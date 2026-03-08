Recommended to configure the environment in Conda. The following is the installation and usage instructions for Conda.

1、Download the installation package: After logging in to the server, enter the following command.

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

<figure><img src="/assets/conda-download.png"/></figure>

2、Execute the installation package.

```bash
bash Miniconda3-latest-Linux-x86_64.sh
```

3、Keep all default configurations. Select `yes` for `yes/no`, and press Enter for the rest.

4、When the following prompt appears, enter `yes` to automatically activate the Conda environment.

<figure><img src="/assets/conda-activate.png"/></figure>

5、The following prompt indicates that the installation is complete.

<figure><img src="/assets/conda-install-finish.png"/></figure>

6、Activate the Conda environment.

```bash
source ~/.bashrc
```

7、If the command line displays the prefix `(base)`, it indicates that the installation is complete.

<figure><img src="/assets/conda-activated.png"/></figure>

!!! question "Error when activating the Conda environment"

	<figure><img src="/assets/conda-activate-error.png"></figure>
	
	**Reason**
	
	Did not enter `yes` in step 4.
	
	**Solution**
	
	Execute the following command:
	
	```bash
	~/miniconda3/condabin/conda init
	```
	
	<figure><img src="/assets/conda-fix-activate-error.png"></figure>
	
	Then execute steps 6-7.

8、You can check the Python and Conda versions in the existing environment using the following command.

```bash
python --version
conda --version
```

<figure><img src="/assets/conda-version.png"/></figure>

9、（Optional but not recommended）Execute the following steps to set [conda-forge](https://conda-forge.org/) as the main update channel. The advantage is that the packages in conda-forge are usually more up-to-date than the packages in conda, but the disadvantage is that their stability and reliability are not as good as the packages in conda. Version conflicts may occur during future upgrades, which may cause the process to freeze. Please decide for yourself whether to prioritize conda-forge. Not recommended for ordinary users.

```bash
conda config --add channels conda-forge
conda config --set channel_priority strict
