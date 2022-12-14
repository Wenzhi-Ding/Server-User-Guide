服务器通过[SSH](https://en.wikipedia.org/wiki/Secure_Shell)的方式进行命令的交互，通过[SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)的方式进行文件的传输。在不同的操作系统中，对于SSH和SFTP客户端有不同的推荐。

macOS中可以使用Terminal完成SSH连接，使用[FileZilla](https://filezilla-project.org/download.php?platform=osx)完成SFTP连接。

!!! note "IP白名单"

	由于服务器可能设置了禁止外网访问（本中心的服务器已全部禁止外网访问），请首先向管理员申报你至多3个常用的IP地址，以豁免内网登陆的要求。

	公网IP地址获取方式：在百度搜索“IP”即可得到

## SSH

在Terminal中输入如下命令后输入密码即可登入：

```bash
ssh <username>@<host>
```

??? question "输入密码时光标不动"

	在macOS和Linux系统中，输入密码时不会提示你已输入多少位。若看到光标不动请不要理会，只需要正常输入完密码并按回车即可。

??? question "SSH连接时出现错误提示`Host key verification failed.`""

    **原因**
    
    需要重置一下本地SSH记录的`known_hosts`。
    
    **解决方案**
    
    1. 先获取目标服务器的IP地址，如123.123.123.123。（可通过`ifconfig`命令找到）
    2. 执行命令`ssh-keygen -R 123.123.123.123`。
    
    参考：
    
    - https://blog.csdn.net/wd2014610/article/details/85639741

## SFTP

推荐使用[FileZilla](https://filezilla-project.org/download.php?platform=osx)。配置可参考[Windows的SFTP章节](/01-connect/win/#sftp)。FileZilla默认不会指明端口号，请填写端口号为22。

## 端口侦听

!!! note "为什么需要设置端口侦听"

	此部分的设置对使用Jupyter Lab非常关键，请务必先完成此步骤再配置Jupyter Lab。端口号请向管理员申请，可以在10000-65535之间选择任意数字。**此处以22222端口为例。**

如需要使用Jupyter Lab，请在Terminal登陆时使用如下命令

```bash
ssh -L 22222:127.0.0.1:22222 <username>@<host>
```