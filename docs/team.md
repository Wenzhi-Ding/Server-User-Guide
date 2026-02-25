假如你需要和其他人共同完成一个项目，你们可以向管理员申请一个团队名称，如`team_trump`。

管理员会新建一个目录`/home/team_trump`，该目录只有你和你的队友有访问权限。你们可以把项目文件放在该目录下。例如：

```bash
home
  \- team_trump
  	\- 2022_us_election
```

??? question "如果在Jupyter Lab中无法找到该文件夹"

	**原因**
	
	通常你的Jupyter Lab是在自己的根目录下启动的，这种情况下你只能看到你账户根目录下的文件。
	
	**解决方案**
	
	执行以下命令：

    ```bash
    ln -s /home/team_trump/2022_us_election ~/2022_us_election
    ```

    执行完以上命令后，在你账号的根目录下应当已出现项目文件夹，访问后会自动切换至`/home/team_trump/2022_us_election`。

	通过软链接的方式，你可以把项目文件夹的入口创建在任何地方。
	
	```bash
	ln -s [SOURCE] [TARGET]
	```

## 管理员：配置共享目录

此部分供管理员参考。以下步骤配置一个多用户可读写的共享目录，满足以下要求：

- 指定用户组内的成员可以**读写所有文件**
- **新建的文件自动继承权限**，无需手动设置
- **不影响用户在其他目录的默认权限**（不修改 umask）
- 其他用户**无法访问**

### 前置条件

- 拥有 `sudo` 权限
- 已安装 ACL 工具（`getfacl` / `setfacl`）

### 1. 创建共享用户组

```bash
sudo groupadd <组名>
```

将需要共享的用户加入该组：

```bash
sudo usermod -aG <组名> <用户名1>
sudo usermod -aG <组名> <用户名2>
```

!!! note

    用户需要重新登录才能使新组生效。可用 `id <用户名>` 验证。

### 2. 创建共享目录

```bash
sudo mkdir /home/<目录名>
```

### 3. 设置目录所有权和基础权限

```bash
# 设置组为共享组
sudo chgrp -R <组名> /home/<目录名>

# 设置基础权限：owner 和 group 可读写执行，other 无权限
sudo chmod -R 770 /home/<目录名>
```

### 4. 设置 setgid

setgid 确保在此目录下新建的文件/子目录**自动继承父目录的组**，而不是使用创建者的默认组。

```bash
sudo chmod g+s /home/<目录名>
```

### 5. 设置 ACL

ACL 解决两个问题：

1. **现有文件**的组权限设置
2. **新建文件**自动获得正确的组权限（通过 default ACL）

```bash
# 给现有文件和目录添加组读写权限（X 表示仅对目录加执行权限）
sudo setfacl -R -m g:<组名>:rwX /home/<目录名>

# 设置 default ACL，新建的文件/目录自动继承
sudo setfacl -R -d -m g:<组名>:rwX /home/<目录名>

# 确保 other 无法访问（包括新建的文件）
sudo setfacl -m d:o::--- /home/<目录名>
```

!!! tip "为什么不用 umask？"

    `umask` 是用户级别的全局设置，修改后会影响该用户在**所有路径**下创建文件的默认权限。ACL 的 default 规则只作用于**特定目录**，更加精准，不会产生副作用。

### 验证

检查权限：

```bash
getfacl /home/<目录名>/
```

期望输出：

```
# owner: <用户>
# group: <组名>
# flags: -s-          ← s 表示 setgid 已生效
user::rwx
group::rwx
group:<组名>:rwx
mask::rwx
other::---
default:user::rwx
default:group::rwx
default:group:<组名>:rwx
default:mask::rwx
default:other::---       ← other 无权限
```

用不同用户分别测试：

```bash
# 用户A 创建文件
touch /home/<目录名>/test_a.txt
echo "hello" > /home/<目录名>/test_a.txt

# 用户B 编辑该文件
echo "world" >> /home/<目录名>/test_a.txt

# 确认组和权限
ls -la /home/<目录名>/test_a.txt
# 预期：组为 <组名>，组权限为 rw
```

### 常见问题

??? question "新加入组的用户看不到文件？"

    用户需要**重新登录**才能使新组生效。验证：`id <用户名>`。

??? question "新建的文件其他人无法编辑？"

    检查 default ACL 是否正确设置：`getfacl <目录>`，确认有 `default:group:<组名>:rwx`。

??? question "如何新增一个共享用户？"

    只需将其加入组即可，无需重新设置目录权限：

    ```bash
    sudo usermod -aG <组名> <新用户>
    ```

??? question "如何取消某个用户的访问？"

    ```bash
    sudo gpasswd -d <用户名> <组名>
    ```
