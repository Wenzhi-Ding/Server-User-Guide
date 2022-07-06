假设上传的DO文件为`reg.do`。执行以下代码即可直接运行`reg.do`。

```bash
stata-mp reg.do
```

请注意正确设置输入和输出文件的路径。

??? question "提示`command not found`"
	
	<figure><img src="/assets/stata-not-found.png"></figure>
	
	**原因**
	
	1. Stata的应用程序尚未加入`PATH`环境变量中。
	2. Stata在本服务器并未安装。
	
	**解决方案**
	
	请联系管理员安装Stata并将执行文件软链接到`/usr/bin`。