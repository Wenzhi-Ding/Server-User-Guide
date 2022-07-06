假设上传的SAS代码文件为`export.sas`。执行以下代码即可直接运行`export.sas`。

```bash
sas export.sas
```

请注意正确设置输入和输出文件的路径。

??? question "提示`command not found`"
	
	**原因**
	
	1. SAS的应用程序尚未加入`PATH`环境变量中。
	2. SAS在本服务器并未安装。
	
	**解决方案**
	
	请联系管理员安装SAS并将执行文件软链接到`/usr/bin`。