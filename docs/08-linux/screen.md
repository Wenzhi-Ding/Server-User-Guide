在SSH终端中启动Jupyter Lab时，一旦出现网络连接波动或者不小心关闭了SSH终端，服务器上的Jupyter Lab就会被关闭，因此代码也随之终止运行。

<figure><img src="/assets/screen-connect-shutdown.png"></figure>

此时需要引入`screen`命令来帮助解决改问题。`screen`命令会在服务器上创建一个独立的桌面，在该桌面中运行的程序不会因为SSH连接的中断而中断。以下为`screen`命令的几个主要使用方法：

- `screen -ls`：查看当前有哪些桌面
- `screen -S xxx`：创建一个名字为xxx的桌面
- `screen -r yyy`：进入名字为yyy的桌面
- Ctrl + A + D：退出当前桌面，回到SSH连接的主界面
- `kill 37821`：假设某个桌面对应的进程号是37821，通过该命令可以强行关闭该桌面

## 执行

具体的执行步骤如下：

1、首先检查当前账号下已经挂载了哪些桌面

```bash
screen -ls
```

<figure><img src="/assets/screen-ls.png"></figure>

如图，我的账号下已有两个桌面：jekyll（进程号为2197748）和nb（进程号为3035702）

2、进入桌面。

**如果没有任何一个桌面是专门用来运行Jupyter Lab的**，则新建一个桌面。通常可以命名为`nb`（notebook的缩写）。

```bash
screen -S nb
```

**如果有专门用来运行Jupyter Lab的桌面**，通过以下命令进入该桌面

```bash
screen -r nb
```

3、运行该命令后会进入到一个全新的桌面，在该桌面中运行任何程序不会收到网络波动或SSH终端关闭的影响。因此可以如常启动Jupyter Lab。

```bash
jupyter lab
```

4、Jupyter Lab正常启动后，键盘上按Ctrl + A +D退出该桌面，回到原本的SSH界面。

5、此后可以随意关闭SSH终端或切换网络等。重新连上SSH终端后，**不必再回到该桌面**，即可直接通过浏览器访问Jupyter Lab。

6、随后如果希望回到该桌面执行重启Jupyter Lab等操作，可以使用该命令：

```bash
screen -r nb
```

??? question "执行`screen -r nb`失败，未能正常切换到名为`nb`的桌面。"

    <figure><img src="/assets/screen-attach.png"></figure>
    
    **原因**
    
    这往往是因为此前未通过Ctrl + A +D的方式正常退出`nb`桌面，使得该桌面仍为“挂载”状态（Attached）。程序认为该桌面仍被占用，因此我们不能进入。
    
    **解决方法**
    
    先使用Ctrl + A +D确保回到最外层的SSH界面，然后执行`screen -d nb`来解除`nb`桌面的占用状态。之后就可以通过`screen -r nb`正常进入了。
    
    <figure><img src="/assets/screen-detach.png"></figure>