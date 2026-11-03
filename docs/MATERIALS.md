# 提供其他凡人素材

可以继续向助手提供新的凡人视频、壁纸录屏、截图或明确许可的素材地址，不必重做启动器。优先提供本地视频文件；仅有平台页面或离线缓存不能保证可直接编辑。

建议同时说明：

- 角色和镜头：韩立、南宫婉或其他角色；希望保留的动作。
- 原视频起止时间，或者交给助手挑选；通常12–20秒更适合观察循环接点。
- 想显示的主、副文案；是否需要背景和人物图标同步更换。
- 分辨率、是否静音（默认静音）、裁切是否允许。
- 只用于本机，还是计划公开发布；公开素材需提供对应许可或授权。

助手的后续工作：检查视频参数及画面、挑选片段和相近的循环首尾、预合成交叉淡化、导出MP4及背景、给出预览、备份并导入，最后核验冷启动、已运行、Esc及交接。每条新素材都需要重新观察接点，交叉淡化不保证所有镜头无缝。

## 自动制作

参照README的create_media.py命令。所有时间单位为秒；start相对原片，loop参数相对裁片。可用--width 1920 --height 1080导出1080p。画面默认按中心裁切至指定比例，人物偏边时应先另做构图，不要直接套用。

输出：startup.mp4、background.jpg、launcher-timing.json、media-manifest.json。背景取自裁片，视频静音。输出目录已存在时停止，避免覆盖旧素材。文件大小取决于原素材复杂度，发布前检查是否低于期望大小；不要通过重复超清片段无限加长等待。

## 已安装版本替换

先关闭开屏，保存launcher.json和assets中的当前图片；素材导入脚本会备份旧MP4和配置：

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Import-Animation.ps1 -VideoPath "C:\Media\new-theme\startup.mp4" -AppRoot "$env:LOCALAPPDATA\HanLiCodexBoot"
```

MSIX虚拟化环境中实际安装目录可能不同，应使用桌面快捷方式的工作目录。根据新素材包launcher-timing.json设置HoldAt、TransitionStart、TransitionEnd；不要把旧时长和DWM关键帧直接套用。

background.jpg需导入换肤项目的主题，而非只替换开屏等待图；主题ID按SKIN.md配置。图标另提供icon.ico即可，更新前备份。不要把替换好的本地素材加入公开Git。
