# 配置

配置模板：config/launcher.example.json；实际配置：安装目录launcher.json。

| 参数 | 当前默认/作用 |
| --- | --- |
| AutoReplaceEntrypoints / ScanAllLocalDrives | false；不自动扫描快捷方式 |
| AppLaunch | 官方Codex AppsFolder入口，不运行CLI代替GUI |
| AppLaunchScript | null为仅动画；Concurrent-Skin.ps1启用并行换肤 |
| Video | media/startup.mp4 |
| PlayerWidth / PlayerHeight | 1600 / 900，物理像素 |
| Volume | 0 |
| HoldAt / TransitionStart / TransitionEnd | 11 / 13.2 / 13.95，新素材应采用素材包时间配置 |
| FadeOnly | true，避免原动画专用DWM矩形帧 |
| MatchClientToPlayer | true；实现按可见窗口外框匹配 |
| PlayWhileWaiting | true；连续播放已预合成视频 |
| MaxWaitSeconds | 100；当前实现还有60秒硬上限 |

文案和配色由TextTitle、TextSubtitle、TitleColor、SubtitleColor控制，颜色使用#RRGGBB；预设见presets。ThemeDirectory为空时复用已设置的活动主题；安装器开启换肤时设置skin-theme，路径必须留在安装目录内。字体仍为华文行楷/华文仿宋，未安装时回退。

窗口默认尺寸需满足Codex在该显示缩放下的最小尺寸；本机旧1280×720不足，1600×900已测试。若仍不匹配，应增大开屏而不是强制压缩Codex内容。不要未经验证开启全盘快捷方式替换。
