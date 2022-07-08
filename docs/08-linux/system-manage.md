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

`-R`参数表示对目录下所有文件执行操作，不指定该参数则仅对文件本身操作。

更改文件所属用户

```bash
sudo chown -R <username> <dir>
```

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

