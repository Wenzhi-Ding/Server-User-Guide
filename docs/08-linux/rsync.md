偶尔我们会有在服务器间同步数据的需求，比如：

- 在两台本中心的服务器间同步数据
- 从WRDS等数据提供商处下载数据

目前推荐使用[SFTP](/01-connect/win/#sftp)和`rsync`命令来完成该工作。

??? question "`rsync`与其他传输方式比的好处？"

	`rsync -avz`命令可以自动比较文件的修改日期，跳过那些没有修改的文件，避免了每次都全量更新对时间和带宽的浪费。此外还会自动将文件“压缩——传输——解压缩”，大幅提高同步的速度。

以从WRDS上下载SDC New Issues数据为例。具体过程如下：

1、首先通过SFTP登录到数据来源服务器（`source`），确定数据的路径。

<figure><img src="/assets/rsync-sftp.png"></figure>

拷贝下该数据路径

```bash
/wrdslin/tfn/sasdata/sdc_ni
```

2、设定好本地用来接收这些数据的路径，如`/data/dataset/sdc`

3、通过以下命令同步

```bash
rsync -avz <username>@<remote_host>:/wrdslin/tfn/sasdata/sdc_ni/* /data/dataset/sdc
```

一般来说，执行该命令后会提示输入密码。正常输入`<remote_host>`的登录密码即可。

??? question "输入密码时光标不动"

	在macOS和Linux系统中，输入密码时不会提示你已输入多少位。若看到光标不动请不要理会，只需要正常输入完密码并按回车即可。

4、可以通过SSH界面或SFTP查看下载进程。

