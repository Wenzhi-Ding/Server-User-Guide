I'm sorry, but you haven't provided any text for me to translate. Could you please provide the text you would like me to translate into naturalistic English?

This page is used to record commonly used operations for server management.

## User Management

Create a user

```bash
sudo adduser <username>
```

Delete a user (including their home directory)

```bash
sudo userdel -r <username>
```

Change the password for a user

```bash
sudo passwd <username>
```

## Group Management

Create a group

```bash
sudo addgroup <groupname>
```

Delete a group

```bash
sudo groupdel <groupname>
```

Add a user to a group

```bash
sudo usermod -aG <groupname> <username>
```

Remove a user from a group

```bash
sudo deluser <username> <groupname>
```

View the users in a group

```bash
sudo getent group <groupname>
```

View all groups a user belongs to

```bash
sudo groups <username>
```

## Permission Management

The basic idea of permission management in Linux servers is to define the permissions for each path separately for the user (Owner), group (Group), and other users (Other). The permissions include Read, Write, and Execute.

### Basic Permission Management

Change the owner of a file

```bash
sudo chown -R <username> <dir>
```

The `-R` parameter indicates that the operation should be performed on all files in the directory. If not specified, it will only apply to the file itself.

Change the group of a file

```bash
sudo chgrp -R <groupname> <dir>
```

Change both the owner and group of a file

```bash
sudo chown -R <username>:<groupname> <dir>
```

Set permissions for all files in a directory

```bash
sudo chmod -R <mode> <dir>
```

The permission code is a three-digit number:

- The first digit represents the permissions for the owner of the file.
- The second digit represents the permissions for the group of the file.
- The third digit represents the permissions for other users.

Each digit is the sum of three binary numbers:

- Read: 4
- Write: 2
- Execute: 1

Here are a few examples to explain this system:

- The file can be read and written by all users, but not executed: `mode=666`
- The owner of the file can read, write, and execute, the group can read, and others are not allowed any operations: `mode=740`
- The owner of the file can read, write, and execute, and all others can read and execute: `mode=755`

### Setting Default Permissions for New Files in a Directory

Set permission inheritance

```bash
chmod g+s <path-to-parent-directory>
```

Set default permissions

```bash
setfacl -d -m g::rwx <path-to-parent-directory>
```

The `-d` flag indicates default permissions, `-m` indicates modification, `u` indicates user, `g` indicates group, and `o` indicates other users. `rwx` represents read, write, and execute permissions.

This command sets the default permissions for new files in the directory. `g::rwx` means that the new files will have the same group as the parent directory and that group will have all three permissions.

View permission settings

```bash
getfacl <directory>
```

## Storage Management

Check folder size

```bash
du -h --max-depth=1 <folder>
```

## Cache Management

Add a Swap partition

```bash
sudo fallocate -l 64G /swap.new
sudo chmod 600 /swap.new
sudo mkswap /swap.new
sudo swapon /swap.new
sudo vim /etc/fstab  # Add the line "/swap.new none swap defaults 0 0"
free -h  # Check if Swap is enabled
swapon -show
```

Remove a Swap partition

```bash
sudo swapoff /swap.old  # If Swap usage is high, it may take a long time to clear
sudo vim /etc/fstab  # Remove or comment out the line corresponding to /swap.old
sudo rm -f /sawp.old
free -h
swapon -show
```

To prevent server crashes due to cache overflow, you can use the `crontab` command to run the following script regularly (the `py_reminder` module called in the script is a decorator I wrote for convenient email reminders).

```python
import os
from datetime import datetime, timedelta
import time

import pandas as pd
from py_reminder import monitor


ROOT = '/home/xxx/'
RESERVED_USERS = ['root']


@monitor('Monitoring server swap')
def report():
    raise Exception('Server swap approaching limit')
    return None


def check_swap_usage():
    os.system(f'sudo free > {ROOT}log/tmp')
    df = pd.read_fwf(f'{ROOT}log/tmp', sep=' ')
    _, tot, used, *_ = df.iloc[1].values
    swap = used / tot * 100
    return swap


def remove_outdated_log(ndays=30):
    now = datetime.now()
    for f in os.listdir(f'{ROOT}log'):
        f_path = f'{ROOT}log/{f}'
        if os.path.isfile(f_path) and now - datetime.fromtimestamp(os.path.getmtime(f_path)) > timedelta(days=ndays):
            os.remove(f_path)


if __name__ == "__main__":
    remove_outdated_log()

    n = datetime.now().strftime('%Y-%m-%d-%H-%M')

    # Record swap usage into log file
    os.system(f'sudo smem -ap -s swap >> {ROOT}log/{n}-smem')

    # Read in log
    with open(f'{ROOT}log/{n}-smem', 'r') as f:
        log = f.readlines()

    # Check if swap is approaching limit
    swap = check_swap_usage()
    flag = True

    while swap > 90:
        # Only send email once
        if flag:
            report()
            flag = False
        
        # Kill the most consumptive process
        l = len(log)
        for _ in range(l):
            pid, user, *_ = log.pop().split()
            if user not in RESERVED_USERS:
                # print(f'try killing {pid}')
                os.system(f'sudo kill -9 {pid}')
                time.sleep(10)  # Have to wait for swap to be cleared
                break

        swap = check_swap_usage()
```

## Limiting User Resource Usage

You can limit the amount of resources a single user can use by following these steps:

1. Open the `/etc/security/limits.conf` file.
2. Add a line `[domain]   hard    [option]    [size]`.
3. Save the file and log out all sessions for that user: `sudo pkill -u [user]`.

Common options for limiting resources include:

- `as`: Maximum amount of memory in Kb.
- `nproc`: Maximum number of processes.

You can consider adding the limited user to the `limit` group. For example, to limit the maximum number of processes to 50 and the maximum memory to 20G, you can write:

```bash
@limit    hard    nproc    50
@limit    hard    as       20480000
```

## Clearing "Zombie" Processes

Sometimes, processes from certain users are not properly closed and remain running in the background, consuming a large amount of memory or cache. In such cases, you can use the following script to remove processes created more than 7 days ago:

### Clearing by Parent Process

For example, if a user has a large number of long-unused kernels running under Jupyter Lab:

```bash
sudo ps -eo pid,ppid,lstart | grep "<parent_pid>" | awk '$1 != "<parent_pid>" && (systime() - mktime(gensub(/ /, "0 ", "g", $3) " " $4 " " $5 " " $6 " " $7) > 60*60*24*7) {print $1}' | xargs sudo kill
```

Note: Replace `<parent_pid>` in the command with the parent process (e.g., Jupyter Lab) for cleaning up expired processes.

### Clearing by User

```bash
sudo ps -eo pid,user,lstart | grep "<username>" | awk '$1 != "<username>" && (systime() - mktime(gensub(/ /, "0 ", "g", $4) " " $5 " " $6 " " $7 " " $8) > 60*60*24*7) {print $1}' | xargs sudo kill
```

Note: Replace `<username>` in the command with the username for cleaning up expired processes.

## Multi-Server Shared Storage and Compute Allocation

When your team has multiple servers with different configurations (e.g., some with GPUs, some with large memory, some CPU-only), you can use **NFS shared storage** so that users store data only once while being able to run computations on any server.

### Core Idea

Mount `/home` (user directories) and `/data` (shared datasets) from an NFS server on all compute nodes. This way:

- User environments (Conda environments, VS Code extensions, etc.) configured on one server are automatically available on all others
- Shared datasets are stored only once and accessible from every server
- Users choose which server to connect to via VS Code Remote-SSH based on the compute resources they need

### Setup Steps

**1. Deploy the NFS Server**

Choose a server with sufficient storage as the NFS Server:

```bash
# Install on the server
sudo apt install nfs-kernel-server

# Create shared directories
sudo mkdir -p /nfs/home /nfs/data

# Configure exports (edit /etc/exports)
/nfs/home  192.168.1.0/24(rw,sync,no_subtree_check)
/nfs/data  192.168.1.0/24(ro,sync,no_subtree_check)  # Read-only for shared data
```

In `/etc/exports`, `rw` means read-write and `ro` means read-only. Replace `192.168.1.0/24` with your actual network range. After editing, run:

```bash
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```

**2. Mount on Compute Servers**

On all compute nodes:

```bash
# Install NFS client
sudo apt install nfs-common

# Create mount points
sudo mkdir -p /home /data

# Test manual mount
sudo mount -t nfs <nfs-server-ip>:/nfs/home /home
sudo mount -t nfs <nfs-server-ip>:/nfs/data /data

# Once confirmed, add to /etc/fstab for automatic mounting on boot
<nfs-server-ip>:/nfs/home  /home  nfs  defaults  0  0
<nfs-server-ip>:/nfs/data  /data  nfs  ro,defaults  0  0
```

**3. Unify User UIDs/GIDs Across Servers**

The UID and GID for the same user must be identical across all servers, otherwise you will get permission errors. When creating users, specify fixed UIDs:

```bash
# Run the same command on all servers to ensure consistent UIDs
sudo groupadd -g 2001 mygroup
sudo useradd -u 2001 -g 2001 -m -d /home/zhangsan zhangsan
```

For larger teams, consider using LDAP (e.g., `slapd`) for centralized account management.

**4. Connect to Different Servers via VS Code**

Users configure multiple servers in their local `~/.ssh/config`:

```
Host cpu-server
    HostName 192.168.1.10
    User zhangsan

Host gpu-server
    HostName 192.168.1.20
    User zhangsan

Host bigmem-server
    HostName 192.168.1.30
    User zhangsan
```

In VS Code, click the remote connection icon in the bottom-left corner to switch between servers of different configurations. Since `/home` is shared, code, Conda environments, and VS Code extensions are available regardless of which server you connect to.

### Environment Management

Users are recommended to manage their Python environments with Conda:

```bash
conda create -n myenv python=3.11
conda activate myenv
pip install pandas scikit-learn
```

Environments are stored in `~/.conda` or `~/miniconda3`, which lives on the shared `/home`. They are automatically available after switching servers.

!!! warning "Caveats"
    - All servers must share the same CPU architecture (all x86_64 or all ARM), otherwise compiled packages will not work across machines
    - Users should avoid running VS Code on two servers simultaneously, as `~/.vscode-server` file lock conflicts may cause issues
    - If high data throughput is needed (e.g., multiple servers reading large datasets concurrently), consider using a 10GbE NIC on the NFS server