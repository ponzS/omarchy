# 场景 1：切入 Omarchy 后直接使用桌面
ID: SC-OMARCHY-PHYSICAL-AUTOLOGIN
Profile: draft
Gate: required
Given 实例所有者为 Omarchy 实例启用了显示接管，当前显示器正在使用另一个实例的桌面
When 所有者启动 Omarchy 实例并通过宿主机 `hc vt switch` 切到它
Then 启动实例不抢占当前显示，切入后直接显示普通实例用户的 Omarchy 桌面
And 用户无需在终端登录界面再次输入账号密码

# 场景 2：多个桌面可以切出并恢复
ID: SC-OMARCHY-PHYSICAL-VT-HANDOFF
Profile: draft
Gate: required
Given 所有者已经进入 Omarchy 物理桌面，同时连接着该实例的远程桌面，另一个实例已有可用的物理桌面会话
When 所有者使用宿主机 `hc vt switch` 切到另一个实例，再切回 Omarchy
Then 两次切换分别显示目标实例的桌面，画面和鼠标键盘正常
And Omarchy 恢复原有会话且无需重新登录，远程桌面仍可使用
