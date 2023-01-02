此页面记录我使用 Pandas 中的一些经验。

## 数据切片

通常数据切片都是用 `df.loc[row_conditions, columns]` 来实现的。由于 Pandas 对逻辑运算符的计算规则，`row_conditions` 的写法常常比较繁琐。比如

```python
tmp = df.loc[(df['a'] == 1) & (df['b'] == 2) & (df['c'] == 3)]
```

可以看到复合逻辑表达写起来很麻烦。因此我目前采用的方法是 Pandas 对 `.loc` 做的进一步封装——`.query()`

```python
tmp = df.query('a == 1 and b == 2 and c == 3')
```

在 `.query()` 中也可以很容易调用 DataFrame 以外的变量，比如环境中有一个常数 `k`，我需要用来做筛选。以下两种方法都可以：

```python
tmp = df.query('a == @k')
tmp = df.query(f'a == {k}')  # 如果 k 是列表类型的变量则不能用这种方法
```

不过值得注意的是，`.query()` 不能对列做选择（相当于 SQL 中的 WHERE 语句），因此如果需要选择特定的列，可以这样写：

```python
tmp = df.query('a == 1 and b == 2 and c == 3')[['a', 'b']]
```