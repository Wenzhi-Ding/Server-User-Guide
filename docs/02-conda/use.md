## 管理环境

安装或更新包可能会无意间改变环境中各个包的版本，进而导致某些原来可以运行的程序会报错。例如使用 Selenium 爬虫，更新 Selenium 后 API 可能会变，从而导致报错，需要重新调试程序。

为了避免这种情况，我们可以创建一个单独的环境来运行这些依赖固定环境的程序。

1、新建环境

```bash
conda create -n torch python=3.11
```

比如此处，就新建了一个名为 `torch` 的环境，并且指定了 Python 版本为3.11。

2、激活环境

```bash
conda activate torch
```

??? question "懒得每次都激活环境"

	可以在 `~/.bashrc` 文件的最后一行加上 `conda activate [name]`，在每次连接时自动激活某环境。

3、直接调用该环境

例如我不想要进入该环境，只是需要直接调用该环境来运行某程序，可以首先获取该环境的 Python 的路径：

```bash
conda activate torch
which python
conda deactivate
```

其中，`which python` 会告诉你 `torch` 环境的 Python 位于哪个位置。比如：

```bash
"/home/bob/miniconda3/envs/torch/bin/python"
```

现在，我们用这个 Python 来执行我们的 `run.py` 文件：

```bash
/home/bob/miniconda3/envs/torch/bin/python run.py
```

4、查看环境

可以通过以下命令检查当前 Conda 中有哪些环境：

```bash
conda env list
```

5、删除环境

某个环境如果不再使用了，建议清除掉，以节省硬盘空间和管理环境的负担。

```bash
conda env remove -n torch
```

此处就清除掉了 `torch` 这个环境