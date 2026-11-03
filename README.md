# HanLi Codex Boot · 凡人主题 Codex 开屏

包含 **韩立·结婴** 与 **慕沛灵·红绡仙影** 两套预设。

Windows 社区启动器：先显示修仙主题动画，同时启动真正的 Codex；准备好后淡出进入主窗口。支持 Esc、圆角、固定开屏位置和可选韩立背景皮肤。

基于 [dragon-codex-boot v0.2.0](https://github.com/yushua0808-cpu/dragon-codex-boot)，换肤兼容 [Codex-Dynamic-Skin v1.7.3](https://github.com/CCDawn/Codex-Dynamic-Skin)。本项目不是 OpenAI 官方产品，也不修改官方安装包。

**仓库不附带动漫视频、壁纸、人物图标或个人配置。** 代码 MIT 许可不代表动漫素材获得开放授权。你可以使用自己提供、获许可的素材制作本地主题；公开发布媒体前需另行确认权利。

## 快速开始

环境：Windows 11 x64（本机已验证）、.NET Framework 4.8、Windows PowerShell 5.1、官方 Codex MSIX；制作素材另需 Python 3.11+ 和提供 H.264 编码器的 FFmpeg。Windows 10、其他 Codex 分发方式尚未验证。

1. 将自己的视频放到仓库外，或者忽略的 `private/` 目录。
2. 制作素材包：

```powershell
python .\tools\create_media.py "C:\Media\recording.mp4" --start 14 --duration 14 --loop-start 5 --loop-end 10.5 --output .\private\hanli
```

`--start` 相对原始视频；`--loop-start/end` 相对裁出的片段。默认静音、1280×720、30 FPS、H.264。视频中等待段已预合成交叉淡化，运行时不反复 seek。启动器窗口默认1600×900，放大720p不增加原始清晰度。

3. 下载 [Windows x64 Release](https://github.com/hahanboh/HanLi-Codex-Boot/releases/latest) 并解压的用户无需编译；从源码安装时先构建及隔离测试：

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\test.ps1
```

4. 首次安装到未使用的本地目录：

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Install-HanLi.ps1 -MediaDirectory .\private\hanli
```

使用 `-Preset mupeiling` 安装慕沛灵预设，默认独立目录及 `MuPeiling Codex` 快捷方式。

桌面出现独立的 `HanLi Codex` 入口；原版快捷方式保留，不扫描磁盘批量替换。安装目录已存在会停止，避免覆盖现有配置。**已安装用户请看[换素材](docs/MATERIALS.md)。**

5. 可选换肤：先按 [SKIN.md](docs/SKIN.md) 配置独立依赖，再安装时加 `-EnableSkin`。未加此参数只启用动画。仓库不自动下载或打包换肤管理器。

## 文档

- [两套主题及慕沛灵去黑边示例](docs/THEMES.md)
- [日常使用、安装与恢复](docs/USAGE.md)
- [提供新素材与制作流程](docs/MATERIALS.md) / [素材需求模板](docs/素材需求模板.md)
- [换肤依赖与安全边界](docs/SKIN.md)
- [配置参数](docs/CONFIGURATION.md)
- [测试与已知限制](docs/TESTING.md)
- [发布到 GitHub](docs/GITHUB.md)
- [上游归属及素材权利](THIRD_PARTY_NOTICES.md)

## 项目结构

```text
src/             启动器C#代码和Windows manifest
runtime/         并行启动、换肤桥接与恢复脚本
config/          可发布配置模板，无个人路径
presets/         韩立、慕沛灵的文案、配色和独立入口预设
scripts/         构建、导入、安装、恢复、测试及发布检查
tools/          FFmpeg素材包制作工具
tests/          几何与隔离快捷方式测试
docs/           中文使用和维护文档
licenses/       保留的第三方许可
private/        本地私有素材，Git忽略
```

本机现有安装未被本次仓库整理替换。源码仓库已验证构建及测试；新版安装器的端到端安装/恢复、第二台干净电脑测试均尚未完成。发布前应执行文档中的人工检查。
