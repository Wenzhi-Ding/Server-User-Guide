## Managing Environments

Installing or updating packages can change versions of various packages in the environment, causing programs that previously worked to fail. To avoid this, we can create isolated virtual environments for each project.

!!! tip "If you still want to use Conda"

    Refer to the [Conda usage guide](../02-conda/use.md).

### 1) Initialize a project

We recommend using `uv init` to initialize a new project. This automatically creates a `pyproject.toml` file to manage dependencies.

```bash
cd ~/my-project
uv init
```

This generates `pyproject.toml`, `.python-version`, and other files in the current directory.

??? question "I just want a virtual environment without project management"

    If you only need a simple virtual environment, create one directly:

    ```bash
    uv venv
    ```

    Or specify a Python version:

    ```bash
    uv venv --python 3.11
    ```

    Or specify a custom name/path:

    ```bash
    uv venv my-env
    ```

### 2) Add dependencies

Use `uv add` to install packages — this automatically updates `pyproject.toml` and installs into the virtual environment:

```bash
uv add numpy pandas matplotlib
```

??? question "How to install a specific version of a package?"

    ```bash
    uv add "numpy>=1.24,<2.0"
    uv add "pandas==2.1.0"
    ```

??? question "How to use pip install?"

    uv also supports pip-style install commands:

    ```bash
    uv pip install numpy
    ```

    However, `uv add` is preferred because it automatically records dependencies in `pyproject.toml`.

### 3) Activate the environment

There are two ways to use Python from the virtual environment.

#### Option A: Use `uv run` (Recommended)

`uv run` automatically executes commands within the virtual environment — no manual activation needed:

```bash
uv run python my_script.py
uv run jupyter lab
```

#### Option B: Manual activation

If you prefer to activate the environment manually:

```bash
source .venv/bin/activate
```

After activation, you'll see a `(.venv)` prefix in the command line. You can then use `python`, `jupyter`, etc. directly.

To deactivate:

```bash
deactivate
```

??? question "Too lazy to activate the environment every time"

    You can add `source /path/to/project/.venv/bin/activate` to the last line of your `~/.bashrc` file to automatically activate a specific environment upon every connection.

#### Option C: VSCode Python Extension (Recommended)

If you use VSCode Remote SSH to connect to the server:

1. Install the [Python extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python) (usually installed by default).

2. After opening your project folder, VSCode will automatically detect the `.venv` directory and prompt you to select it as the interpreter.

3. If not auto-detected, select it manually:
    - Press `Ctrl+Shift+P` (macOS: `Cmd+Shift+P`)
    - Search for `Python: Select Interpreter`
    - Select the Python interpreter in the `.venv` directory

4. Once selected, the VSCode terminal will automatically activate the virtual environment — no need to manually run `source .venv/bin/activate`.

### 4) Restore an environment

One major advantage of uv is precise environment restoration. When you're on a new machine or need to recreate the environment:

```bash
cd ~/my-project
uv sync
```

`uv sync` will precisely reinstall all dependencies based on `pyproject.toml` (and `uv.lock`), ensuring environment consistency.

??? question "Restore from requirements.txt"

    If you have a `requirements.txt` file:

    ```bash
    uv pip install -r requirements.txt
    ```

??? question "How to export the dependency list?"

    ```bash
    uv pip freeze > requirements.txt
    ```

    Or use uv's native lock file — simply share the `pyproject.toml` and `uv.lock` files with others.

### 5) Directly call the environment

If you don't want to enter the environment, you can directly call Python from the virtual environment:

```bash
/path/to/project/.venv/bin/python run.py
```

Or use `uv run`:

```bash
uv run --project /path/to/project python run.py
```

### 6) View environment information

```bash
uv pip list       # List installed packages
uv python list --only-installed   # List installed Python versions
```

### 7) Remove an environment

If an environment is no longer needed, remove it to save disk space:

```bash
rm -rf .venv
```

Or if you have a named environment:

```bash
rm -rf my-env
```

---

## uv vs Conda

### Why we recommend uv

| Feature | uv | Conda |
|-|-|-|
| Install speed | ⚡ Extremely fast (10-100x) | Slow |
| Disk usage | Lightweight | Heavy (base env alone is several GB) |
| Dependency resolution | Fast and precise | Slow, sometimes hangs |
| Python version management | Built-in | Built-in |
| Environment reproducibility | `uv.lock` for precise locking | `environment.yml` is imprecise |
| PyPI compatibility | Fully compatible | Has its own channels, occasional issues |
| Learning curve | Low (similar to pip) | Medium |

### When should you still use Conda?

- **Non-Python dependencies**: Conda can manage C/C++ libraries, CUDA toolkit, and other system-level dependencies. uv only manages Python packages.
- **Specific scientific packages**: Some packages (e.g. `rdkit`, certain bioinformatics tools) are only available through Conda channels.
- **Existing team workflow**: If your team already uses Conda consistently and it works well, there's no need to switch.

!!! note "CUDA users"

    If you need GPU support (e.g. PyTorch, TensorFlow), uv can install their pip versions just fine. Most deep learning frameworks now provide pre-compiled CUDA builds via PyPI. For example:

    ```bash
    uv add torch torchvision torchaudio
    ```

    Refer to each framework's official documentation for specific installation instructions.
