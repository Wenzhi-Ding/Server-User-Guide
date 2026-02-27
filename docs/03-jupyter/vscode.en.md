You are encouraged to use Jupyter with VSCode instead of its original interface.

The advantage of the VSCode version is that you can use the rich plugins available in VSCode, such as [variable explorer and data viewer](https://code.visualstudio.com/docs/datascience/jupyter-notebooks#_variable-explorer-and-data-viewer), code splitting (which are drawbacks of the web version), auto-completion, quick navigation, code correction, displaying function parameter documentation, custom themes, and interactive Git version control (e.g., [PyLance](https://github.com/microsoft/pylance-release), [GitHub Copilot](https://github.com/features/copilot), [GitHub Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme)).


1) Install VSCode locally and install the RemoteSSH plugin. The specific process can be found in the [official tutorial](https://code.visualstudio.com/docs/remote/ssh).

2) After setting up [SSH passwordless login](../08-linux/pubkey.md), add the following content to the local SSH configuration file.

The location of the local SSH configuration file is usually (and can be opened and edited using VSCode or Notepad) (`C:\Users\[local_username]\.ssh\config`) and can be opened and edited using VSCode or Notepad.

```bash
"C:\Users\[local_username]\.ssh\config"
```

This allows SSH to use the local private key for login, eliminating the need to enter the password manually.

```bash
Host [host]
  HostName [host]
  User [username]
  IdentityFile "C:\Users\[local_username]\.ssh\id_rsa"
```

3) After logging into the server in VSCode, add the project folder in the VSCode file explorer and click on the `ipynb` file to open Jupyter Lab.

4) Set Jupyter Lab to use a [fixed token for login](install.md#set-token).

Start Jupyter Lab and copy the URI containing the token `http://localhost:22222/lab?token=foobar` (note that it should be displayed as `http://localhost:22222/lab?token=...` in the SSH terminal, and you need to fill in the token you set in the URI).

Enter this URI in the "Jupyter Server" in the bottom right corner of VSCode to avoid entering the Jupyter Lab password every time.

??? question "Why does it show missing components even though the environment on the server is configured?"

	**Reason**
	
	It may be because you haven't selected the kernel on the server side, so VSCode defaults to using the Jupyter Kernel on your local machine.
	
	**Solution**
	
	In the kernel settings in the top right corner of VSCode, select the IPython kernel on the server side. You can determine if it is a server-side kernel by the path of the kernel, the word "Remote," or the virtual environment name.
	
	<figure><img src="/assets/jupyter-vscode-kernel-select.png"></figure>

5) You can refer to the [official tutorial](https://code.visualstudio.com/docs/datascience/jupyter-notebooks) for how to use Jupyter Lab in VSCode.

??? question "How to resume the kernel and continue working after the SSH connection is interrupted?"

	First, make sure you have run Jupyter Lab using [this method](../08-linux/screen.md).
	
	In the kernel selection in the top right corner, select the previous kernel of this notebook.
	
	<figure><img src="/assets/jupyter-vscode-restore-kernel.png"></figure>

!!! note "Kernel management in VSCode version"

	Currently, the VSCode version does not support closing the kernel like the web version. Therefore, it is recommended to regularly clean up the kernels consciously, otherwise there may be too many kernels running in the background.
	
	The easiest way is to restart Jupyter Lab regularly. Another method is to open the web version, clean up the kernels there, and then return to the VSCode version to work.
	
	P.S.: If I am responsible for maintaining those servers, there will be scripts to automatically detect and prompt you to close processes that consume too much memory or have high cache usage.

??? question "How to find and replace within a cell in the VSCode version?"

	In the VSCode version of Jupyter, you cannot use the web version's `Ctrl+Shift+R` to find and replace within a cell. Instead, you can use the `F3` key.

	If you need to find and replace throughout the entire notebook, you can use `Ctrl+F` and `Ctrl+H` as usual.