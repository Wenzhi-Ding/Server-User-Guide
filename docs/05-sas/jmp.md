JMP是SAS旗下的一款可视化的数据分析软件。本页面提供一些JMP的基本操作参考和概念解释。

## 导入并浏览数据

=== "1.导入数据"

	<figure><img src="/assets/jmp-open-data.png"></figure>

=== "2.浏览数据"

	<figure><img src="/assets/jmp-data-browser.png"></figure>

## 创建新的变量

=== "1.新建列"
	
	<figure><img src="/assets/jmp-new-column.png"></figure>

=== "2.创建公式"
	
	<figure><img src="/assets/jmp-new-column-formula.png"></figure>

=== "3.编辑公式"
	
	<figure><img src="/assets/jmp-edit-formula.png"></figure>

## 线性模型分析

### OLS及逻辑回归

主界面中选择“分析——拟合模型”，即可进入线性模型的设置界面。

<figure><img src="/assets/jmp-linear-model.png"></figure>

??? question "无法选择Logistic模型"

	**原因**
	
	因变量的类型是连续型，并未设置成有序型或名义型。
	
	**解决方案**
	
	在列信息中改变数据类型。
	
	<figure><img src="/assets/jmp-column-info.png"></figure>
	
	<figure><img src="/assets/jmp-change-type.png"></figure>

模型运行完成后，会返回报告界面。

<figure><img src="/assets/jmp-model-report.png"></figure>

点击红色三角可以展开更多报告选项。例如二分类问题中常用来评估模型的ROC曲线和混淆矩阵。以及“刻画器”，可以用来交互式的查看自变量对因变量的影响。

<figure><img src="/assets/jmp-interact.png"></figure>

### 生存分析

## 非线性模型

线性模型结果报告中提到的“刻画器”在非线性模型的展示中格外有用。

### 神经网络

主界面中选择“分析——预测建模——神经”，即可进入神经网络的设置界面。

### 随机森林

主界面中选择“分析——预测建模——Bootstrap森林法”，即可进入随机森林的设置界面。