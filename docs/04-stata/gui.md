!!! 前置条件

	使用图形界面的Stata需要首先完成X11相关的配置
	
	- [Windows](/08-linux/gui/#windows)
	- [macOS](/08-linux/gui/#macos)

连接SSH终端后，输入以下命令即可访问Stata图形界面。但该界面对网速和网络稳定性要求较高。假如服务器设在香港，则在香港以外的地方不推荐使用此方法，界面刷新会非常缓慢。

```bash
xstata-mp
```

<figure><img src="/assets/stata-gui.png"></figure>

??? question "提示`command not found`"

	<figure><img src="/assets/stata-not-found.png"></figure>
	
	**原因**
	
	1. Stata的应用程序尚未加入`PATH`环境变量中。
	2. Stata在本服务器并未安装。
	
	**解决方案**
	
	请联系管理员安装Stata并将执行文件软链接到`/usr/bin`。