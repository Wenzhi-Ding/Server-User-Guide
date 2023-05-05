## Matplotlib字体设置

暂时修改字体设置（推荐这种方法，从代码层面确保跨系统的一致性）：

```python
plt.rcParams['font.family'] = 'Microsoft YaHei'
```

## 安装字体

如果画图时提示没有该字体，则需要安装一下。

安装新字体需要把字体拷贝到 Matplotlib 的字体文件夹：

```python
import matplotlib as mpl

mpl.matplotlib_fname()  # 得到配置文件夹路径。字体文件夹在此路径下
```

删除 Matplotlib 的缓存文件。

```python
import matplotlib as mpl
import shutil

shutil.rmtree(mpl.get_cachedir())  # 直接用代码删掉Matplotlib的缓存文件夹
```

随后再重新导入 Matplotlib 即可使用新字体。

## 查看可用字体

浏览所有可用字体：

```python
from matplotlib import font_manager
font_set = {f.name for f in font_manager.fontManager.ttflist}
sorted(font_set)
for f in font_set:
    print(f)
```