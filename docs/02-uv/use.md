## 管理环境

安装或更新包可能会改变环境中各个包的版本，导致原来可以运行的程序报错。为了避免这种情况，我们可以为每个项目创建独立的虚拟环境。

!!! tip "如果你仍想使用 Conda"

    可以参考 [Conda 使用教程](../02-conda/use.md)。

### 1、初始化项目

推荐使用 `uv init` 来初始化一个新项目。这会自动创建 `pyproject.toml` 文件来管理依赖。

```bash
cd ~/my-project
uv init
```

这将在当前目录生成 `pyproject.toml`、`.python-version` 等文件。

??? question "不想创建项目，只想要一个虚拟环境"

    如果你只需要一个简单的虚拟环境（不需要项目管理功能），可以直接创建：

    ```bash
    uv venv
    ```

    或者指定 Python 版本：

    ```bash
    uv venv --python 3.11
    ```

    或者指定环境的名称/路径：

    ```bash
    uv venv my-env
    ```

### 2、添加依赖

使用 `uv add` 来安装包，这会自动更新 `pyproject.toml` 并安装到虚拟环境中：

```bash
uv add numpy pandas matplotlib
```

??? question "如何安装指定版本的包？"

    ```bash
    uv add "numpy>=1.24,<2.0"
    uv add "pandas==2.1.0"
    ```

??? question "如何使用 pip install？"

    uv 也兼容 pip 风格的安装命令：

    ```bash
    uv pip install numpy
    ```

    但推荐优先使用 `uv add`，因为它会自动管理 `pyproject.toml` 中的依赖记录。

### 3、激活环境

有两种方式使用虚拟环境中的 Python。

#### 方式一：使用 `uv run`（推荐）

`uv run` 会自动在虚拟环境中执行命令，无需手动激活：

```bash
uv run python my_script.py
uv run jupyter lab
```

#### 方式二：手动激活

如果你习惯手动激活环境：

```bash
source .venv/bin/activate
```

激活后，命令行前会出现 `(.venv)` 前缀，此时可以直接使用 `python`、`jupyter` 等命令。

退出环境：

```bash
deactivate
```

??? question "懒得每次都激活环境"

    可以在 `~/.bashrc` 文件的最后一行加上 `source /path/to/project/.venv/bin/activate`，在每次连接时自动激活某环境。

#### 方式三：VSCode Python 环境插件（推荐）

如果你使用 VSCode Remote SSH 连接服务器：

1. 安装 [Python 扩展](https://marketplace.visualstudio.com/items?itemName=ms-python.python)（通常已默认安装）。

2. 打开你的项目文件夹后，VSCode 会自动检测 `.venv` 目录并提示你选择该解释器。

3. 如果未自动检测到，可以手动选择：
    - 按 `Ctrl+Shift+P`（macOS 为 `Cmd+Shift+P`）
    - 搜索 `Python: Select Interpreter`
    - 选择 `.venv` 目录中的 Python 解释器

4. 选择后，VSCode 的终端会自动激活该虚拟环境，无需手动执行 `source .venv/bin/activate`。

### 4、恢复环境

uv 的一大优势是可以精确地恢复环境。当你在新机器上或者需要重新创建环境时：

```bash
cd ~/my-project
uv sync
```

`uv sync` 会根据 `pyproject.toml`（以及 `uv.lock`）精确地重新安装所有依赖，确保环境一致。

??? question "从 requirements.txt 恢复环境"

    如果你有一个 `requirements.txt` 文件：

    ```bash
    uv pip install -r requirements.txt
    ```

??? question "如何导出依赖列表？"

    ```bash
    uv pip freeze > requirements.txt
    ```

    或者使用 uv 原生的锁文件，直接将 `pyproject.toml` 和 `uv.lock` 文件分享给他人即可。

### 5、直接调用该环境

如果不想进入环境，可以直接调用虚拟环境中的 Python：

```bash
/path/to/project/.venv/bin/python run.py
```

或使用 `uv run`：

```bash
uv run --project /path/to/project python run.py
```

### 6、查看环境信息

```bash
uv pip list       # 查看已安装的包
uv python list --only-installed   # 查看已安装的 Python 版本
```

### 7、删除环境

某个环境如果不再使用了，建议清除掉以节省硬盘空间：

```bash
rm -rf .venv
```

或者如果你有命名的环境：

```bash
rm -rf my-env
```

---

## uv vs Conda

### 为什么推荐 uv？

| 特性 | uv | Conda |
|-|-|-|
| 安装速度 | ⚡ 极快（10-100x） | 较慢 |
| 磁盘占用 | 轻量 | 较重（base 环境即占数 GB） |
| 依赖解析 | 快速且精确 | 较慢，有时会卡死 |
| Python 版本管理 | 内置支持 | 内置支持 |
| 环境可复现性 | `uv.lock` 锁文件精确锁定 | `environment.yml` 不够精确 |
| 与 PyPI 兼容 | 完全兼容 | 有自己的渠道，偶有兼容问题 |
| 学习成本 | 低（类似 pip） | 中等 |

### 什么时候仍应该用 Conda？

- **需要安装非 Python 的依赖**：Conda 可以管理 C/C++ 库、CUDA toolkit 等系统级依赖，uv 仅管理 Python 包。
- **特定的科学计算包**：某些包（如 `rdkit`、部分生物信息学工具）仅在 Conda 渠道提供。
- **团队已有 Conda 工作流**：如果团队已经统一使用 Conda 且运行良好，不必强行切换。

!!! note "CUDA 用户"

    如果你需要使用 GPU（如 PyTorch、TensorFlow），uv 同样可以安装它们的 pip 版本。大多数深度学习框架现在都通过 PyPI 提供预编译的 CUDA 版本。例如：

    ```bash
    uv add torch torchvision torchaudio
    ```

    具体安装方式请参考各框架的官方文档。
