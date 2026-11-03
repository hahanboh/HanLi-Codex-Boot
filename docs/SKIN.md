# 可选Codex背景皮肤

基础动画不需要此依赖。换肤需要单独安装CCDawn/Codex-Dynamic-Skin v1.7.3，并先用上游管理器应用自有背景、验证Codex能正常打开。管理器不包含在本仓库，不提供自动下载。

兼容约定：运行时位于LOCALAPPDATA/CodexDreamSkin/manager-runtime/1.7.3，活动主题位于LOCALAPPDATA/CodexDreamSkin/active-theme/theme.json。安装器为每套预设生成独立skin-theme及主题ID（custom-hanli或custom-mupeiling），桥接读取该ID验证。先用上游管理器确认独立调试会话可以正常登录和换肤。

**启用本机127.0.0.1:9335调试端口后，同机程序可能访问可见聊天等应用内容。** 这是可选能力，安装时只有明确传入-EnableSkin才启用；不公开绑定0.0.0.0。桥接复用上游进程和CDP身份校验，不读取API Key文件。首次换肤会使用独立CDP浏览器配置，可能需要在该配置重新登录；不要复制凭据来绕过登录。

本机兼容改动需要应用到上游1.7.3的payload/scripts/injector.mjs：

1. runOneShot内两处applyToSession(session, payload)应为applyToSession(session, loadedPayload)。检查版本中是否已修复，勿全文件盲替换。
2. setStreamCspBypass函数中，requested为false且session.dreamSkinStreamCspBypass尚未初始化时，赋false并返回，避免静态图片首次应用时多发不必要的Page.setBypassCSP。

本仓库提供scripts/Patch-SkinRuntime.ps1进行备份和限定替换；仅针对1.7.3，陌生版本应先审阅，不能删除身份校验。该补丁不修改官方Codex安装包。

然后使用新安装器-EnableSkin（可加-Preset mupeiling）。本仓库不自动应用运行时补丁；请先执行兼容补丁并检查输出。当前桥接在启动真实窗口后用UTF-8读取注入报告，页面未就绪时重试；上游或Codex更新仍可能导致选择器和启动行为变化。多窗口、其他平台以及干净机器上的完整换肤安装尚需额外测试。恢复请先运行安装目录skin-tools/Restore-Skin.ps1。
