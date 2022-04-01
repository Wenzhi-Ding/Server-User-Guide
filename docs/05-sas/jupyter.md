## 安装`saspy`

```shell
conda install saspy
```

启动`python`，通过以下命令找到`saspy`配置文件的位置

```python
import saspy
saspy
```

例如返回

```python
<module 'saspy' from '
/home/ubuntu/miniconda3/envs/py39/lib/python3.9/site-packages/saspy/__init__.py'>
```

通过SFTP打开该目录`/home/ubuntu/miniconda3/envs/py39/lib/python3.9/site-packages/saspy`，编辑该目录下的`sascfg.py`文件：

<figure><img src="/assets/sas-py-config.png"></figure>

将`default`中的`saspath`改为本服务器的SAS安装位置。该安装位置可以在Linux Shell通过以下命令得到：

```shell
which sas
```

## 在Python中使用

SAS官方提供的`saspy`参考代码：[saspy-examples](https://github.com/sassoftware/saspy-examples/)

经过尝试，目前推荐的流程如下。

### 初始化

使用SAS数据首先需要将对应的目录作为Library指示给SAS。下面的例子即是将`/data/dataset/Compustat/d_global`目录作为一个Library指示给SAS，并命名为`db`。

```python
import saspy

sas = saspy.SASsession()
ll = sas.submit('libname db "/data/dataset/Compustat/d_global";')
```

### 读取数据

在此处，我们默认数据处理的核心是Pandas。因此目标是以尽可能高效的方式将SAS数据读取为Pandas.DataFrame。如果需要转换为其他数据类型，可以从Pandas.DataFrame做进一步转换或自行探索其他方案。

读取整张表：

```python
df = sas.sd2df(
    libref='db', 
    table='g_names', 
)
df.head()
```

<figure><img src="/assets/sas-py-read-simple.png"></figure>

!!! 效率问题

	读取大表时不建议采用这种方法，请参考下方。

有选择地读取：

```python
df = sas.sd2df(
    libref='db', 
    table='g_names', 
    dsopts={
        'where': 'costat = "A" and fic = "NLD"', 
        'keep': ['gvkey', 'costat', 'fic'],
        # 'drop': ['conm', 'sedol'],
        'obs': 10
    }
)
df.head()
```

<figure><img src="/assets/sas-py-read-filter.png"></figure>

!!! 处理大文件

	建议善用`where`和`obs`选项。先按一定条件选择少量数据观察，并写完处理代码后，再对整张表进行读取。
	
	在数据被处理达到合理大小后，可以及时存储为Parquet格式。方便快速调用查询结果。
	
	读取大表尽量不要覆盖SAS直接返回的变量（上面例子中的`df`），否则每次处理出问题都需要重新读取的话会比较浪费时间。90GB的SAS数据读取一遍大约需要10分钟。

更多选项请参考帮助文档和样例代码。

```python
help(sas.sd2df)
```

