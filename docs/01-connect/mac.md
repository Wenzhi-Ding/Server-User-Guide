服务器通过 [SSH](https://en.wikipedia.org/wiki/Secure_Shell) 方式进行命令的交互，通过 [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol) 的方式进行文件的传输。在不同的操作系统中，对于 SSH 和 SFTP 客户端有不同的推荐。

macOS中可以使用 Terminal 完成 SSH 连接，使用 [FileZilla](https://filezilla-project.org/download.php?platform=osx) 完成 SFTP 连接。

!!! warning  "IP 白名单"

	由于服务器可能设置了禁止外网访问（本中心的服务器已全部禁止外网访问），请首先向管理员申报你至多 3 个常用的 IP 地址，以豁免内网登陆的要求。

	公网 IP 地址获取方式：访问 [ip4.me](https://ip4.me){:target="_blank"}

    请不要在挂代理、VPN 的情况下查询。否则要么无法查到 IP，要么会返回公共机房的 IP。

    部分团队可以使用[跳板服务器](/08-linux/jump-proxy)绕开限制，详情咨询本团队 IT 负责人。

## SSH

在 Terminal 中输入如下命令后输入密码即可登入：

```bash
ssh <username>@<host>
```

??? question "输入密码时光标不动"

	在 macOS 和 Linux 系统中，输入密码时不会提示你已输入多少位。若看到光标不动请不要理会，只需要正常输入完密码并按回车即可。

??? question "SSH 连接时出现错误提示 `Host key verification failed.`""

    **原因**
    
    需要重置一下本地 SSH 记录的 `known_hosts`。
    
    **解决方案**
    
    1. 先获取目标服务器的 IP 地址，如 123.123.123.123。（可通过 `ifconfig` 命令找到）
    2. 执行命令 `ssh-keygen -R 123.123.123.123`。
    
    参考：
    
    - https://blog.csdn.net/wd2014610/article/details/85639741

??? question "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

	出现该错误提示表示远程服务器的密钥修改过了（比如重装了系统、重新生成了密钥等）。此时需要将自己系统的 `known_hosts` 文件中该服务器的公钥删除。
    
## SFTP

推荐使用 [FileZilla](https://filezilla-project.org/download.php?platform=osx)。配置可参考 [Windows 的 SFTP 章节](/01-connect/win/#sftp)。FileZilla 默认不会指明端口号，请填写端口号为 22。

## 端口侦听

!!! warning "为什么需要设置端口侦听"

	此部分的设置对使用 Jupyter Lab 非常关键，请务必先完成此步骤再配置 Jupyter Lab。端口号请向管理员申请，可以在 10000-65535 之间选择任意数字。**此处以 22222 端口为例。**

    由于我没有 Mac 机器，端口侦听这部分未经测试。有用户反馈不能正确实现功能。如果不能配置成功可以跳过该步骤，直接使用 VSCode 版本的 Jupyter。

如需要使用 Jupyter Lab，请在连接服务器时使用如下命令

```bash
ssh -L 22222:127.0.0.1:22222 <username>@<host>
```