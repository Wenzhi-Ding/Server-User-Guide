!!! note "请先了解以下内容再配置VSCode版的Jupyter"

	- [网页版](03-jupyter/web)的设置
	- 使用Screen命令将Jupyter Lab[挂载于后台](/08-linux/screen)
	- [SSH免密码登录](/08-linux/pubkey)

VSCode版本的好处是可以使用VSCode中丰富的插件，比如[查看变量表和值](https://code.visualstudio.com/docs/datascience/jupyter-notebooks#_variable-explorer-and-data-viewer)、代码分屏（以上两个是网页版的硬伤）、自动补全、快速跳转、代码纠错、显示函数参数文档、自定义主题、交互式的Git版本管理等（如[PyLance](https://github.com/microsoft/pylance-release)、[GitHub Copilot](https://github.com/features/copilot)、[GitHub Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme)）


1、在本地安装VSCode，并安装RemoteSSH插件。具体过程可见[官方教程](https://code.visualstudio.com/docs/remote/ssh)。

2、设置[SSH免密码登录](/08-linux/pubkey)后，将本地的SSH配置文件增加以下内容。

本地的SSH配置文件的位置通常为（可用VSCode或记事本打开编辑）：

```bash
"C:\Users\[local_username]\.ssh\config"
```

添加以下内容使得SSH登陆时调用本地私钥，从而不必手动输入密码。

```bash
Host [host]
  HostName [host]
  User [username]
  IdentityFile "C:\Users\[local_username]\.ssh\id_rsa"
```

3、VSCode中登录服务器后，在VSCode的资源管理器中添加项目文件夹，双击其中的`ipynb`文件即可打开Jupyter Lab。

4、将Jupyter Lab设置为[固定Token登录](/03-jupyter/install/#__tabbed_1_4)。
	
启动Jupyter Lab，复制包含Token的URI`http://localhost:22222/lab?token=foobar`（注意，在SSH终端中显示应为`http://localhost:22222/lab?token=...`，需要自己将设置好的Token填写到URI中）

将该URI输入给VSCode右下角的“Jupyter Server”，即可免于每次登录输入Jupyter Lab的密码。

??? question "为何服务器Conda环境已配置，运行代码时却提示缺少某些组件？"

	**原因**
	
	可能是因为你未选择服务器端的Kernel，因此VSCode默认使用了你本地的Jupyter Kernel。
	
	**解决方法**
	
	在VSCode右上角的内核设定中，选择服务器端的ipython内核。主要可以通过Kernel的路径、Remote字样或Conda环境名称来确定是否为服务器上的内核。
	
	<figure><img src="/assets/jupyter-vscode-kernel-select.png"></figure>

5、VSCode中Jupyter Lab的使用方法可以参考[官方教程](https://code.visualstudio.com/docs/datascience/jupyter-notebooks)

??? question "如何在SSH连接中断后恢复内核并继续工作？"
	
	首先需要确保已按照[该方式](/08-linux/screen)运行Jupyter Lab。
	
	在右上角的内核选择中，选择此前该笔记本的内核即可。
	
	<figure><img src="/assets/jupyter-vscode-restore-kernel.png"></figure>

!!! note "VSCode版的内核管理"

	目前，VSCode版尚不支持像网页版一样关闭内核。因此，建议你定期有意识的去清理内核，否则可能会有过多的内核堆在后台。
	
	最简单的方法是定期重新启动Jupyter Lab。另一个方法则是打开网页版，在网页版中清理完内核再回到VSCode版工作。
	
	P.S.：如果是我负责维护的那些服务器，会有脚本自动检测并提示你关闭占用内存或缓存过高的进程。