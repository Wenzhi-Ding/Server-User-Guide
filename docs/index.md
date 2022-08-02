# 服务器使用指南

本手册提供了从基础到进阶的多个使用指引。

## 用户反馈

服务器使用过程中如遇到任何：

1. 该指南未覆盖的问题；
2. 无法快速在指南中找到解决方案的问题。

请及时联系丁文治（微信、Slack或邮箱）或在GitHub上[提Issues](https://github.com/Wenzhi-Ding/Server-User-Guide/issues)，我会帮忙解决并更新该指南。

非常欢迎直接编辑页面后在GitHub上[发起Pull Requests](https://github.com/Wenzhi-Ding/Server-User-Guide/pulls)！

如果你在指南中看到需要联系“管理员”的部分，但你不明白其含义，那么可以忽略这部分。这些要求只在某些服务器上生效。



## 快速目录

### 必要步骤

- [连接服务器](/01-connect/win/)
- [Linux基本命令](/08-linux/basic/)

### 推荐完成

若计划使用Python或Jupyter，请参考：

- [Conda](/02-conda/install/)
- [Jupyter Lab](/03-jupyter/install)

Stata和SAS亦可通过以上方式使用。

- [Jupyter中使用Stata](/04-stata/jupyter/)
- [Jupyter中使用SAS](/05-sas/jupyter/)

若只计划轻度使用Stata或SAS，可以参考：

||Stata|SAS|
|:-|:-|:-|
|不在服务器写代码|[Stata命令行](/04-stata/command-line)|[SAS命令行](/05-sas/command-line)|
|需要在服务器看数据和写代码|[Stata图形界面](/04-stata/gui)|[SAS图形界面](/05-sas/gui)|

### 其他推荐阅读

- 断网后程序中断：[Linux后台稳定运行程序](/08-linux/screen/)
- 服务器宕机：[避免过度占用资源](/08-linux/smem/)
- 希望有图形界面可以操作：[Linux的图形界面](/08-linux/gui)