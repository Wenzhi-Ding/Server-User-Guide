假如你需要和其他人共同完成一个项目，你们可以向管理员申请一个团队名称，如`team_trump`。

管理员会新建一个目录`/home/team_trump`，该目录只有你和你的队友有访问权限。你们可以把项目文件放在该目录下。例如：

```bash
home
  \- team_trump
  	\- 2022_us_election
```

更改路径下所有文件的组别归属和权限：

```bash
sudo chgrp -R team_trump team_trump
sudo chmod -R 770 team_trump
```

此外，管理员需要设定该路径的默认权限模式：

```bash
sudo chmod g+s team_trump
```

??? question "如果在Jupyter Lab中无法找到该文件夹"

	**原因**
	
	通常你的Jupyter Lab是在自己的根目录下启动的，这种情况下你只能看到你账户根目录下的文件。
	
	**解决方案**
	
	执行以下命令：

    ```bash
    ln -s /home/team_trump/2022_us_election ~/2022_us_election
    ```

    执行完以上命令后，在你账号的根目录下应当已出现项目文件夹，访问后会自动切换至`/home/team_trump/2022_us_election`。

	通过软链接的方式，你可以把项目文件夹的入口创建在任何地方。
	
	```bash
	ln -s [SOURCE] [TARGET]
	```