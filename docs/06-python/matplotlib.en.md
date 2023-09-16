## Setting Font in Matplotlib

Temporarily modify the font setting (recommended method to ensure consistency across systems at the code level):

```python
plt.rcParams['font.family'] = 'Microsoft YaHei'
```

## Installing Fonts

If you encounter a prompt indicating that the font is not available when plotting, you need to install it.

To install a new font, copy the font to the Matplotlib font folder:

```python
import matplotlib as mpl

mpl.matplotlib_fname()  # Get the configuration folder path. The font folder is located at this path.
```

Delete the Matplotlib cache files.

```python
import matplotlib as mpl
import shutil

shutil.rmtree(mpl.get_cachedir())  # Delete the Matplotlib cache folder directly using code.
```

Then, re-import Matplotlib to use the new font.

## Viewing Available Fonts

Browse all available fonts:

```python
from matplotlib import font_manager
font_set = {f.name for f in font_manager.fontManager.ttflist}
sorted(font_set)
for f in font_set:
    print(f)
```