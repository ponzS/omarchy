# 场景 1：已有容器通过官方入口更新
ID: SC-UPDATES-EXISTING-CONTAINER
Profile: draft
Gate: required
Given 使用定制 4.0.4 镜像创建的 LightOS Omarchy 容器已启用容器更新适配，官方软件源可用
When 普通用户执行官方 `omarchy update`
Then 官方 Omarchy 和配套设置包完成升级，适用迁移完成
And 用户的个人文件和容器桌面启动配置保留，容器不部署宿主引导或管理宿主内核

# 场景 2：新建容器持续使用官方更新
ID: SC-UPDATES-NEW-CONTAINER
Profile: draft
Gate: required
Given 使用新版 LightOS Omarchy 镜像创建的容器已完成普通用户初始化，官方软件源可用
When 普通用户执行官方 `omarchy update`
Then 更新不受定制 Omarchy 包版本限制，官方软件包与适用迁移正常完成
And 更新后仍可登录桌面，个人文件保留，容器不部署宿主引导或管理宿主内核
