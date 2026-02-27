The server interacts with commands through [SSH](https://en.wikipedia.org/wiki/Secure_Shell) and transfers files through [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol). Different operating systems have different recommendations for SSH and SFTP clients.

On macOS, you can use Terminal for SSH connections and [FileZilla](https://filezilla-project.org/download.php?platform=osx) for SFTP connections.

!!! warning "IP Whitelist"

    Since the server may have restricted external access (all servers in this center have disabled external access), please first inform the administrator of up to 3 commonly used IP addresses to exempt the requirement for internal network login.

    To obtain your public IP address, visit [ip4.me](https://ip4.me){:target="_blank"}.

    Please do not query while using proxies or VPNs. Otherwise, you may either be unable to retrieve the IP or receive the IP of a public data center.

## SSH

To log in, enter the following command in Terminal and then enter your password:

```bash
ssh <username>@<host>
```

??? question "Cursor does not move when entering password"

    In macOS and Linux systems, the cursor does not move when entering a password. If you see the cursor not moving, please ignore it and simply enter your password and press Enter.

??? question "Error message 'Host key verification failed.' when connecting via SSH"

    **Cause**

    You need to reset the `known_hosts` file in your local SSH records.

    **Solution**

    1. First, obtain the IP address of the target server, such as 123.123.123.123 (can be found using the `ifconfig` command).
    2. Execute the command `ssh-keygen -R 123.123.123.123`.

    Reference:

    - [https://blog.csdn.net/wd2014610/article/details/85639741](https://blog.csdn.net/wd2014610/article/details/85639741)

??? question "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

    If you encounter this error message, it means that the key of the remote server has been modified (e.g., the system has been reinstalled or the key has been regenerated). In this case, you need to delete the public key of the server from your system's `known_hosts` file.

## SFTP

It is recommended to use FileZilla. Configuration can be referred to in the [SFTP section for Windows](win.md#sftp). FileZilla does not specify the port number by default, so please enter 22 as the port number.

## Port Forwarding

!!! warning "Why is port forwarding necessary?"

    This setting is crucial for using Jupyter Lab. Please complete this step before configuring Jupyter Lab. Please request a port number from the administrator, which can be any number between 10000 and 65535. **Here, we will use port 22222 as an example.**

    Since I do not have a Mac machine, the port forwarding section has not been tested. Some users have reported that it does not work correctly. If you cannot configure it successfully, you can skip this step and use the VSCode version of Jupyter directly.

If you need to use Jupyter Lab, use the following command when connecting to the server:

```bash
ssh -L 22222:127.0.0.1:22222 <username>@<host>
```