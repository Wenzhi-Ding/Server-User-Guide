!!! Prerequisites

	To use the SAS graphical interface, you need to first configure X11.

	- [Windows](/en/08-linux/gui/#windows)
	- [macOS](/en/08-linux/gui/#macos)

After connecting to the SSH terminal, you can access the SAS graphical interface by entering the following command. However, please note that this interface requires a high internet speed and network stability. If the server is located in Hong Kong, it is not recommended to use this method outside of Hong Kong as the interface refresh will be very slow.

```bash
sas
```

<figure><img src="/assets/sas-gui.png"></figure>

??? question "Getting `command not found` error"
	
	**Reason**
	
	1. The SAS application has not been added to the `PATH` environment variable.
	2. SAS is not installed on this server.
	
	**Solution**
	
	Please contact the administrator to install SAS and create a symbolic link to the executable file in `/usr/bin`.