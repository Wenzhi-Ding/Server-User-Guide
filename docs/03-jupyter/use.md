## 启动

1、尝试启动Jupyter Lab。在服务器中输入以下命令

```bash
jupyter lab
```

<figure><img src="/assets/jupyter-start.png"></figure>

若出现结尾是`/lab`的链接，表明Jupyter Lab配置完成。

??? question "链接结尾未出现`/lab`"
	
	**原因**
	
	若链接的结尾有一串形同加密字符串的内容，说明在没有正确配置Jupyter Lab的密码。
	
	**解决方案**
	
	重新[配置Jupyter Lab的密码](/03-jupyter/install/)（第5步）。

2、打开本地浏览器，访问上述任一网址。

=== "1. 浏览器访问"
	
	输入在此前设置的Jupyter Lab密码。
	
	<figure><img src="/assets/jupyter-enter-passwd.png"></figure>

=== "2. Jupyter Lab界面"

	<figure><img src="/assets/jupyter-ui.png"></figure>
=== "3. 编辑及运行代码"

	<figure><img src="/assets/jupyter-ui2.png"></figure>

!!! 稳定运行

	当网络发生波动或SSH终端意外被关闭（比如电脑关机、待机），Jupyter Lab也会终止运行。当您的Jupyter Lab配置完成、可以正常访问后，**请务必参考[Screen命令教程](/08-linux/screen/)将Jupyter Lab挂载于独立的窗口下。**

!!! 自动完成括号配对

	在Settings菜单中，推荐勾选Auto Close Brackets。这样当你输入引号、括号的左半部分时，系统会自动输入右半部分，并把你的光标置于括号中间。编辑体验比较好。
	
	<figure><img src="/assets/jupyter-auto-close-brackets.png"></figure>

??? question "Jupyter Lab链接中的端口号正确，但本地电脑浏览器中显示无法访问"

	**原因**
	
	可能其他应用程序或其他人恰巧占用了该端口。
	
	**解决方案**
	
	如果在SSH终端中，Jupyter Lab显示`The port xxxxx is already in use`，说明是服务器上其他人或应用程序占用了该端口。否则应该是自己电脑上的应用程序占用了该端口。
	
	- 简单方案：重启电脑后首先连接服务器并打开Jupyter Lab
	- 精准方案：通过`netstat -aof | findstr:22222`找出占用了22222端口的应用程序。关闭该应用程序后即可正常访问Jupyter Lab。

??? question "Jupyter Lab密码不正确"

	**原因**
	
	可能是忘记密码了。
	
	**解决方案**
	
	重复[安装](/03-jupyter/install)的第5步。重新设定密码后，重启Jupyter Lab即可。

## 新建

### 笔记本

### 代码文件

### 命令行

## 交互

### 代码

对代码的交互要在单元格内完成，即鼠标在单元格内点击，出现光标时可以对代码进行编辑。

|动作|Windows操作|macOS操作|
|-|-|-|
|运行代码|Ctrl + Enter||
|替换代码|Ctrl + Shift + R||
|查找代码|Ctrl + F||
|撤销代码操作|Ctrl + Z||

### 单元格
对单元格的交互要在单元格外完成，即点选单元格外部。

|动作|Windows操作|macOS操作|
|-|-|-|
|新增单元格|A|A|
|复制单元格|C|C|
|粘贴单元格|V|V|
|删除单元格|D + D|D + D|
|撤销单元格操作|Z|Z|
|改变单元格为代码单元格|I|I|
|改变单元格为笔记单元格|Y|Y|

### 笔记

当单元格被改为笔记单元格，可以使用[Markdown](https://en.wikipedia.org/wiki/Markdown)语言做笔记。具体语法请参照[教程](https://markdown.com.cn/)。

## 内核

### 