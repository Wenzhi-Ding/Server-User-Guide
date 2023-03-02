服务器通过 [SSH](https://en.wikipedia.org/wiki/Secure_Shell) 的方式进行命令的交互，通过 [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol) 的方式进行文件的传输。在不同的操作系统中，对于 SSH 和 SFTP 客户端有不同的推荐。

推荐使用 Xshell 和 Xftp 连接服务器，免费版可以通过此[链接](https://www.xshell.com/zh/free-for-home-school/)下载。

!!! warning "IP 白名单"

	由于服务器可能设置了禁止外网访问（本中心的服务器已全部禁止外网访问），请首先向管理员申报你至多 3 个常用的 IP 地址，以豁免内网登陆的要求。

	公网 IP 地址获取方式：在百度搜索“IP”即可得到

## SSH

1、新建会话。

<figure><img src="/assets/xshell-new-connect.png" alt="xshell-new-connect"></figure>

2、输入连接配置。

<figure><img src="/assets/xshell-config-1.png" alt="xshell-config-1"></figure>

3、输入用户名及密码。

<figure><img src="/assets/xshell-passwd.png" alt="xshell-passwd"></figure>

4、点击“确定”将配置保存至会话管理器。在会话管理器中双击该配置即可登入服务器。出现 `<username>@<host>` 字样表示已成功登入。

<figure><img src="/assets/xshell-login-success.png" alt="xshell-login-success"></figure>

??? question "Cannot connect to 'http://xxx.xxx.xxx'"

	SSH 和 SFTP 的连接并不是使用 HTTP 协议。只需要将 `xxx.xxx.xxx` 填入 Host 位置即可，不需要添加任何额外的协议（除非你的服务器管理员明确告知你需要）。

## SFTP

1、启动 Xftp。输入配置后点链接即可进入文件管理界面。

<figure><img src="/assets/xftp-config.png" alt="xftp-config"></figure>

??? question "Cannot connect to 'http://xxx.xxx.xxx'"

	SSH 和 SFTP 的连接并不是使用 HTTP 协议。只需要将 `xxx.xxx.xxx` 填入Host位置即可，不需要添加任何额外的协议（除非你的服务器管理员明确告知你需要）。
	
2、随后可以在此处查看保存的配置并登入。

<figure><img src="/assets/xftp-all-config.png" alt="xftp-all-config"></figure>

3、设置展示隐藏文件。

<figure><img src="/assets/xftp-show-all-file-1.png" alt="xftp-show-all-file-1"></figure>

<figure><img src="/assets/xftp-show-all-file-2.png" alt="xftp-show-all-file-2"></figure>

4、右键文件即可在本地和服务器之间传输文件。

<figure><img src="/assets/xftp-transfer.png" alt="xftp-transfer"></figure>



## 端口侦听

!!! warning "为什么需要设置端口侦听"

	此部分的设置对使用 Jupyter Lab 非常关键，请务必先完成此步骤再配置 Jupyter Lab。端口号请向管理员申请，可以在 10000-65535 之间选择任意数字。**此处以 22222 端口为例。**

1、在会话管理器中右键，进入会话配置的属性。

<figure><img src="/assets/xshell-config-more.png" alt="xshell-config-more"></figure>

2、添加端口侦听规则。

=== "1. 设置隧道"

	<figure><img src="/assets/xshell-tunnel.png" alt="xshell-tunnel"></figure>

=== "2. 设置出入端口"

	<figure><img src="/assets/xshell-port.png" alt="xshell-port"></figure>

3、重新连接会话使端口侦听生效。

