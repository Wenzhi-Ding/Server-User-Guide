This page records some of my experiences using Pandas.

## Data Slicing

Usually, data slicing is achieved using `df.loc[row_conditions, columns]`. Due to the calculation rules of logical operators in Pandas, the syntax for `row_conditions` can often be cumbersome. For example:

```python
tmp = df.loc[(df['a'] == 1) & (df['b'] == 2) & (df['c'] == 3)]
```

As you can see, writing complex logical expressions can be tedious. Therefore, the method I currently use is to further encapsulate `.loc` in Pandas with `.query()`:

```python
tmp = df.query('a == 1 and b == 2 and c == 3')
```

In `.query()`, it is also easy to call variables outside of the DataFrame, such as a constant `k` that I need for filtering. Both of the following methods work:

```python
tmp = df.query('a == @k')
tmp = df.query(f'a == {k}')  # This method cannot be used if k is a list-type variable
```

However, it is worth noting that `.query()` cannot be used for column selection (equivalent to the WHERE clause in SQL). Therefore, if you need to select specific columns, you can write it like this:

```python
tmp = df.query('a == 1 and b == 2 and c == 3')[['a', 'b']]
```