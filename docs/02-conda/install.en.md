I recommend setting up the environment using Conda. Here are the installation and usage instructions for Conda.

1) Download the installation package by logging into the server and entering the following command:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

<figure><img src="/assets/conda-download.png"/></figure>

2) Execute the installation package by running the following command:

```bash
bash Miniconda3-latest-Linux-x86_64.sh
```

3) Keep all the default configurations. When prompted with "yes/no," choose "yes" and press enter for the rest of the prompts.

4) When prompted with the message to activate Conda environment, enter "yes" to activate it automatically.

<figure><img src="/assets/conda-activate.png"/></figure>

5) Once the installation is complete, you will see the following message:

<figure><img src="/assets/conda-install-finish.png"/></figure>

6) Activate the Conda environment by running the following command:

```bash
source ~/.bashrc
```

7) If the command line shows `(base)` prefix, it means the installation is complete.

<figure><img src="/assets/conda-activated.png"/></figure>

??? if you encounter an error while activating the Conda environment follow these steps

	<figure><img src="/assets/conda-activate-error.png"></figure>
	
	**reason**
	
	No input (`yes`) was made in step 4
	
	**solution**
	
	Run the following command:
	
	```bash
	~/miniconda3/condabin/conda init
	```
	
	<figure><img src="/assets/conda-fix-activate-error.png"></figure>
	
	Afterwards, proceed with steps 6 and 7

8) You can check the Python and Conda versions in the existing environment by using the following commands:

```bash
python --version
conda --version
```

<figure><img src="/assets/conda-version.png"/></figure>

9) (Optional but not recommended) If you want to set [conda-forge](https://conda-forge.org/) as the primary update channel, you can follow these steps. Note that conda-forge packages are usually more up-to-date than conda packages, but they may have lower stability and reliability. This can potentially cause process freezing due to version conflicts during future upgrades. It is not recommended for regular users.

```bash
conda config --add channels conda-forge
conda config --set channel_priority strict
```