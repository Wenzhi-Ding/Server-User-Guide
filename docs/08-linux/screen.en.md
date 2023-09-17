Sure, please provide the text that you would like me to translate.

When starting Jupyter Lab in an SSH terminal, if there is a network connection fluctuation or if the SSH terminal is accidentally closed, the Jupyter Lab on the server will be shut down, and the code will stop running.

<figure><img src="/assets/screen-connect-shutdown.png"></figure>

To solve this problem, the `screen` command can be used. The `screen` command creates a separate desktop on the server, and programs running in this desktop will not be interrupted by SSH connection interruptions. Here are several main usage methods of the `screen` command:

- `screen -ls`: View the current desktops.
- `screen -S xxx`: Create a desktop named xxx.
- `screen -r yyy`: Enter the desktop named yyy.
- Ctrl + A + D: Exit the current desktop and return to the main SSH interface.
- `kill 37821`: Assuming the process ID of a desktop is 37821, this command can forcefully close the desktop.

## Execution

The specific execution steps are as follows:

1) First, check which desktops are already mounted under the current account.

```bash
screen -ls
```

<figure><img src="/assets/screen-ls.png"></figure>

As shown in the image, there are two desktops under my account: jekyll (process ID 2197748) and nb (process ID 3035702).

2) Enter the desktop.

**If there is no desktop specifically used to run Jupyter Lab**, create a new desktop. It is usually named `nb` (abbreviation for notebook).

```bash
screen -S nb
```

**If there is a desktop specifically used to run Jupyter Lab**, enter that desktop using the following command:

```bash
screen -r nb
```

3) After running this command, you will enter a brand new desktop. Any program running in this desktop will not be affected by network fluctuations or the SSH terminal being closed. Therefore, you can start Jupyter Lab as usual.

```bash
jupyter lab
```

4) After Jupyter Lab starts normally, press Ctrl + A + D on the keyboard to exit the desktop and return to the original SSH interface.

5) From now on, you can freely close the SSH terminal or switch networks, etc. After reconnecting to the SSH terminal, **you don't need to return to the desktop**. You can directly access Jupyter Lab through a browser.

6) If you want to return to the desktop to perform operations such as restarting Jupyter Lab, you can use the following command:

```bash
screen -r nb
```

??? question "Failed to execute `screen -r nb`, unable to switch to the desktop named `nb`"

    <figure><img src="/assets/screen-attach.png"></figure>
    
    **Reason**
    
    This is often because the `nb` desktop was not exited properly using Ctrl + A + D before, causing the desktop to still be in the "attached" state. The program thinks that the desktop is still occupied, so we cannot enter it.
    
    **Solution**
    
    First, use Ctrl + A + D to make sure you are back to the outermost SSH interface, then execute `screen -d nb` to release the occupied state of the `nb` desktop. After that, you can enter it normally using `screen -r nb`.
    
    <figure><img src="/assets/screen-detach.png"></figure>

??? question "After mounting Jupyter to run in the background and closing it, it seems that the code does not continue running when returning to Jupyter"

    This is because when Jupyter is closed locally, it no longer renders and updates the webpage. In this case, you can check if Jupyter is still running the code by adding a new cell and running code like `print(1)`. If it doesn't respond immediately, it means that Jupyter is still running the code.

    If you need to monitor the progress of the program, it is recommended to add the output of the running program to a log file (any TXT file will do).