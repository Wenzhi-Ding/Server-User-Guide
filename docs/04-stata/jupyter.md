目前，Stata有两种主流的在Jupyter Lab中使用的方案：

1. 官方提供的PyStata，可以在Python内核的笔记本中调用Stata
	* 优点：跟Python紧密结合，可以随时将Python数据直接输入Stata，运行Stata的统计命令后，将结果提取回Python做进一步处理
	* 缺点：暂时不支持语法高亮
	* 样例：[PyStata Example](/04-stata/pystata/)
2. Kyle Barron的[Stata Kernel](https://kylebarron.dev/stata_kernel/)
	* 优点：原生态的Stata使用体验，并且支持语法高亮
	* 缺点：只能使用Stata本身不灵活的导出方式
	* 样例：[Stata Kernel Example](/04-stata/stata_kernel)



此处推荐使用第一种解决方案。



## 1. PyStata

参考[官方教程](https://www.stata.com/python/pystata/)。



## 2. Stata Kernel

参考Kyle Barron的以下教程：

- [安装](https://kylebarron.dev/stata_kernel/getting_started/)

- [设置](https://kylebarron.dev/stata_kernel/using_stata_kernel/configuration/)
- [专有命令](https://kylebarron.dev/stata_kernel/using_stata_kernel/magics/)



!!! note "配置过程中需要指明Stata的位置"

	通常，根据安装的版本，Stata在Linux系统中具体的执行文件位置分别为：
	
	MP版本：
	
	```bash
	/usr/local/stata17/stata-mp
	```
	
	BE或SE版本：
	
	```bash
	/usr/local/stata17/stata
	```
