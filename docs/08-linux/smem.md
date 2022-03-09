经常有服务器用户会将某些早已不再使用的进程挂在后台，如Jupyter Lab的某些内核。除了占用内存外，也常常占用大量的缓存。此页面指导用户如何查看进程占用了多少内存和缓存，用以及时关闭浪费系统资源的进程。

# 查看Swap占用

## 普通用户

```bash
smem -p -s swap
```

??? question "`smem`命令报错"

	**原因**
	
	可能由于你在Conda（或其他）虚拟环境下，`smem`不能正确调用到所依赖的特定版本的Python
	
	**解决方案**
	
	以Conda为例，执行以下命令1~2次退出Conda环境：
	
	```bash
	conda deactivate
	```
	
	随后便可使用`smem`命令查看内存和缓存占用了。
	

<figure><img src="/assets/linux-smem.png"></figure>

图中各列的含义：

- PID：进程的ID，决定杀掉某进程时需要用（[关闭进程的教程](/08-linux/basic/#_10)）
- User：该进程归属的用户
- Command：该进程由什么命令触发
- **Swap：缓存占用**
- **USS：内存占用**（进程独自占用的物理内存 Unique Set Size，内存管理主要参考这个指标）
- PSS及RSS：内存占用的不同计算方式

查看自己的Swap及内存总占用

```bash
smem -p -s swap -u
```

## 系统管理员

对于系统管理工作，往往还需要用到以下命令：

查看所有用户、所有进程的Swap及内存占用

```bash
sudo smem -p -s swap
```

查看每个用户的Swap及内存总占用

```bash
sudo smem -p -s swap -u
```

查看某个用户所有进程的Swap及内存占用

```bash
sudo smem -p -s swap -U <username>
```

# 调整Swap

此部分仅供运维人员参考，普通用户请不要尝试（也没有权限）自行调整Swap。

参考[Swap空间占用过高解决方案](https://www.jianshu.com/p/dbc27148f58c)。