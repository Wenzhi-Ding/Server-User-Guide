使用 Public Key（公钥）登录相比起使用密码登录不仅更方便，且更为安全。

!!! warning "应确认服务器是否允许该方式"
	
	服务器默认是没有开启公钥登录的。请联系管理员确认服务器是否允许公钥登录。
	
	由我管理的服务器通常允许。

	如果使用的是腾讯云、AWS 等厂商提供的云服务，需要参考各个厂商自己的政策及教程。

## 设置

可以通过以下方式设置免密码登录：

1、本地步骤

首先在本地计算机的 cmd 中执行 `ssh-keygen`。所有提示一路回车即可，注意中间提示密钥文件存储的位置，通常是

```bash
C:\Users\[username]/.ssh/id_rsa  # Windows
~/.ssh/id_rsa  # Linux or MacOS
```

在对应目录下找到 `id_rsa.pub` 文件，用记事本打开并复制里面全部内容（公钥）。

2、服务器步骤

在服务器的 `~/.ssh` 目录下创建 `authorized_keys` 文件，并用记事本或 `vim` 编辑，将在第一步中复制的公钥粘贴在该文件中。

??? question "没有 `.ssh` 这个目录"

	这可能是因为你的账号还未创建过该目录。最简单的解决办法是运行 `ssh-keygen` 命令，按照默认设置一路回车下来就会自动创建。

随后在服务器运行以下命令确保相关路径的权限设置正确：

```bash
chmod 700 ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

3、测试连接

此时，在本地用任意 SSH 工具连接服务器都应当不再需要输入密码。如在 cmd 中尝试：

```bash
ssh [username]@[host]
```

应当可以直接登入服务器。

??? question "仍然需要输入密码"

	可以尝试在服务器运行以下命令后重试：
	
	```bash
	restorecon -v ~/.ssh/authorized_keys
	```

??? question "我需要使用指定的私钥文件来登录"

	在 `~\.ssh\config` 文件中，编辑如下

	```bash
	Host <host name>
		HostName <host name>
		IdentityFile "<path to private key>"
		User <username>
	```

??? question "一直提示 Permission denied"

	这可能是由于家目录的权限设置不正确。如果家目录的权限是 777，就无法使用密钥登录该账号。可以改为 755 或更严格的权限。
	

## 管理员设置

允许 SSH 通过公钥登录：

```bash
sudo vim /etc/ssh/sshd_config
```

将 `PubkeyAuthentication yes` 取消注释。

随后重启 SSH 服务即可生效：

```bash
sudo systemctl restart ssh
```

为提高服务器的安全性，管理员亦可以关闭密码登录，仅允许公钥登录，即将 `PasswordAuthentication` 设置为 `no`。然后用户每次需要添加一个登录设备，需通过管理员把公钥加入对应账户的 `~/.ssh/authorized_keys` 中。