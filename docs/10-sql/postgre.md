# PostgreSQL

## 安装PostgreSQL Server

根据[官方网页](https://www.postgresql.org/download/)安装PostgreSQL Server。

安装结束后检查是否安装成功：

```bash
psql --version
```

应当会返回PostgreSQL Server的版本号。

## 配置服务器端

安装完成后，如果直接试图进入PostgreSQL，应该会失败。

```bash
psql
```

提示：

```
psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "ubuntu" does not exist
```

此时应该先给自己的账户创建一个PSQL中的超级用户。先切换到安装PSQL时创建的postgres用户

```bash
sudo su - postgres
```

进入PSQL

```bash
psql
```

随后使用SQL语句创建超级用户`ubuntu`，假定密码是`123456`。

```sql
CREATE USER ubuntu WITH SUPERUSER PASSWORD '123456';
```

查看用户列表：

```
\du
```

退出PSQL：

```
\q
```

此时回到自己的`ubuntu`用户时，已经可以打开PSQL了。

新建一个test数据库：

```bash 
createdb test
```

进入test数据库：

```bash
psql postgres
```

以ubuntu的身份进入test数据库：

```bash
psql -U ubutnu test
```

## 远程连接：服务器端设置

在自己的电脑上，可以通过SSL或SSH隧道远程连接服务器上的SQL Server。此处只推荐使用SSH隧道。

首先修改PSQL的`postgresql.conf`配置文件，通常位于`/etc/postgresql/14/main`（其中14为版本号）。

```bash
sudo vim /etc/postgresql/14/main/postgresql.conf
```

将其中的`listen_addresses`参数取消注释并添加`<local_ip>`，即服务器的IP地址：

```
listen_addresses = 'localhost,<local_ip>'
```

接下来修改`pg_hba.conf`配置文件

```bash
sudo vim /etc/postgresql/14/main/pg_hba.conf
```

添加规则允许你的用户访问PSQL（第一行是原有的，第二行是新增的）：

```
host    all             all             127.0.0.1/32            scram-sha-256
host    all             ubuntu          127.0.0.1/0             md5
```

编辑完成后，重新启动PSQL：

```bash
sudo service postgresql restart
```

## 远程连接：本地设置

可以安装[PgAdmin](https://www.pgadmin.org/)或[HeidiSQL](https://www.heidisql.com/)，其中PgAdmin是为PostgreSQL Server专门设计的显示界面，HeidiSQL是适用于各种SQL Server的显示界面。

设置方法大同小异。此处以HeidiSQL举例：

首先填入SQL相关的信息，如PostgreSQL Server所在的服务器IP、SQL的用户名及密码（而非SSH的用户名及密码）、数据库名。

<figure><img src="/assets/heidisql-sql.png"></figure>

然后填入SSH相关的信息，即你的服务器账户登录所需信息。

<figure><img src="/assets/heidisql-ssh.png"></figure>

如此便可以成功登录。HeidiSQL成功登录的显示如下：

<figure><img src="/assets/heidisql-login.png"></figure>

PgAdmin成功登录的显示如下：

<figure><img src="/assets/pgadmin-login.png"></figure>