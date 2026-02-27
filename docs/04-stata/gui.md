!!! 前置条件

	使用图形界面的Stata需要首先完成X11相关的配置
	
	- [Windows](../08-linux/gui.md#windows)
	- [macOS](../08-linux/gui.md#macos)

连接SSH终端后，输入以下命令即可访问Stata图形界面。但该界面对网速和网络稳定性要求较高。假如服务器设在香港，则在香港以外的地方不推荐使用此方法，界面刷新会非常缓慢。

```bash
xstata-mp
```

<figure><img src="/assets/stata-gui.png"></figure>

??? question "`xstata-mp`还是`xstata`？"

	`xstata-mp`对应的是Stata的MP版本（多核版本），具有较快的运行速度（以及较昂贵的价格）。
	
	`xstata`对应的是Stata的SE版本（单核版本）。
	
	通常建议默认使用`xstata-mp`。
	
??? question "提示`command not found`"

	<figure><img src="/assets/stata-not-found.png"></figure>
	
	**原因**
	
	1. Stata的应用程序尚未加入`PATH`环境变量中。
	2. Stata在本服务器并未安装。
	
	**解决方案**
	
	请联系管理员安装Stata并将执行文件软链接到`/usr/bin`。