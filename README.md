# 凡人主题 Codex 开屏

Windows 版 Codex 的社区开屏工具，附韩立、慕沛灵两段示例视频。支持静音播放、圆角窗口、Esc跳过；动画播放时同步打开真正的Codex。

## 使用

1. 从右侧 **Releases** 下载 Windows x64 压缩包并解压。
2. 双击 **启动韩立.cmd** 或 **启动慕沛灵.cmd**。
3. 想用自己的素材，双击 **使用自己的视频.cmd** 选择MP4。以后再次双击会复用所选视频；换新视频也可放到 `media/custom.mp4`。

也可以直接把自己的MP4改名为 `hanli.mp4` 或 `mupeiling.mp4`，替换 `media` 中的对应文件，原来的启动按钮照常使用。视频时长自动读取，不必手工设置转场时间。建议使用H.264 MP4。

需要先剪辑？把原视频和想保留的时间段交给助手，按[素材制作说明](docs/素材制作.md)生成素材包，再用其中的 `startup.mp4` 替换示例即可。制作工具保留在 `tools/create_media.py`。

## 说明

- 需要Windows 11 x64、.NET Framework 4.8及官方Codex桌面版。普通用户运行，不改官方程序，不替换原快捷方式。
- 即用模式仅添加开屏，不需要Python、FFmpeg或换肤依赖。Python和FFmpeg只用于剪辑制作。
- 运行文件缓存在当前用户的LOCALAPPDATA/FanrenCodexBoot。解压目录和视频建议长期保留。
- `打开原版Codex.cmd` 可直接使用官方入口。不添加后台服务；慢启动最多等待60秒。
- 可选背景换肤见[换肤说明](docs/SKIN.md)，不影响默认开屏使用。

## 源码与素材

源码及构建脚本在 `src/`、`scripts/`，运行 `scripts/test.ps1` 验证。Release内已附预编译程序；从源码启动时会自动尝试构建。

本项目基于 [dragon-codex-boot](https://github.com/yushua0808-cpu/dragon-codex-boot)，保留上游MIT许可，非OpenAI官方产品。代码MIT许可不包含示例视频；Wallpaper来源、创作者和素材权利见[素材来源说明](media/来源说明.md)。
