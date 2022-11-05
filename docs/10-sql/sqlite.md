# SQLite

进入SQLite数据库
```bash
sqlite3 test.db
```

查看数据表
```sql
.tables
```

退出
```sql
.quit
```

执行SQL脚本
```sql
.read xxx.sql
```

删除表的某一列
```sql
ALTER TABLE xxx RENAME TO yyy;
.read new_xxx.sql  -- 创建不含该列的新表
INSERT INTO xxx SELECT * FROM yyy;
DROP TABLE yyy;
```