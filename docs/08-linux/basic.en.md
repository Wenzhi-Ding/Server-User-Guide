Sure, please provide the text that you would like me to translate.

Here is an introduction to basic commands for operating a Linux server.

Most commands can be viewed with detailed explanations by adding the `--help` parameter.

```bash
<command> --help
```

## File System

### File List

List all files and folders in the current directory.

=== "Basic Information"

    ```bash
    ls
    ```

    <figure><img src="/assets/linux-ls.png"></figure>

=== "Detailed Information"

    ```bash
    ls -lh
    ```

    <figure><img src="/assets/linux-ls-lh.png"></figure>

    - The first column starting with `drw`: represents the [permission settings]() of the file (Todo)
    - The second column `13`: number of links
    - The third column `ubuntu`: user who owns the file
    - The fourth column `ubuntu`: group that owns the file
    - The fifth column `4.0K`: size of the file
    - The sixth column `Feb 19 15:35`: last modified time
    - The seventh column `docs`: file name

List all files and folders in the specified path.

```bash
ls <dir>
```

### Moving between Paths

Move to the `docs` folder in the current path.

```bash
cd docs
```

Move to the parent folder.

```bash
cd ..
```

Move to the specified path.

```bash
cd /home/ubuntu/example/docs
```

### Creating Folders

```bash
mkdir <directory_name>
```

### Copying and Moving

Copy a file.

```bash
cp <source> <destination>
```

Copy a folder.

```bash
cp -r <source> <destination>
```

Move a file or folder.

```bash
mv <source> <destination>
```

### Deleting

Delete a file.

=== "Basic"

    ```bash
    rm file.txt
    ```

=== "Batch Deletion"

    Delete all files in the current path with the `.txt` extension.

    ```bash
    rm *.txt
    ```

Delete a folder.

```bash
rm -rf <directory>
```

### Checking Disk Space Usage

=== "Checking Mounted Disks"

    ```bash
    df -ah
    ```

=== "Checking Folder Usage"

    ```bash
    du -sh <folder>
    ```

## Managing Applications

### Listing Processes

=== "All Processes"

    ```bash
    ps -ajxf
    ```

    <figure><img src="/assets/linux-ps-ajxf.png"></figure>

    - The second column `2197748`: PID
    - The last column: process name (and the relationship between processes)

=== "Finding Processes with a Specific Name"

    ```bash
    ps -ajxf | grep <search>
    ```

    <figure><img src="/assets/linux-ps-grep.png"></figure>

### Monitoring Resource Usage

```bash
htop
```

<figure><img src="/assets/linux-htop.png"></figure>

Clicking on the various headers (such as `VIRT`, `CPU%`) allows you to sort and view them.

!!! CPU Parallelism

    Please do not use all threads, and keep at least some threads available for other users to perform basic computing tasks. Unless necessary, do not use more than 2/3 of the maximum number of threads.

!!! Memory Usage in Multi-Process Applications

    When using multiple processes (mainly for Python users), please limit the number of processes to avoid memory overflow. Memory overflow can lead to server crashes and other serious consequences.

!!! Idle Memory Usage

    When not in use for a long time, please close threads in a timely manner to release memory for other users to use. If you find that there is insufficient memory during use and other users are occupying a large amount of memory, please contact the user or coordinate with WenZhi Ding.

    For checking Swap usage, please refer to [this page](/en/08-linux/swap).

### Terminating Processes

Obtain the process ID (PID) from the `ps` command or the `htop` command above.

=== "Killing a Process"

    ```bash
    kill -9 <PID>
    ```

=== "Killing All Processes of a User"

    ```bash
    sudo killall -u <username> -9
    ```

## Text Operations

Configuration files in Linux are typically in the form of text (even if the file extension is not `.txt` or there is no file extension at all). The easiest way to edit these files is to download them to your local machine via [SFTP](/en/01-connect/win/#sftp), edit them, and then upload them back to their original location.

However, for browsing and simple editing, you can do it directly in the SSH terminal. For example, for the `config.ini` file:

```bash
vim config.ini
```

The operation of Vim is different from traditional text editors. You can learn it from [this tutorial](https://www.runoob.com/linux/linux-vim.html).