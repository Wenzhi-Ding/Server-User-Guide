The server interacts with commands through [SSH](https://en.wikipedia.org/wiki/Secure_Shell) and transfers files through [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol). Different operating systems have different recommendations for SSH and SFTP clients.

It is recommended to use Xshell and Xftp to connect to the server. The free version can be downloaded through this [link](https://www.xshell.com/en/free-for-home-school/).

!!! warning "IP Whitelist"

    Since the server may be set to prohibit external access (all servers in this center have been prohibited from external access), please first declare up to 3 commonly used IP addresses to the administrator to exempt the requirement for internal network login.

    Public IP address acquisition method: [ip4.me](https://ip4.me){:target="_blank"}

    Please do not query while using proxies or VPN. Otherwise, you may either be unable to find the IP or return the IP of a public data center.

## SSH

1) Create a new session.

<figure><img src="/assets/xshell-new-connect.png" alt="xshell-new-connect"></figure>

2) Enter the connection configuration.

<figure><img src="/assets/xshell-config-1.png" alt="xshell-config-1"></figure>

3) Enter the username and password.

<figure><img src="/assets/xshell-passwd.png" alt="xshell-passwd"></figure>

4) Click "OK" to save the configuration to the session manager. Double-click the configuration in the session manager to log in to the server. The appearance of `<username>@<host>` indicates a successful login.

<figure><img src="/assets/xshell-login-success.png" alt="xshell-login-success"></figure>

??? question "Cannot connect to 'http://xxx.xxx.xxx'"

    The SSH and SFTP connections do not use the HTTP protocol. Just enter `xxx.xxx.xxx` in the Host field, without adding any additional protocols (unless your server administrator explicitly tells you to).

??? question "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

    This error message indicates that the remote server's key has been modified (such as reinstalling the system or regenerating the key). In this case, you need to delete the public key of that server from the `known_hosts` file on your system.

## SFTP

1) Launch Xftp. Enter the configuration and click Connect to enter the file management interface.

<figure><img src="/assets/xftp-config.png" alt="xftp-config"></figure>

??? question "Cannot connect to 'http://xxx.xxx.xxx'"

    The SSH and SFTP connections do not use the HTTP protocol. Just enter `xxx.xxx.xxx` in the Host field, without adding any additional protocols (unless your server administrator explicitly tells you to).

2) You can then view the saved configurations and log in here.

<figure><img src="/assets/xftp-all-config.png" alt="xftp-all-config"></figure>

3) Set to display hidden files.

<figure><img src="/assets/xftp-show-all-file-1.png" alt="xftp-show-all-file-1"></figure>

<figure><img src="/assets/xftp-show-all-file-2.png" alt="xftp-show-all-file-2"></figure>

4) Right-click on a file to transfer files between the local and server.

<figure><img src="/assets/xftp-transfer.png" alt="xftp-transfer"></figure>

## Port Forwarding

!!! warning "Why do you need to set up port forwarding?"

    This setting is crucial for using Jupyter Lab. Please complete this step before configuring Jupyter Lab. Please apply for a port number from the administrator, and you can choose any number between 10000 and 65535. **Here, we use port 22222 as an example.**

1) Right-click in the session manager and go to the properties of the session configuration.

<figure><img src="/assets/xshell-config-more.png" alt="xshell-config-more"></figure>

2) Add a port forwarding rule.

=== "1. Set up a tunnel"

    <figure><img src="/assets/xshell-tunnel.png" alt="xshell-tunnel"></figure>

=== "2. Set up inbound and outbound ports"

    <figure><img src="/assets/xshell-port.png" alt="xshell-port"></figure>

3) Reconnect the session for the port forwarding to take effect.