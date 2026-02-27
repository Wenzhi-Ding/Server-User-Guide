推荐使用 [uv](https://docs.astral.sh/uv/) 来管理 Python 环境。uv 是由 [Astral](https://astral.sh/) 开发的极速 Python 包管理器，用 Rust 编写，速度比传统工具快 10-100 倍。

!!! tip "如果你之前使用 Conda"

    如果你仍希望使用 Conda 管理环境，可以参考[Conda 安装教程](../02-conda/install.md)和[Conda 使用教程](../02-conda/use.md)。但我们现在推荐使用 uv，原因详见[uv 与 Conda 的对比](use.md#uv-vs-conda)。

## 安装 uv

1、在服务器中执行以下命令安装 uv：

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

2、安装完成后，重新加载 shell 配置：

```bash
source $HOME/.local/bin/env
```

也可以关闭终端后重新连接。

3、验证安装是否成功：

```bash
uv --version
```

若能正常返回版本号（如 `uv 0.6.x`），则表示安装成功。

## 安装 Python

uv 可以直接管理 Python 版本，无需预先安装 Python。

1、安装指定版本的 Python：

```bash
uv python install 3.12
```

2、查看已安装的 Python 版本：

```bash
uv python list --only-installed
```

3、（可选）安装多个 Python 版本：

```bash
uv python install 3.11 3.12 3.13
```

## 更新 uv

```bash
uv self update
```
