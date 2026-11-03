"""Prepare a private, silent media pack using an independently installed FFmpeg."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--start', type=float, default=0)
    parser.add_argument('--duration', type=float, default=14)
    parser.add_argument('--loop-start', type=float, default=5)
    parser.add_argument('--loop-end', type=float, default=10.5)
    parser.add_argument('--blend', type=float, default=.4)
    parser.add_argument('--wait', type=float, default=65)
    parser.add_argument('--width', type=int, default=1280)
    parser.add_argument('--height', type=int, default=720)
    parser.add_argument('--ffmpeg', default='ffmpeg')
    parser.add_argument('--crop', help='Effective picture rectangle: width:height:x:y. Full cropped picture is resized to output dimensions.')
    args = parser.parse_args()
    if not args.source.is_file():
        parser.error('Source does not exist.')
    if args.output.exists():
        parser.error('Output already exists; choose a new directory to preserve earlier work.')
    if not (args.start >= 0 and 0 < args.blend < args.loop_start < args.loop_end <= args.duration and args.loop_end - args.loop_start > 2 * args.blend):
        parser.error('Require 0 < blend < loop-start < loop-end <= duration and loop longer than twice blend.')
    if args.duration < 4 or args.wait < args.duration or args.width < 320 or args.height < 180 or args.width % 2 or args.height % 2:
        parser.error('Invalid duration, wait, or even output dimensions.')
    exe = shutil.which(args.ffmpeg)
    if not exe:
        parser.error('FFmpeg not found; use --ffmpeg with an absolute executable path.')
    if args.crop and not re.fullmatch(r'[1-9]\d*:[1-9]\d*:\d+:\d+', args.crop):
        parser.error('Crop must be width:height:x:y with positive dimensions and nonnegative origin.')
    args.output.mkdir(parents=True)
    def run(*items):
        subprocess.run([exe, '-hide_banner', '-loglevel', 'error', '-y', *map(str, items)], check=True)
    with tempfile.TemporaryDirectory(prefix='hanli-media-') as folder:
        temp = Path(folder)
        clip = temp / 'clip.mp4'
        framing = (f'crop={args.crop},scale={args.width}:{args.height}' if args.crop else f'scale={args.width}:{args.height}:force_original_aspect_ratio=increase,crop={args.width}:{args.height}')
        run('-ss', args.start, '-i', args.source, '-t', args.duration,
            '-vf', framing + ',setsar=1,fps=30,format=yuv420p',
            '-an', '-c:v', 'libx264', '-preset', 'fast', '-crf', '22', clip)
        # Both segments finish at loop-start + blend. Repeating the encoded cycle needs no seek.
        for name, start in [('intro', 0), ('cycle', args.loop_start + args.blend)]:
            offset = args.loop_end - start - args.blend
            graph = (f'[0:v]trim=start={start}:end={args.loop_end},setpts=PTS-STARTPTS,fps=30,settb=AVTB[a];'
                     f'[0:v]trim=start={args.loop_start}:end={args.loop_start + args.blend},setpts=PTS-STARTPTS,fps=30,settb=AVTB[b];'
                     f'[a][b]xfade=transition=fade:duration={args.blend}:offset={offset},format=yuv420p[v]')
            run('-filter_complex_threads', 1, '-i', clip, '-filter_complex', graph, '-map', '[v]',
                '-an', '-c:v', 'libx264', '-preset', 'fast', '-crf', '24', '-g', '30', temp / f'{name}.mp4')
        period = args.loop_end - args.loop_start - args.blend
        count = max(1, int((args.wait - args.loop_end) / period) + 1)
        listing = temp / 'concat.txt'
        listing.write_text("file 'intro.mp4'\n" + "file 'cycle.mp4'\n" * count, encoding='utf-8')
        video = args.output / 'startup.mp4'
        run('-f', 'concat', '-safe', 0, '-i', listing, '-c', 'copy', '-movflags', '+faststart', video)
        run('-ss', min(args.loop_start, args.duration / 2), '-i', clip, '-frames:v', 1, args.output / 'background.jpg')
        run('-i', video, '-f', 'null', '-')
    timing = {'HoldAt': args.duration - 3, 'TransitionStart': args.duration - .8, 'TransitionEnd': args.duration - .05}
    (args.output / 'launcher-timing.json').write_text(json.dumps(timing, indent=2), encoding='utf-8')
    manifest = {'source_sha256': hashlib.file_digest(args.source.open('rb'), 'sha256').hexdigest(),
                'video_sha256': hashlib.file_digest(video.open('rb'), 'sha256').hexdigest(),
                'crop': args.crop, 'start_seconds': args.start, 'duration_seconds': args.duration,
                'loop_start': args.loop_start, 'loop_end': args.loop_end, 'blend_seconds': args.blend,
                'audio': 'none', 'rights': 'User supplied; permission to publish must be checked separately.'}
    (args.output / 'media-manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    print(f'Media pack ready: {args.output.resolve()} ({video.stat().st_size / 1048576:.1f} MiB)')


if __name__ == '__main__':
    main()
