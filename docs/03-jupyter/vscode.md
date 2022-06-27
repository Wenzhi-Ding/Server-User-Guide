推荐在完成[网页版](03-jupyter/web)的设置后再配置VSCode的版本。

1、在本地安装VSCode，并安装RemoteSSH插件。具体过程可见[官方教程](https://code.visualstudio.com/docs/remote/ssh)。

2、推荐先设置[SSH免密码登录](08-linux/pubkey)，并将本地的SSH配置文件增加以下内容：

```bash
Host [host]
  HostName [host]
  User [username]
  IdentityFile "C:\Users\[local_username]\.ssh\id_rsa"
```

本地的SSH配置文件通常为：

```bash
"C:\Users\[local_username]\.ssh\config"
```

3、VSCode中登录服务器后，在VSCode的资源管理器中添加项目文件夹，双击其中的`ipynb`文件即可打开Jupyter Lab。

4、VSCode中Jupyter Lab的使用方法可以参考[官方教程](https://code.visualstudio.com/docs/datascience/jupyter-notebooks)

??? question "如何在SSH连接中断后恢复内核并继续工作"
	
	首先需要确保已按照[该方式](08-linux/screen)运行Jupyter Lab。
	
	在右上角的内核选择中，选择此前该笔记本的内核即可。
	
	<figure><img src="/assets/jupyter-vscode-restore-kernel.png"></figure>

