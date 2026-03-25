The server interacts with commands via [SSH](https://en.wikipedia.org/wiki/Secure_Shell) and transfers files via [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol). Different SSH and SFTP clients are recommended for different operating systems.

It is recommended to use Xshell and Xftp to connect to the server. The free version can be downloaded via this [link](https://www.xshell.com/zh/free-for-home-school/). The user interface is relatively user-friendly and easy to use.

However, since Xshell and Xftp are paid software with limited features in the free version, you can consider using VS Code with an SSH plugin as an SSH client and [WinSCP](https://winscp.net/eng/download.php) as an SFTP client after you are familiar with SSH and SFTP operations.

!!! warning "IP Whitelist"

	Since the server may be configured to prevent access from external networks (all servers in this center have external network access disabled), please first declare up to 3 commonly used IP addresses to the administrator to exempt the requirement for internal network login.

	How to obtain a public IP address: [ip4.me](https://ip4.me){:target="_blank"}

	Please do not query while using a proxy or VPN. Otherwise, you may not be able to find the IP address, or it may return the IP address of a public data center.

	Some teams can use a [jump server](../08-linux/jump-proxy.md) to bypass the restrictions. Please consult the IT administrator of your team for details.

!!! tip "PolyU Users"

	If you are a PolyU user, please quit all third-party antivirus software before connecting, keeping only the built-in Windows Defender, in order to pass the GlobalProtect VPN security check.

## SSH

1. Create a new session.

<figure><img src="/assets/xshell-new-connect.png" alt="xshell-new-connect"></figure>

2. Enter the connection configuration.

<figure><img src="/assets/xshell-config-1.png" alt="xshell-config-1"></figure>

3. Enter the username and password.

<figure><img src="/assets/xshell-passwd.png" alt="xshell-passwd"></figure>

4. Click "OK" to save the configuration to the session manager. Double-click the configuration in the session manager to log in to the server. The appearance of `<username>@<host>` indicates successful login.

<figure><img src="/assets/xshell-login-success.png" alt="xshell-login-success"></figure>

??? question "Cannot connect to 'http://xxx.xxx.xxx'"

	The connection for SSH and SFTP does not use the HTTP protocol. Simply enter `xxx.xxx.xxx` in the Host field; no additional protocol needs to be added (unless your server administrator explicitly tells you that you need one).

??? question "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

	This error message indicates that the remote server's key has been changed (e.g., the system was reinstalled, or a new key was generated). In this case, you need to delete the public key of this server from your system's `known_hosts` file.

## SFTP

1. Start Xftp. Enter the configuration and click "Connect" to enter the file management interface.

<figure><img src="/assets/xftp-config.png" alt="xftp-config"></figure>

??? question "Cannot connect to 'http://xxx.xxx.xxx'"

	The connection for SSH and SFTP does not use the HTTP protocol. Simply enter `xxx.xxx.xxx` in the Host field; no additional protocol needs to be added (unless your server administrator explicitly tells you that you need one).
	
2. You can then view and log in to the saved configurations here.

<figure><img src="/assets/xftp-all-config.png" alt="xftp-all-config"></figure>

3. Set to display hidden files.

<figure><img src="/assets/xftp-show-all-file-1.png" alt="xftp-show-all-file-1"></figure>

<figure><img src="/assets/xftp-show-all-file-2.png" alt="xftp-show-all-file-2"></figure>

4. Right-click on a file to transfer it between the local machine and the server.

<figure><img src="/assets/xftp-transfer.png" alt="xftp-transfer"></figure>



## Port Listening

!!! warning "Why is port listening necessary?"

	This setting is crucial for using Jupyter Lab. Please complete this step before configuring Jupyter Lab. Please apply for a port number from the administrator, and you can choose any number between 10000-65535. **This example uses port 22222.**

1. Right-click in the session manager and go to the properties of the session configuration.

<figure><img src="/assets/xshell-config-more.png" alt="xshell-config-more"></figure>

2. Add a port listening rule.

=== "1. Set up a tunnel"

	<figure><img src="/assets/xshell-tunnel.png" alt="xshell-tunnel"></figure>

=== "2. Set up inbound and outbound ports"

	<figure><img src="/assets/xshell-port.png" alt="xshell-port"></figure>

3. Reconnect the session to activate port listening.
