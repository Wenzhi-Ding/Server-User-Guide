推荐使用JupyterLab在服务器上直接编写和运行代码。

!!! 端口转发
	
	在配置Jupyter Lab之前，请务必确保已按照第一节“连接服务器”中配置了端口侦听（[Windows](/01-connect/win/#_1)、[macOS](/01-connect/mac/#_1)）。

!!! Conda

	若您没有配置环境的经验，请先[安装Conda](/02-conda/install)。

1、在Conda环境中安装Jupyter Lab。

```bash
conda install jupyterlab
```

2、检查安装情况。若能正常返回版本号，则表明安装成功。

```bash
jupyter lab --version
```

<figure><img src="/assets/jupyter-version.png"></figure>

3、创建Jupyter Lab配置文件。注意返回的提示，指明了配置文件存放的位置。

```bash
jupyter lab --generate-config
```

<figure><img src="/assets/jupyter-config-path.png"></figure>

??? question "找不到配置文件"

	**原因1**
	
	没有看文件路径。
	
	**解决方案**
	
	请看客户端中提示的路径。
	
	**原因2**
	
	Xftp没有显示隐藏文件。
	
	**解决方案**
	
	参考[该页面](/01-connect/win/#sftp)关于Xftp的设置。

4、使用SFTP客户端将配置文件下载到自己的计算机进行编辑

<figure><img src="/assets/jupyter-config.png"></figure>

5、搜索以下配置项，取消注释，并改为指定的值。**注意三项设定都必须完成。**

=== "不打开浏览器"
	
	启动Jupyter Lab后不打开浏览器（否则会在服务器端打开浏览器）。
	
	搜索：
	
	```python
	c.ExtensionApp.open_browser
	```
	
	并设为`False`。
	
	<figure><img src="/assets/jupyter-browser.png"></figure>

=== "固定端口"

	在指定的端口启动Jupyter Lab。端口号请向管理员申请，可以在20000-49999之间选择任意数字。此处以22222端口为例。
	
	搜索：
	
	```python
	c.ServerApp.port
	```
	
	并设为分配的端口号。
	
	<figure><img src="/assets/jupyter-port.png"></figure>

=== "设定密码"

	在服务器中启动Python。
	
	```bash
	python
	```
	
	输入以下命令生成密码的加密字符串。
	
	```python
	from jupyter_server.auth import passwd; passwd()
	```
	
	复制`sha1:`或`argon2:`开头的字符串。
	
	<figure><img src="/assets/jupyter-gen-passwd.png"></figure>
	
	??? question "输入密码时光标不动"
	
	    在macOS和Linux系统中，输入密码时不会提示你已输入多少位。若看到光标不动请不要理会，只需要正常输入完密码并按回车即可。
	
	在配置文件中搜索：
	
	```python
	c.ServerApp.password
	```
	
	并设为`sha1:`或`argon2:`开头的字符串。
	
	<figure><img src="/assets/jupyter-set-passwd.png"></figure>
	
	退出Python。
	
	```python
	exit()
	```

=== "展示多个输出"

	在命令行输入`ipython profile create`，得到ipython配置文件的位置。通常该位置是`~/.ipython/profile_default/ipython_config.py`
	
	打开该`ipython_config.py`文件，找到`ast_node_interactivity`，取消其注释状态，并将默认的`"last_expr"`设置为`"all"`。
	
	此处的目的是使得你的Jupyter Lab能够在一个单元格中输出多个结果。


6、通过SFTP将修改好的配置文件传输回服务器上的原位置，替换原本的配置文件。