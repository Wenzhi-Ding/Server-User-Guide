## Update GPU Driver

After updating the GPU driver, software may not be compatible with the driver version. For example, commands such as `nvidia-smi` and `nvitop` may no longer work.

The simplest solution is to restart the machine. However, considering that servers may be in use for a long time, there is another option: to [uninstall and reload the GPU](https://askubuntu.com/questions/1166317/module-nvidia-is-in-use-but-there-are-no-processes-running-on-the-gpu).

The script is as follows:

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
