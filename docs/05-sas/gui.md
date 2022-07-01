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
	
	**原因**
	
	SAS在本服务器并未安装。
	
	**解决方案**
	
	请联系管理员安排安装了SAS的服务器的账号。