建议使用编号系统管理项目文件。如`2022_network_analysis`项目的文件结构：

```bash
2022_network_analysis
  \-01_code
  	\-a01_analysis.ipynb
  	\-a02_visualize.ipynb
  	\-d11_basic_data.ipynb
  \-02_rdata
    \-raw_data.csv
  \-03_wdata
  	\-0100_reg.csv
  	\-0200_visual.csv
  	\-1100_data_wip.csv
  	\-1101_data_processed.csv
  \-04_result
  	\-tab_baseline.rtf
  	\-fig_trend.svg
```

## 代码

代码存放于`01_code`。

- `a01`表示分析（`a`取analysis首字母）用的第一份代码
- `d11`表示处理（`d`取data首字母）`11`系列的数据。

## 原始数据

原始数据存放于`02_rdata`，即从外部获取的原始数据，如`raw_data.csv`。

尽量不要改变原始数据的原本命名（除非是WRDS或CSMAR这些数据平台导出的意义不明的文件名），方便以后定位每份原始数据的来源。

## 经处理数据

经处理的数据存放于`03_wdata`。

- 数据组成成分可以按`11`、`12`的前缀编写。
	* 可以按数据来源分类，比如Compustat的数据统一为`11`前缀，CRSP的数据统一为`12`前缀。
	* 也可以按主题分类，比如股价数据统一为`11`前缀，宏观数据统一为`12`前缀。
- 分析用的数据以`01-09`开头，比如回归分析的数据是`01`、可视化用的数据是`02`。
- 后两位可以按顺序依次从`00`编至`99`。

??? question "这样编号的好处是什么？"

	- 编号前缀可以快速定位某个数据是被哪份代码处理的。
	- 编号后缀可以指明数据在项目处理流程中的先后关系。

## 结果

输出结果存放于`04_result`

- `tab`前缀用于表格
- `fig`前缀用于图片

??? question "这样编号的好处是什么？"

	方便在LaTeX中调用。