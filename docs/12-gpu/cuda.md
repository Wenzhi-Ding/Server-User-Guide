## 安装CUDA

参照 Nvidia [官方指引](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu)即可。

## 训练模型

由于机器学习的 Package 迭代更新速度较快，常常出现由于 Package、驱动版本不匹配导致代码无法运行的问题。此处推荐使用 Docker 保证代码顺利运行。可以在 [Tensorflow](https://www.tensorflow.org/install/docker?hl=zh-cn) 和 [Nvidia](https://catalog.ngc.nvidia.com/containers) 的网站找到官方编译的 Container。

以 TensorFlow 为例，当需要使用 TensorFlow v1.11 微调 BERT 模型，可以使用以下流程：

1、查询 Docker 版本

```bash
docker --version
```

假设版本为 20.10。

??? question "Permission denied"

    这是由于管理员未将你添加入 Docker 的权限组。具体操作如下：

    1. 管理员新建 `docker` 用户组：`sudo groupadd docker`
    2. 管理员将 `docker.sock` 的用户组改为 `docker`：`sudo chgrp docker /var/run/docker.sock`
    3. 管理员将用户添加至 `docker` 用户组：`sudo usermod -aG docker <username>`
    4. 用户关闭终端后重新进入

2、下载并运行官方编译镜像

Tensorflow 官方镜像（推荐，版本更灵活）：

```bash
docker run --gpus all -it --rm docker.io/tensorflow/tensorflow:1.11.0-gpu-py3 bash
```

将 `1.11.0` 替换成你需要的版本即可。还可以在 Docker 外直接调用 Python 运行你的脚本，类似以下这样：

```bash
docker run -it --rm -v $PWD:/tmp -w /tmp tensorflow/tensorflow python ./script.py
```

也可以使用 Nvidia 官方镜像：

```bash
docker run --gpus all -it --rm nvcr.io/nvidia/tensorflow:20.10-tf1-py3
```

??? question "`docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]`"

    这通常是因为 GPU 的驱动没装好。具体情况有可能比较复杂，请找管理员解决。

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
- 删除某个 Container：`docker kill <container id>`
