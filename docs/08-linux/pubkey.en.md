Using Public Key (PK) login is not only more convenient than using a password, but also more secure.

!!! warning "Make sure the server allows this method"

	By default, the server does not have PK login enabled. Please contact the administrator to confirm if PK login is allowed on the server.

	Servers that I manage usually allow PK login.

	If you are using cloud services provided by Tencent Cloud, AWS, or other vendors, please refer to their policies and tutorials.

## Setup

You can set up passwordless login using the following steps:

1 Local Steps

First, open the command prompt on your local computer and execute `ssh-keygen`. Just press Enter for all prompts, and pay attention to the location where the key files are stored. Usually, it is:

```bash
C:\Users\[username]/.ssh/id_rsa  # Windows
~/.ssh/id_rsa  # Linux or MacOS
```

Find the `id_rsa.pub` file in the corresponding directory, open it with a text editor, and copy the entire content (public key).

2 Server Steps

Create an `authorized_keys` file in the `~/.ssh` directory on the server. Use a text editor or `vim` to edit the file, and paste the public key copied in the first step.

??? question "No `.ssh` directory"

	This may be because your account has not created the directory yet. The simplest solution is to run the `ssh-keygen` command, and it will automatically create the directory with default settings.

Then, run the following command on the server to ensure the correct permission settings for the relevant paths:

```bash
chmod 700 ~
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

3 Test Connection

At this point, you should be able to connect to the server without entering a password using any SSH tool on your local computer. For example, try the following command in the command prompt:

```bash
ssh [username]@[host]
```

You should be able to log in to the server directly.

??? question "Still need to enter a password"

	You can try running the following command on the server and then retry:

	```bash
	restorecon -v ~/.ssh/authorized_keys
	```

??? question "I need to use a specific private key file to log in"

	In the `~/.ssh/config` file, edit as follows:

	```bash
	Host <host name>
		HostName <host name>
		IdentityFile "<path to private key>"
		User <username>
	```

## Administrator Settings

To allow SSH login with PK:

```bash
sudo vim /etc/ssh/sshd_config
```

Uncomment `PubkeyAuthentication yes`.

Then, restart the SSH service for the changes to take effect:

```bash
sudo systemctl restart ssh
```

To enhance server security, administrators can also disable password login and only allow PK login by setting `PasswordAuthentication` to `no`. In this case, users need to have their public keys added to the corresponding account's `~/.ssh/authorized_keys` file by the administrator whenever they need to add a login device.