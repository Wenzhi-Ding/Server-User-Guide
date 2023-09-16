# SQLite

To enter the SQLite database, use the following command:
```bash
sqlite3 test.db
```

To view the tables in the database, use the following SQL command:
```sql
.tables
```

To exit the SQLite database, use the following SQL command:
```sql
.quit
```

To execute an SQL script, use the following command:
```sql
.read xxx.sql
```

To delete a column from a table, follow these steps:
```sql
ALTER TABLE xxx RENAME TO yyy; -- Rename the table
.read new_xxx.sql  -- Create a new table without the column
INSERT INTO xxx SELECT * FROM yyy; -- Copy data from the renamed table to the new table
DROP TABLE yyy; -- Drop the renamed table
```