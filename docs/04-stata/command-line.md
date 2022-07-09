## 运行DO文件

假设上传的DO文件为`reg.do`。执行以下代码即可直接运行`reg.do`。

```bash
stata-mp reg.do
```

请注意正确设置输入和输出文件的路径。

??? question "`stata-mp`还是`stata`？"

	`stata-mp`对应的是Stata的MP版本（多核版本），具有较快的运行速度（以及较昂贵的价格）。
	
	`stata`对应的是Stata的SE版本（单核版本）。
	
	通常建议默认使用`stata-mp`。

??? question "提示`command not found`"
	
	<figure><img src="/assets/stata-not-found.png"></figure>
	
	**原因**
	
	1. Stata的应用程序尚未加入`PATH`环境变量中。
	2. Stata在本服务器并未安装。
	
	**解决方案**
	
	请联系管理员安装Stata并将执行文件软链接到`/usr/bin`。

## 记录Stata的输出 (LOG)

假定我们希望把Stata运行中的所有输出保存在`/home/user/project/log.smcl`文件，只需要在DO文件的最开始加上以下代码即可。
	
如果希望每次运行都替换原本的记录：
	
```stata
log using "/home/user/project/log.smcl", replace smcl
set linesize 255
```

如果希望每次运行的记录附在原本的记录后面：

```stata
log using "/home/user/project/log.smcl", append smcl
set linesize 255
```

注意，SMCL是Stata专用的记录格式，需要用Stata打开。你也可以用TXT格式输出：

```stata
log using "/home/user/project/log.txt", append txt
set linesize 255
```

## 后台运行Stata

如果不需要在SSH终端中看结果，而只需要让其运行完代码后看记录文件，可以运行：

```bash
stata-mp -b reg.do
```

这种方式建议与上面“记录Stata的输出”结合使用。