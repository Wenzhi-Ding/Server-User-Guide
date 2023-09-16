1. Try starting Jupyter Lab. Enter the following command in the server:

```bash
jupyter lab
```

<figure><img src="/assets/jupyter-start.png"></figure>

If a link ending with `/lab` appears, it means that Jupyter Lab is configured successfully.

??? question "Link does not end with `/lab`"

	**Reason**
	
	If the link ends with a string that looks like an encrypted content, it means that Jupyter Lab password is not configured correctly.
	
	**Solution**
	
	Reconfigure the Jupyter Lab password (Step 5 in [Jupyter Lab installation](/03-jupyter/install/)).

2. Open a local browser and visit any of the above URLs.

=== "1. Browser Access"
	
	Enter the Jupyter Lab password that you set earlier.
	
	<figure><img src="/assets/jupyter-enter-passwd.png"></figure>

=== "2. Jupyter Lab Interface"

	<figure><img src="/assets/jupyter-ui.png"></figure>
=== "3. Edit and Run Code"

	<figure><img src="/assets/jupyter-ui2.png"></figure>

!!! Stable Operation

	If there is a network fluctuation or the SSH terminal is accidentally closed (e.g., computer shutdown, sleep), Jupyter Lab will also stop running. After your Jupyter Lab is configured and accessible, **please refer to the [Screen command tutorial](/08-linux/screen/) to run Jupyter Lab in a separate window**.

!!! Automatic Parentheses Pairing

	In the Settings menu, it is recommended to check Auto Close Brackets. This way, when you enter the left half of quotes or parentheses, the system will automatically enter the right half and place your cursor in the middle of the parentheses. It provides a better editing experience.
	
	<figure><img src="/assets/jupyter-auto-close-brackets.png"></figure>

??? question "The port number in the Jupyter Lab link is correct, but the local computer browser shows that it cannot be accessed"

	**Reason**
	
	It is possible that another application is using the same port.
	
	**Solution**
	
	For local port conflicts:
	
	- Simple solution: Restart your computer, connect to the server, and open Jupyter Lab first.
	- Precise solution: Use `netstat -aof | findstr:xxxxx` (Windows) or `lsof -i | grep xxxx` (Linux or MacOS) to find the application that is using the port with the number `xxxxx`. Close that application and you will be able to access Jupyter Lab normally.

??? question "The port xxxxx is already in use"

	**Reason**

	It means that someone else or another application on the server is using the port (known as "server port conflict").
	
	**Solution**
	
	For server port conflicts: First, try closing the Jupyter Lab that you have already opened. If you still see `The port xxxxx is already in use`, it is likely that another user is using that port. You can use `lsof -i | grep xxxx` to find the process ID and user that is using the port. In this case, you need to contact the administrator for coordination.

??? question "Jupyter Lab password is incorrect"

	**Reason**
	
	It is possible that you have forgotten the password.
	
	**Solution**
	
	Repeat Step 5 in the [installation](/03-jupyter/install) process. After setting the password again, restart Jupyter Lab.