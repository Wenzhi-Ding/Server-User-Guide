## Managing Environments

Installing or updating packages can unintentionally change the versions of various packages in the environment, which can cause errors in programs that were previously running. For example, when using the Selenium web scraper, updating Selenium may change the API, resulting in errors that require debugging the program.

To avoid this situation, we can create a separate environment to run programs that depend on a fixed environment.

1) Creating a new environment

```bash
conda create -n torch python=3.11
```

In this example, a new environment named "torch" is created, with Python version 3.11 specified.

2) Activating the environment

```bash
conda activate torch
```

??? question "Too lazy to activate the environment every time"

    You can add `conda activate [name]` as the last line in the `~/.bashrc` file to automatically activate a specific environment upon every connection.

3) Directly calling the environment

For example, if you don't want to enter the environment but need to directly call it to run a program, you can first obtain the path to the Python executable in that environment:

```bash
conda activate torch
which python
conda deactivate
```

The `which python` command will tell you the location of the Python executable in the "torch" environment. For example:

```bash
"/home/bob/miniconda3/envs/torch/bin/python"
```

Now, we can use this Python executable to run our `run.py` file:

```bash
/home/bob/miniconda3/envs/torch/bin/python run.py
```

4) Viewing environments

You can use the following command to check which environments are currently available in Conda:

```bash
conda env list
```

5) Removing an environment

If an environment is no longer needed, it is recommended to remove it to save disk space and reduce the burden of managing environments.

```bash
conda env remove -n torch
```

This command will remove the "torch" environment.