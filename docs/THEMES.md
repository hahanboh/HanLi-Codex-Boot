# 韩立和慕沛灵预设

| 预设 | 主/副文案 | 色调 | 独立目录/桌面入口 |
| --- | --- | --- | --- |
| hanli | 道友，请留步 / 灵气汇聚，仙途将启…… | 青玉白 | HanLiCodexBoot / HanLi Codex |
| mupeiling | 仙缘再续 / 清风引仙路，静候洞府开启…… | 暖白淡金 | MuPeilingCodexBoot / MuPeiling Codex |

文案、颜色和窗口标题来自presets/*.json；安装后在launcher.json修改TextTitle、TextSubtitle、TitleColor、SubtitleColor即可，不再需要为文案重新编译。

素材由用户自备，主题预设本身不包含人物图像。角色名称用于主题识别，不代表动漫方授权。

## 慕沛灵示例

本地试作录屏的右侧有96像素黑边，有效区域1824×1080。下面参数只针对这种录屏尺寸，不适用于所有视频：

```powershell
python .\tools\create_media.py "C:\Media\mupeiling-recording.mp4" --start 4 --duration 20 --loop-start 8 --loop-end 17 --blend 0.6 --crop 1824:1080:0:0 --width 1920 --height 1080 --output .\private\mupeiling
powershell -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\Install-HanLi.ps1 -MediaDirectory .\private\mupeiling -Preset mupeiling
```

--crop会先裁掉黑边，再将全部有效画面缩放到目标尺寸，因此1824到1920存在约5.3%的横向拉伸；不再裁掉额外人物内容。要保持原比例，应选择匹配的输出和开屏窗口尺寸。

可选换肤时增加-EnableSkin，安装器将素材包背景保存到独立skin-theme，不覆盖全局活动主题。运行不同入口会切换当前Codex会话的背景；两套入口共用真正的Codex及账号，不是隔离工作区。

本地试作已验证：1920×1080、30FPS、静音、约26.5MiB，已运行Codex场景约21秒完成交接，窗口1600×900对齐，皮肤校验通过。该试作素材不随开源仓库或Release上传。
