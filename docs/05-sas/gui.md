!!! 前置条件

	使用图形界面的SAS需要首先完成X11相关的配置
	
	- [Windows](/08-linux/gui/#windows)
	- [macOS](/08-linux/gui/#macos)

连接SSH终端后，输入以下命令即可访问SAS图形界面。但该界面对网速和网络稳定性要求较高。假如服务器设在香港，则在香港以外的地方不推荐使用此方法，界面刷新会非常缓慢。

```bash
sas
```

<figure><img src="/assets/sas-gui.png"></figure>

??? question "提示`command not found`"
	
	这可能说明该服务器没有安装SAS，或管理员未将SAS执行文件的路径加入PATH中。
	
	通常SAS在Linux系统中的位置为`/usr/local/SASHome/SASFoundation/9.4/sas`。你可以自行检查该文件是否存在。如果存在的话，可以直接运行。
	
	```bash
	/usr/local/SASHome/SASFoundation/9.4/sas
	```
	
	另外，如果该文件存在，但`sas`命令仍提示`command not found`，请提示管理员将SAS的执行文件软连接到`/usr/bin`中。