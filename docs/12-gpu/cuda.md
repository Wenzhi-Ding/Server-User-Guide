## 安装CUDA

参照 Nvidia [官方指引](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu)即可。

## 训练模型

由于机器学习的 Package 迭代更新速度较快，常常出现由于 Package、驱动版本不匹配导致代码无法运行的问题。此处推荐使用 Docker 保证代码顺利运行。可以在 Nvidia 的[网站](https://catalog.ngc.nvidia.com/containers)找到官方编译的 Container。

以 TensorFlow 为例（[Nvidia 官方指引](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tensorflow)），需要使用 TensorFlow v1.15 微调 BERT 模型，可以使用以下流程：

1、查询 Docker 版本

```bash
docker --version
```

假设版本为 20.10。

2、下载并运行官方编译镜像

```bash
docker run --gpus all -it --rm nvcr.io/nvidia/tensorflow:20.10-tf1-py3
```

3、在 Python 中检查 GPU 是否可用

```python
import tensorflow as tf
print(tf.test.is_gpu_available())
```

其他操作：

- 进入镜像后，可以使用 `Ctrl+P` 和 `Ctrl+Q` 的组合暂时离开镜像
- `docker ps` 可以浏览当前挂载的 Container
- `docker attach <docker id> ` 可以返回对应的 Container
- 向 Container 中复制文件：`docker cp file <docker id>:/path`
- 从 Container 中复制文件：`docker cp <docker id>:/path/file /path`