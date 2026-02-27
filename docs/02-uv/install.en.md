We recommend using [uv](https://docs.astral.sh/uv/) to manage Python environments. uv is an extremely fast Python package manager developed by [Astral](https://astral.sh/), written in Rust, and 10-100x faster than traditional tools.

!!! tip "If you previously used Conda"

    If you still prefer using Conda to manage environments, refer to the [Conda installation guide](../02-conda/install.md) and [Conda usage guide](../02-conda/use.md). However, we now recommend uv — see [uv vs Conda comparison](use.md#uv-vs-conda) for why.

## Installing uv

1) Install uv by running the following command on the server:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

2) After installation, reload the shell configuration:

```bash
source $HOME/.local/bin/env
```

Or simply close and reopen the terminal.

3) Verify the installation:

```bash
uv --version
```

If a version number is returned (e.g. `uv 0.6.x`), the installation was successful.

## Installing Python

uv can manage Python versions directly — no need to install Python beforehand.

1) Install a specific Python version:

```bash
uv python install 3.12
```

2) List installed Python versions:

```bash
uv python list --only-installed
```

3) (Optional) Install multiple Python versions:

```bash
uv python install 3.11 3.12 3.13
```

## Updating uv

```bash
uv self update
```
