## Matplotlib字体设置

浏览所有可用字体：

```python
from matplotlib import font_manager
font_set = {f.name for f in font_manager.fontManager.ttflist}
sorted(font_set)
for f in font_set:
    print(f)
```

暂时修改字体设置（推荐这种方法，从代码层面确保跨系统的一致性）：

```python
plt.rcParams['font.family'] = 'Microsoft YaHei'
```

安装新字体需要把字体拷贝到Matplotlib的字体文件夹后，删除Matplotlib的缓存文件。随后再重新导入Matplotlib即可使用新字体。

```python
import matplotlib as mpl
mpl.matplotlib_fname()  # 得到配置文件夹路径。字体文件夹在此路径下

mpl.get_cachedir()  # 得到Matplotlib的缓存文件夹路径

import shutil
shutil.rmtree(mpl.get_cachedir())  # 直接用代码删掉该路径
```