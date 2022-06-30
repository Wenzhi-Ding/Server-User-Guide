推荐在Conda下配置环境。以下为Conda的安装和使用说明。

1、下载安装包：登入服务器后，输入以下命令。

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

<figure><img src="/assets/conda-download.png"/></figure>

2、执行安装包。

```bash
bash Miniconda3-latest-Linux-x86_64.sh
```

3、全部保持默认配置即可。`yes/no`选yes，其余一路按回车。

4、出现以下提示时，请输入yes，以自动激活Conda环境。

<figure><img src="/assets/conda-activate.png"/></figure>

5、出现以下提示表示安装已完成。

<figure><img src="/assets/conda-install-finish.png"/></figure>

6、激活Conda环境。

```bash
source ~/.bashrc
```

7、若命令行出现`(base)`前缀，则表示安装已完成。

<figure><img src="/assets/conda-activated.png"/></figure>

??? question "激活Conda环境时报错"

	<figure><img src="/assets/conda-activate-error.png"></figure>
	
	**原因**
	
	在第4步时没有输入`yes`。
	
	**解决方案**
	
	执行以下命令：
	
	```bash
	~/miniconda3/condabin/conda init
	```
	
	<figure><img src="/assets/conda-fix-activate-error.png"></figure>
	
	此后再执行6-7步即可。

8、通过以下命令可以检查现有环境中的Python和Conda版本。

```bash
python --version
conda --version
```

<figure><img src="/assets/conda-version.png"/></figure>

9、（可选）执行以下步骤将[conda-forge](https://conda-forge.org/)设为主要的更新渠道。好处是通常conda-forge的包比conda的包更新的及时很多，但缺点是稳定性和可靠性不如conda的包。请自行决定是否设置conda-forge优先。

```bash
conda config --add channels conda-forge
conda config --set channel_priority strict
```