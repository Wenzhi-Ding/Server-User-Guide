使用Public Key登录相比起使用密码登录不仅更方便，且更为安全。可以通过以下方式设置免密码登录：

1、本地步骤

首先在本地计算机的cmd中执行`ssh-keygen`。所有提示一路回车即可，注意中间提示密钥文件存储的位置，通常是

```bash
C:\Users\[username]/.ssh/id_rsa  # Windows
~/.ssh/id_rsa  # Linux or MacOS
```

在对应目录下找到`id_rsa.pub`文件，用记事本打开并复制里面全部内容（公钥）。

2、服务器步骤

在服务器的`~/.ssh`目录下创建`authorized_keys`文件，并用记事本或`vim`编辑，将在第一步中复制的公钥粘贴在该文件中。

随后在服务器运行以下命令确保相关路径的权限设置正确：

```bash
chmod 700 ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

3、测试连接

此时，在本地用任意SSH工具连接服务器都应当不再需要输入密码。如在cmd中尝试：

```bash
ssh [username]@[host]
```

应当可以直接登入服务器。

??? question "仍然需要输入密码"

	可以尝试在服务器运行以下命令后重试：
	
	```bash
	restorecon -v ~/.ssh/authorized_keys
	```