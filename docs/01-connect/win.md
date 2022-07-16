服务器通过[SSH](https://en.wikipedia.org/wiki/Secure_Shell)的方式进行命令的交互，通过[SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)的方式进行文件的传输。在不同的操作系统中，对于SSH和SFTP客户端有不同的推荐。

推荐使用Xshell和Xftp连接服务器，免费版可以通过此[链接](https://www.xshell.com/zh/free-for-home-school/)下载。

## SSH

1、新建会话。

<figure><img src="/assets/xshell-new-connect.png" alt="xshell-new-connect"></figure>

2、输入连接配置。

<figure><img src="/assets/xshell-config-1.png" alt="xshell-config-1"></figure>

3、输入用户名及密码。

<figure><img src="/assets/xshell-passwd.png" alt="xshell-passwd"></figure>

4、点击“确定”将配置保存至会话管理器。在会话管理器中双击该配置即可登入服务器。出现`<username>@<host>`字样表示已成功登入。

<figure><img src="/assets/xshell-login-success.png" alt="xshell-login-success"></figure>

## SFTP

1、启动Xftp。输入配置后点链接即可进入文件管理界面。

<figure><img src="/assets/xftp-config.png" alt="xftp-config"></figure>

2、随后可以在此处查看保存的配置并登入。

<figure><img src="/assets/xftp-all-config.png" alt="xftp-all-config"></figure>

3、设置展示隐藏文件。

<figure><img src="/assets/xftp-show-all-file-1.png" alt="xftp-show-all-file-1"></figure>

<figure><img src="/assets/xftp-show-all-file-2.png" alt="xftp-show-all-file-2"></figure>

4、右键文件即可在本地和服务器之间传输文件。

<figure><img src="/assets/xftp-transfer.png" alt="xftp-transfer"></figure>



## 端口侦听

!!! 为什么需要设置端口侦听

	此部分的设置对使用Jupyter Lab非常关键，请务必先完成此步骤再配置Jupyter Lab。端口号请向管理员申请，可以在20000-49999之间选择任意数字。**此处以22222端口为例。**

1、在会话管理器中右键，进入会话配置的属性。

<figure><img src="/assets/xshell-config-more.png" alt="xshell-config-more"></figure>

2、添加端口侦听规则。

=== "1. 设置隧道"

	<figure><img src="/assets/xshell-tunnel.png" alt="xshell-tunnel"></figure>

=== "2. 设置出入端口"

	<figure><img src="/assets/xshell-port.png" alt="xshell-port"></figure>

3、重新连接会话使端口侦听生效。

