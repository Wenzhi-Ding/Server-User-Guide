!!! warning "不再推荐使用网页版 Jupyter Lab"

	我们现在推荐使用 [VSCode 版 Jupyter Lab](vscode.md)，原因如下：

	- VSCode 提供更丰富的插件生态（代码补全、跳转、纠错、Copilot 等）
	- VSCode 支持变量查看器和数据查看器，网页版不支持
	- VSCode 支持代码分屏，网页版不支持
	- 网页版需要维护额外的端口转发配置，VSCode 通过 Remote SSH 直接连接
	- 网页版在网络波动时容易中断，VSCode 更稳定

	以下内容保留供参考。

---

1、尝试启动Jupyter Lab。在服务器中输入以下命令

```bash
jupyter lab
```

<figure><img src="/assets/jupyter-start.png"></figure>

若出现结尾是`/lab`的链接，表明Jupyter Lab配置完成。

??? question "链接结尾未出现`/lab`"
	
	**原因**
	
	若链接的结尾有一串形同加密字符串的内容，说明在没有正确配置Jupyter Lab的密码。
	
	**解决方案**
	
	重新[配置Jupyter Lab的密码](install.md)（第5步）。

2、打开本地浏览器，访问上述任一网址。

=== "1. 浏览器访问"
	
	输入在此前设置的Jupyter Lab密码。
	
	<figure><img src="/assets/jupyter-enter-passwd.png"></figure>

=== "2. Jupyter Lab界面"

	<figure><img src="/assets/jupyter-ui.png"></figure>
=== "3. 编辑及运行代码"

	<figure><img src="/assets/jupyter-ui2.png"></figure>

!!! 稳定运行

	当网络发生波动或SSH终端意外被关闭（比如电脑关机、待机），Jupyter Lab也会终止运行。当您的Jupyter Lab配置完成、可以正常访问后，**请务必参考[Screen命令教程](../08-linux/screen.md)将Jupyter Lab挂载于独立的窗口下。**

!!! 自动完成括号配对

	在Settings菜单中，推荐勾选Auto Close Brackets。这样当你输入引号、括号的左半部分时，系统会自动输入右半部分，并把你的光标置于括号中间。编辑体验比较好。
	
	<figure><img src="/assets/jupyter-auto-close-brackets.png"></figure>

??? question "Jupyter Lab链接中的端口号正确，但本地电脑浏览器中显示无法访问"

	**原因**
	
	可能其他应用程序恰巧占用了该端口。
	
	**解决方案**
	
	对于本地端口占用：
	
	- 简单方案：重启自己的电脑后首先连接服务器并打开Jupyter Lab。
	- 精准方案：通过`netstat -aof | findstr:xxxxx`（Windows）或`lsof -i | grep xxxx`（Linux或MacOS）找出占用了xxxxx端口的应用程序。关闭该应用程序后即可正常访问Jupyter Lab。

??? question "The port xxxxx is already in use"

	**原因**

	说明服务器上其他人或应用程序占用了该端口（称为“服务器端口占用”）。

	**解决方案**

	对于服务器端口占用：首先尝试关闭自己之前已经打开了的Jupyter Lab。如果仍然显示`The port xxxxx is already in use`，那很有可能是其他用户占用了该端口。通过`lsof -i | grep xxxx`可以找到占用了该端口的进程号和用户。这种情况需要联系管理员来协调。

??? question "Jupyter Lab密码不正确"

	**原因**
	
	可能是忘记密码了。
	
	**解决方案**
	
	重复[安装](install.md)的第5步。重新设定密码后，重启Jupyter Lab即可。