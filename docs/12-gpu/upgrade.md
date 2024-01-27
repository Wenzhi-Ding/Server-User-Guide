## 更新 GPU 驱动

每次更新完 GPU 驱动，就可能出现软件与驱动版本不匹配的问题。例如 `nvidia-smi`、`nvitop` 等命令可能就用不了了。

此时最简单的办法是重启机器。但考虑到服务器可能长时间都有人在使用，因此还有另一个办法就是单独[卸载和重载 GPU](https://askubuntu.com/questions/1166317/module-nvidia-is-in-use-but-there-are-no-processes-running-on-the-gpu)。

脚本如下：

```bash
# Stop processes using GPU
sudo service gdm3 stop

# Unload GPU
sudo rmmod nvidia_uvm
sudo rmmod nvidia_drm
sudo rmmod nvidia_modeset
sudo rmmod nvidia

# Reload GPU
sudo modprobe nvidia
sudo modprobe nvidia_modeset
sudo modprobe nvidia_drm
sudo modprobe nvidia_uvm
```