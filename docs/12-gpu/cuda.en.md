## Installing CUDA

You can refer to Nvidia's [official guide](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu) for installation.

## Training Models

Due to the fast iteration and updates of machine learning packages, it is common to encounter issues where code cannot run due to package and driver version mismatch. Here, we recommend using Docker to ensure smooth code execution. You can find official compiled containers on the websites of [Tensorflow](https://www.tensorflow.org/install/docker?hl=en) and [Nvidia](https://catalog.ngc.nvidia.com/containers).

Taking TensorFlow as an example, when you need to fine-tune a BERT model using TensorFlow v1.11, you can follow these steps:

1. Check Docker version

```bash
docker --version
```

Assuming the version is 20.10.

??? question "Permission denied"

    This is because the administrator has not added you to the Docker permission group. Here are the specific steps:

    1. The administrator creates a new `docker` user group: `sudo groupadd docker`
    2. The administrator changes the user group of `docker.sock` to `docker`: `sudo chgrp docker /var/run/docker.sock`
    3. The administrator adds the user to the `docker` user group: `sudo usermod -aG docker <username>`
    4. The user closes the terminal and re-enters

2. Download and run the official compiled image

TensorFlow official image (recommended for more flexibility in versions):

```bash
docker run --gpus all -it --rm docker.io/tensorflow/tensorflow:1.11.0-gpu-py3 bash
```

Replace `1.11.0` with the version you need. You can also directly call Python outside of Docker to run your script, similar to the following:

```bash
docker run -it --rm -v $PWD:/tmp -w /tmp tensorflow/tensorflow python ./script.py
```

You can also use the Nvidia official image:

```bash
docker run --gpus all -it --rm nvcr.io/nvidia/tensorflow:20.10-tf1-py3
```

??? question "`docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]`"

    This is usually because the GPU driver is not installed properly. The specific situation may be more complex, so please consult the administrator to resolve it.

3. Check GPU availability in Python

```python
import tensorflow as tf
print(tf.test.is_gpu_available())
```

Other operations:

- After entering the image, you can temporarily leave the image using the combination `Ctrl+P` and `Ctrl+Q`.
- `docker ps` allows you to browse the currently mounted containers.
- `docker attach <docker id>` allows you to return to the corresponding container.
- Copying files to the container: `docker cp file <docker id>:/path`
- Copying files from the container: `docker cp <docker id>:/path/file /path`
- Deleting a container: `docker kill <container id>`