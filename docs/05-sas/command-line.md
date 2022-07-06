假设上传的SAS代码文件为`export.sas`。执行以下代码即可直接运行`export.sas`。

```bash
sas export.sas
```

请注意正确设置输入和输出文件的路径。

??? question "提示`command not found`"
	
	这可能说明该服务器没有安装SAS，或管理员未将SAS执行文件的路径加入PATH中。
	
	通常SAS在Linux系统中的位置为`/usr/local/SASHome/SASFoundation/9.4/sas`。你可以自行检查该文件是否存在。如果存在的话，可以直接运行。
	
	```bash
	/usr/local/SASHome/SASFoundation/9.4/sas export.sas
	```
	
	另外，如果该文件存在，但`sas`命令仍提示`command not found`，请提示管理员将SAS的执行文件软连接到`/usr/bin`中。在管理员设置后，应当可以直接使用：
	
	```bash
	sas export.sas
	```