此处介绍Linux服务器的基本操作命令。

大多数命令可以通过添加`--help`参数的方式看到详细说明。

```bash
<command> --help
```

## 文件系统

### 文件列表

列出当前路径下所有文件及文件夹

=== "基本信息"

    ```bash
    ls
    ```
    
    <figure><img src="/assets/linux-ls.png"></figure>

=== "详细信息"

    ```bash
    ls -lh
    ```
    
    <figure><img src="/assets/linux-ls-lh.png"></figure>
    
    - 第一列`drw`开头字符串：代表该文件的[权限设置]()（Todo）
    - 第二列`13`：链接数量
    - 第三列`ubuntu`：拥有该文件的用户
    - 第四列`ubuntu`：拥有该文件的用户组
    - 第五列`4.0K`：该文件的大小
    - 第六列`Feb 19 15:35`：最近修改时间
    - 第七列`docs`：文件名

列出指定路径下的所有文件及文件夹

```bash
ls <dir>
```

### 在路径间移动

移动至当前路径下的`docs`文件夹

```bash
cd docs
```

移动至上一层文件夹

```bash
cd ..
```

移动至指定路径

```bash
cd /home/ubuntu/example/docs
```

### 创建文件夹

```bash
mkdir <directory_name>
```

### 复制、移动

复制文件

```bash
cp <source> <destination>
```

复制文件夹

```bash
cp -r <source> <destination>
```

移动文件或文件夹

```bash
mv <source> <destination>
```

### 删除

删除文件

=== "基本"

    ```bash
    rm file.txt
    ```

=== "批量删除"
	
	删除当前路径下所有文件名含`.txt`的文件
	
	```bash
	rm *.txt
	```

删除文件夹

```bash
rm -rf <directory>
```

### 检查硬盘空间占用

=== "检查硬盘挂载"

    ```bash
    df -ah
    ```

=== "检查文件夹占用"

    ```bash
    du -sh <folder>
    ```

## 管理应用程序

### 列出进程

=== "所有进程"

    ```bash
    ps -ajxf
    ```
    
    <figure><img src="/assets/linux-ps-ajxf.png"></figure>
    
    - 第二列`2197748`：PID
    - 最后一列：进程名（以及进程之间的从属关系）

=== "查找指定名字的进程"

	```bash
	ps -ajxf | grep <search>
	```
	
	<figure><img src="/assets/linux-ps-grep.png"></figure>

### 监控资源占用情况

```bash
htop
```

<figure><img src="/assets/linux-htop.png"></figure>

点击各个表头（如`VIRT`、`CPU%`）可以排序查看。

!!! CPU并行

	请不要使用全部的线程，至少保留部分线程给其他用户完成基本的计算任务。非特殊情况请不要使用超过最大线程数的2/3。

!!! 多进程内存占用
	
	在使用多进程时（主要针对Python用户），请注意限制进程数量避免内存溢出。内存溢出可能导致服务器宕机等严重后果。

!!! 待机内存占用

	长时间不使用时，请及时关闭线程以释放内存给其他用户使用。在使用过程中发现内存不足，并有其他用户大量占用的情况，请联系该用户或丁文治协调。
	
	关于检查Swap占用，请参考[该页面](/08-linux/swap)

### 关闭进程

从上方`ps`命令或`htop`命令获得进程号`PID`

=== "杀死进程"
	
	```bash
	kill -9 <PID>
	```

=== "杀死某用户的所有进程"

	```bash
	sudo killall -u <username> -9
	```

## 文本操作

Linux中的配置文件基本以文本的形式存在（哪怕文件后缀名不是`.txt`或根本没有后缀名）。编辑这些文件最简单的方法是通过[SFTP](/01-connect/win/#sftp)下载到本地，编辑完后上传至原位置。

但对于浏览和简单的编辑，可以在SSH终端直接完成。如针对`config.ini`文件：

```bash
vim config.ini
```

Vim的操作与传统的文本编辑不同，可以通过该[教程](https://www.runoob.com/linux/linux-vim.html)学习。