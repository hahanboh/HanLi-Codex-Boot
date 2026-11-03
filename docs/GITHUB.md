# 发布与维护

项目仓库：https://github.com/hahanboh/HanLi-Codex-Boot 。只发布本目录，不上传父目录的outputs、备份或现有安装。

## 每次发布

1. 完成scripts/test.ps1及实际动画/换肤/恢复测试，记录没有执行的检查。
2. scripts/verify-repository.ps1检查Git跟踪文件；不要git add -f提交private/、视频、人物图或日志。
3. 更新VERSION、CHANGELOG及已验证环境。
4. 执行scripts/package.ps1 -IncludeBinary生成包含源码和预编译启动器的Windows x64 ZIP；不附带媒体。生成的ZIP旁有SHA-256校验文件。
5. 审阅本地Git改动、提交、打标签、推送后发布GitHub Release。新的Release包须重新生成，不从旧安装目录打包。

## 素材政策

代码与预设按MIT发布；用户影视录屏、Wallpaper壁纸、角色图标和截图的权利单独处理。未确认公开分发许可的素材只留在private/，不会进入仓库或Release。测试视频使用FFmpeg人工图案，不使用动漫截图。

当前运行实例的登录信息、聊天、CDP浏览器配置与安装路径均不打包。公开前仍须人工审阅，模式匹配扫描不能替代所有凭据检查。

Windows发布包的社区可执行文件未做商业代码签名；它不是OpenAI官方可执行文件。首次公开版标记为预发布，不保证所有Windows和Codex版本兼容。
