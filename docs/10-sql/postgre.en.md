# PostgreSQL

## Installing PostgreSQL Server

Install PostgreSQL Server according to the [official website](https://www.postgresql.org/download/).

After installation, check if it was successful by running the following command:

```bash
psql --version
```

It should return the version number of PostgreSQL Server.

## Configuring the Server

After installation, if you try to access PostgreSQL directly, it will fail.

```bash
psql
```

Error message:

```
psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "ubuntu" does not exist
```

To fix this, you need to create a superuser in PostgreSQL for your account. First, switch to the "postgres" user created during the PostgreSQL installation:

```bash
sudo su - postgres
```

Enter the PostgreSQL prompt:

```bash
psql
```

Then, use SQL commands to create a superuser named "ubuntu" with the password "123456" (assuming these values):

```sql
CREATE USER ubuntu WITH SUPERUSER PASSWORD '123456';
```

To view the list of users:

```
\du
```

Exit the PostgreSQL prompt:

```
\q
```

Now, when you switch back to your "ubuntu" user, you should be able to open PostgreSQL.

Create a new database named "test":

```bash 
createdb test
```

Enter the "test" database:

```bash
psql postgres
```

To enter the "test" database as the user "ubuntu":

```bash
psql -U ubuntu test
```

## Remote Connection: Server-side Configuration

On your local computer, you can remotely connect to the SQL Server on the server using SSL or an SSH tunnel. Here, we recommend using an SSH tunnel.

First, modify the `postgresql.conf` configuration file of PostgreSQL, usually located at `/etc/postgresql/14/main` (where 14 is the version number).

```bash
sudo vim /etc/postgresql/14/main/postgresql.conf
```

Uncomment the `listen_addresses` parameter and add `<local_ip>`, which is the IP address of the server:

```
listen_addresses = 'localhost,<local_ip>'
```

Next, modify the `pg_hba.conf` configuration file:

```bash
sudo vim /etc/postgresql/14/main/pg_hba.conf
```

Add a rule to allow your user to access PostgreSQL (the first line is the existing one, and the second line is the new one):

```
host    all             all             127.0.0.1/32            scram-sha-256
host    all             ubuntu          127.0.0.1/0             md5
```

After editing, restart PostgreSQL:

```bash
sudo service postgresql restart
```

## Remote Connection: Local Configuration

You can install [PgAdmin](https://www.pgadmin.org/) or [HeidiSQL](https://www.heidisql.com/). PgAdmin is a dedicated graphical interface for PostgreSQL Server, while HeidiSQL is a graphical interface for various SQL Servers.

The setup process is similar. Here, we'll use HeidiSQL as an example:

First, enter the SQL-related information, such as the IP address of the PostgreSQL Server, the SQL username and password (not the SSH username and password), and the database name.

<figure><img src="/assets/heidisql-sql.png"></figure>

Then, enter the SSH-related information, which is the login information for your server account.

<figure><img src="/assets/heidisql-ssh.png"></figure>

This should allow you to successfully log in. The successful login screen for HeidiSQL looks like this:

<figure><img src="/assets/heidisql-login.png"></figure>

The successful login screen for PgAdmin looks like this:

<figure><img src="/assets/pgadmin-login.png"></figure>