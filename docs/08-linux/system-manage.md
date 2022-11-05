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
chmod g+s <directory>
```

设置默认权限

```bash
setfacl -d -m g::rwx <directory>
```

`-d` 表示默认权限，`-m` 表示修改，`g` 表示群组，`o` 表示其他用户。

查看权限设置

```bash
getfacl <directory>
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