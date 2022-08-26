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

5、搜索以下配置项，取消注释，并改为指定的值。**注意前三项设定都必须完成**，最后一项可选。

!!! note "不打开浏览器"
	
	启动Jupyter Lab后不打开浏览器（否则会在服务器端打开浏览器）。
	
	搜索：
	
	```python
	c.ExtensionApp.open_browser
	```
	
	并设为`False`。
	
	<figure><img src="/assets/jupyter-browser.png"></figure>

!!! note "固定端口"

	在指定的端口启动Jupyter Lab。端口号请向管理员申请，可以在10000-65535之间选择任意数字。此处以22222端口为例。
	
	搜索：
	
	```python
	c.ServerApp.port
	```
	
	并设为分配的端口号。
	
	<figure><img src="/assets/jupyter-port.png"></figure>
	
	??? question "向谁申请端口号？"
		
		仅某些服务器的用户需要向管理员申请端口号。如果服务器用户不多，自行决定一个端口号即可。
		
		因为每个端口只能用于一个进程，这意味着如果你与其他人使用同一个端口的话，他将有可能看到并操作你的Jupyter Lab。因此仍然建议选择端口号后向该服务器的管理员报备，避免端口冲突。
		
		如果发现该端口经常不可用，可能是因为跟其他用户的端口冲突了，可以考虑更换一个端口。

!!! note "设定密码"

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

!!! note "设定Token"
	
	此设定为可选项，并非必需。主要是用于VSCode免密码验证使用Jupyter Lab。
	
	在配置文件中搜索`c.ServerApp.token`，取消注释，并将其值设为一个指定的字符串，比如`foobar`。
	
	此后重新启动Jupyter Lab，你会发现系统提示的URI已经变为了`http://localhost:22222/lab?token=foobar`。使用这个含Token的URI可以免密码登录Jupyter Lab。
	
	但必须强调的是，这一方式的安全性相较密码登录是有所下降的。
	
??? question "启动后提示`IndentationError: unexpected indent`"

	**原因**
	
	这是因为`jupyter_lab_config.py`文件中有不正确的缩进，通常是由于取消注释时未将空格一同删掉。
	
	**解决方案**
	
	修复`jupyter_lab_config.py`中的缩进问题即可。


6、通过SFTP将修改好的配置文件传输回服务器上的原位置，替换原本的配置文件。

7、（可选）iPython设置。在命令行输入`ipython profile create`，得到ipython配置文件的位置。通常该位置是`~/.ipython/profile_default/ipython_config.py`。打开该文件，找到以下配置项，推荐按如下设置。

!!! note "展示多个输出"
    
    ```python
    c.InteractiveShell.ast_node_interactivity = 'all'
    ```
    
    此处的目的是使得你的Jupyter Lab能够在一个单元格中输出多个结果。

!!! note "启动默认执行"

    ```python
    c.InteractiveShellApp.exec_lines = [
            "import pandas as pd",
            "import numpy as np",
            "import matplotlib.pyplot as plt",
            "pd.set_option('display.max_columns', 500)",
            "pd.set_option('display.max_rows', 100)",
            ]
    ```
    
    此处使得每次打开一个新的笔记本，都会自动导入pandas和numpy，以及调整pandas表格的可显示范围。
    
    你可以在此处加入其他懒得每次都写的代码。