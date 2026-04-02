本页面用于记录服务器管理常用的操作

## 用户管理

创建用户

```bash
sudo adduser <username>
```

删除用户（及其Home目录）

```bash
sudo userdel -r <username>
```

修改某用户的密码

```bash
sudo passwd <username>
```

## 群组管理

新建群组

```bash
sudo addgroup <groupname>
```

删除群组

```bash
sudo groupdel <groupname>
```

将用户添加至群组

```bash
sudo usermod -aG <groupname> <username>
```

将用户移除出群组

```bash
sudo deluser <username> <groupname>
```

浏览群组下的用户

```bash
sudo getent group <groupname>
```

浏览用户所在的所有群组

```bash
sudo groups <username>
```

## 权限管理

Linux 服务器中权限管理的基本思路是对每个路径都分别规定用户（Owner）、群组（Group）和其他用户（Other）的权限。权限的内容包括读取（Read）、写入（Write）、执行（Execute）。

### 基本权限管理

更改文件所属用户

```bash
sudo chown -R <username> <dir>
```

`-R`参数表示对目录下所有文件执行操作，不指定该参数则仅对文件本身操作。

更改文件所属群组

```bash
sudo chgrp -R <groupname> <dir>
```

同时更改文件所属用户和群组

```bash
sudo chown -R <username>:<groupname> <dir>
```

设定目录下所有文件权限

```bash
sudo chmod -R <mode> <dir>
```

权限代码为3位数：

- 第一位：文件所属用户的权限
- 第二位：文件所属群组的权限
- 第三位：其他用户的权限

每一位数是三个二进制数的累加：

- 读取：4
- 写入：2
- 执行：1

以下通过几个示例来解释这套系统：

- 文件可被所有用户读取和写入，但不允许执行：`mode=666`
- 文件所属用户可以的读取、写入、执行，所属群组可以读取，其他人不允许任何操作：`mode=740`
- 文件所属用户可以的读取、写入、执行，其他所有人可以读取和执行：`mode=755`

### 设定路径下新文件的默认权限

设置权限继承

```bash
chmod g+s <path-to-parent-directory>
```

设置默认权限

```bash
setfacl -d -m g::rwx <path-to-parent-directory>
```

`-d` 表示默认权限，`-m` 表示修改，`u` 表示用户，`g` 表示群组，`o` 表示其他用户。`rwx` 分别表示读取、写入和执行权限。

本命令的作用就是设置该路径下的新文件的默认权限。`g::rwx` 表示新文件都跟上级目录的群组一样，且该群组对新文件拥有全部三种权限。

查看权限设置

```bash
getfacl <directory>
```

## 存储管理

检查文件夹占用大小

```bash
du -h --max-depth=1 <folder>
```

## 缓存管理

增加一个Swap分区

```bash
sudo fallocate -l 64G /swap.new
sudo chmod 600 /swap.new
sudo mkswap /swap.new
sudo swapon /swap.new
sudo vim /etc/fstab  # 增加内容/swap.new none swap defaults 0 0
free -h  # 查看Swap是否生效
swapon -show
```

移除某个Swap分区

```bash
sudo swapoff /swap.old  # 如果Swap使用较高，需要较长时间清理
sudo vim /etc/fstab  # 移除或注释/swap.old对应的那行
sudo rm -f /sawp.old
free -h
swapon -show
```

监控缓存预防宕机，可以用 `crontab` 命令定期运行以下脚本（其中调用的 [py_reminder](https://github.com/Wenzhi-Ding/py_reminder) 是我写的用于便捷发邮件提示的装饰器）。

```python
import os
from datetime import datetime, timedelta
import time

import pandas as pd
from py_reminder import monitor


ROOT = '/home/xxx/'
RESERVERD_USERS = ['root']


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
            if user not in RESERVERD_USERS:
                # print(f'try killing {pid}')
                os.system(f'sudo kill -9 {pid}')
                time.sleep(10)  # Have to wait for swap to be cleared
                break

        swap = check_swap_usage()
```

## 限制用户资源占用

可以通过以下方法限制单个用户可以使用的资源数量：

1. 打开 `/etc/security/limits.conf` 文件
2. 添加一行 `[domain]   hard    [option]    [size]`
3. 保存后将该用户所有会话注销：`sudo pkill -u [user]`

常用的限制选项包括：

- `as`：总共可以使用多少 Kb 的内存
- `nproc`：总共可以使用多少个进程

通常可以考虑将被限制用户加入群组 `limit`，因此限制最大进程数 50 个、最大内存 20G 可以这么写：

```bash
@limit    hard    nproc    50
@limit    hard    as       20480000
```

## 清除“僵尸”进程

有些用户的进程没有妥善的关闭，会长期挂在后台，可能占用大量的内存或缓存。此时可以通过这个脚本清除 7 天前创建的进程：

### 按父进程清除

比如某用户的 Jupyter Lab 下挂了大量长期未用的 Kernel：

```bash
sudo ps -eo pid,ppid,lstart | grep "<parent_pid>" | awk '$1 != "<parent_pid>" && (systime() - mktime(gensub(/ /, "0 ", "g", $3) " " $4 " " $5 " " $6 " " $7) > 60*60*24*7) {print $1}' | xargs sudo kill
```

注意替换命令中的两个 `<parent_pid>` 为需要清理过期进程的父进程（比如 Jupyter Lab）

### 按用户清除

```bash
sudo ps -eo pid,user,lstart | grep "<username>" | awk '$1 != "<username>" && (systime() - mktime(gensub(/ /, "0 ", "g", $4) " " $5 " " $6 " " $7 " " $8) > 60*60*24*7) {print $1}' | xargs sudo kill
```

注意替换命令中的两个 `<username>` 为用户名。

## 多服务器共享存储与算力分配

当团队有多台不同配置的服务器（如有的带 GPU、有的内存大、有的仅 CPU），可以通过 **NFS 共享存储** 让用户只存一份数据，同时能灵活选择不同服务器做运算。

### 核心思路

将所有服务器的 `/home`（用户目录）和 `/data`（公共数据）统一挂载到 NFS 服务器上。这样：

- 用户在任意一台服务器上配置的环境（Conda 环境、VS Code 插件等）会自动同步到所有服务器
- 公共数据只需存储一份，所有服务器都能访问
- 用户通过 VS Code Remote-SSH 自行选择连接哪台服务器来获得对应的算力

### 搭建步骤

#### 1. 部署 NFS 服务器

选一台存储空间充足的服务器作为 NFS Server，安装并配置：

```bash
# 服务端安装
sudo apt install nfs-kernel-server

# 创建共享目录
sudo mkdir -p /nfs/home /nfs/data

# 配置导出（编辑 /etc/exports）
/nfs/home  192.168.1.0/24(rw,sync,no_subtree_check)
/nfs/data  192.168.1.0/24(ro,sync,no_subtree_check)  # 公共数据建议只读
```

`/etc/exports` 中的 `rw` 表示读写，`ro` 表示只读。`192.168.1.0/24` 替换为你的实际内网网段。编辑完成后执行：

```bash
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```

#### 2. 在计算服务器上挂载

在所有计算节点上执行：

```bash
# 客户端安装
sudo apt install nfs-common

# 创建挂载点
sudo mkdir -p /home /data

# 手动挂载测试
sudo mount -t nfs <nfs-server-ip>:/nfs/home /home
sudo mount -t nfs <nfs-server-ip>:/nfs/data /data

# 确认无误后写入 /etc/fstab 实现开机自动挂载
<nfs-server-ip>:/nfs/home  /home  nfs  defaults  0  0
<nfs-server-ip>:/nfs/data  /data  nfs  ro,defaults  0  0
```

#### 3. 统一用户 UID/GID

所有服务器上同一用户的 UID 和 GID 必须一致，否则会出现权限问题。建议用脚本批量创建用户时指定固定 UID：

```bash
# 在所有服务器上执行相同命令，确保 UID 一致
sudo groupadd -g 2001 mygroup
sudo useradd -u 2001 -g 2001 -m -d /home/zhangsan zhangsan
```

或者使用 LDAP（如 `slapd`）统一管理账号，适合用户量较大的场景。

#### 4. 用户使用 VS Code 连接不同服务器

用户在本地的 `~/.ssh/config` 中配置多台服务器：

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

在 VS Code 中点击左下角远程连接，即可像切换频道一样选择不同配置的服务器。由于 `/home` 是共享的，无论连哪台服务器，代码、Conda 环境、VS Code 插件都在。

### 环境管理建议

推荐用户使用 Conda 管理各自的 Python 环境：

```bash
conda create -n myenv python=3.11
conda activate myenv
pip install pandas scikit-learn
```

环境存储在用户的 `~/.conda` 或 `~/miniconda3` 中，因为是共享 `/home`，所以切换服务器后环境自动可用。

!!! warning "注意事项"
    - 所有服务器的 CPU 架构必须一致（同为 x86_64 或同为 ARM），否则编译好的包不能跨机器使用
    - 同一用户应避免同时在两台服务器上运行 VS Code，可能因 `~/.vscode-server` 的文件锁冲突导致异常
    - 如果数据吞吐量要求高（如多台服务器同时读取大数据集），建议 NFS 服务器使用万兆网卡