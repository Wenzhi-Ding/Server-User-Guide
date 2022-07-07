## Windows

在Windows中如果希望以图形界面的方式使用服务器上的某些程序（如Stata、SAS），可以通过两个方案解决。

### Xmanager

安装与Xshell配套的[Xmanager](https://www.netsarang.com)后，在Xshell中使用相关命令，即可自动调出图形界面。

由于Xmanager没有官方免费版本提供，如需使用请自行考虑在官网购买正版或看看万能的某宝。

### Xming

[Xming](https://en.wikipedia.org/wiki/Xming)需要与PuTTY搭配使用。

1、在此处[下载Xming客户端](https://sourceforge.net/projects/xming/)并安装。

2、启动Xming。

3、在PuTTY中连接服务器时，为SSH命令增加`-X`参数，即：

```bash
ssh -X <username>@<host>
```

4、使用相关命令，将通过Xming调出图形界面。

??? question "图形界面报错，未能正常启动"

	**原因**
	
	可能是由于端口占用混乱。
	
	**解决方案**
	
	彻底退出所有PuTTY和Xming，并重新启动。

## macOS

macOS中，需要[XQuartz](https://en.wikipedia.org/wiki/XQuartz)搭配Terminal使用。

1、在此处[下载XQuartz客户端](https://www.xquartz.org/)并安装。

2、启动XQuartz。

3、在Terminal中连接服务器时，为SSH命令增加`-X`参数，即：

```bash
ssh -X <username>@<host>
```

4、使用相关命令，将通过XQuartz调出图形界面。

??? question "图形界面报错，未能正常启动"

	**原因**
	
	可能是由于端口占用混乱。
	
	**解决方案**
	
	彻底退出所有Terminal和XQuartz，并重新启动。