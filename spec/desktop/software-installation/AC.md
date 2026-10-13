# 场景 1：通过桌面菜单安装普通软件
ID: SC-INSTALLS-REPOSITORY-SOFTWARE
Profile: draft
Gate: required
Given 普通用户已登录使用本 fork 镜像新建的 Omarchy 实例远程桌面，软件源可用
When 用户从安装菜单选择一个尚未安装的普通软件，并按提示授权安装
Then 安装窗口正常打开，软件安装成功并可以使用
And 用户可以通过终端安装普通软件

# 场景 2：安装 AUR 软件
ID: SC-INSTALLS-AUR-SOFTWARE
Profile: draft
Gate: required
Given 普通用户已登录使用本 fork 镜像新建的 Omarchy 实例，AUR 及所选软件的源码可用
When 用户从 AUR 安装入口选择一个尚未安装的软件，并按提示授权安装
Then 用户能够完成源码构建及安装，并可以使用该软件

# 场景 3：直接使用预装的基础应用
ID: SC-USES-PREINSTALLED-DESKTOP-APPLICATIONS
Profile: draft
Gate: required
Given 普通用户已首次登录使用本 fork 镜像新建的 Omarchy 实例远程桌面
When 用户打开 Chrome、网页应用快捷方式和基础桌面应用
Then Chrome 正常启动，网页应用快捷方式由 Chrome 打开
And Foot、文件管理器、Neovim、图片查看器、视频播放器及 btop 可以启动使用
