If you need to collaborate with others on a project, you can request a team name from the administrator, such as `team_trump`.

The administrator will create a directory `/home/team_trump`, which only you and your teammates have access to. You can place project files in this directory. For example:

```bash
home
  \- team_trump
  	\- 2022_us_election
```

??? question "If you cannot find the folder in Jupyter Lab"

	**Reason**
	
	Usually, your Jupyter Lab is launched in your own home directory, where you can only see files in your account's root directory.
	
	**Solution**
	
	Run the following command:

    ```bash
    ln -s /home/team_trump/2022_us_election ~/2022_us_election
    ```

    After executing the above command, the project folder should appear in your account's root directory, and accessing it will automatically switch to `/home/team_trump/2022_us_election`.

	By creating a symbolic link, you can create an entry point for the project folder anywhere.
	
	```bash
	ln -s [SOURCE] [TARGET]
	```

## Admin: Configuring Shared Directories

This section is for administrator reference. The following steps configure a multi-user read/write shared directory that meets these requirements:

- Members of the designated user group can **read and write all files**
- **Newly created files automatically inherit permissions**, no manual setup needed
- **Does not affect users' default permissions in other directories** (no umask modification)
- Other users **cannot access** the directory

### Prerequisites

- `sudo` privileges
- ACL tools installed (`getfacl` / `setfacl`)

### 1. Create a Shared User Group

```bash
sudo groupadd <group_name>
```

Add users who need shared access to the group:

```bash
sudo usermod -aG <group_name> <username1>
sudo usermod -aG <group_name> <username2>
```

!!! note

    Users need to log out and log back in for the new group to take effect. Verify with `id <username>`.

### 2. Create the Shared Directory

```bash
sudo mkdir /home/<directory_name>
```

### 3. Set Directory Ownership and Base Permissions

```bash
# Set the group to the shared group
sudo chgrp -R <group_name> /home/<directory_name>

# Set base permissions: owner and group can read/write/execute, others have no access
sudo chmod -R 770 /home/<directory_name>
```

### 4. Set setgid

setgid ensures that files/subdirectories created in this directory **automatically inherit the parent directory's group**, rather than using the creator's default group.

```bash
sudo chmod g+s /home/<directory_name>
```

### 5. Set ACL

ACL solves two problems:

1. Setting group permissions for **existing files**
2. **Newly created files** automatically get correct group permissions (via default ACL)

```bash
# Add group read/write permissions to existing files and directories (X means execute only for directories)
sudo setfacl -R -m g:<group_name>:rwX /home/<directory_name>

# Set default ACL so new files/directories automatically inherit
sudo setfacl -R -d -m g:<group_name>:rwX /home/<directory_name>

# Ensure others cannot access (including newly created files)
sudo setfacl -m d:o::--- /home/<directory_name>
```

!!! tip "Why not use umask?"

    `umask` is a user-level global setting — changing it affects the default permissions for files created by that user in **all directories**. ACL default rules only apply to a **specific directory**, making them more precise with no side effects.

### Verification

Check permissions:

```bash
getfacl /home/<directory_name>/
```

Expected output:

```
# owner: <user>
# group: <group_name>
# flags: -s-          ← s indicates setgid is active
user::rwx
group::rwx
group:<group_name>:rwx
mask::rwx
other::---
default:user::rwx
default:group::rwx
default:group:<group_name>:rwx
default:mask::rwx
default:other::---       ← others have no access
```

Test with different users:

```bash
# User A creates a file
touch /home/<directory_name>/test_a.txt
echo "hello" > /home/<directory_name>/test_a.txt

# User B edits the file
echo "world" >> /home/<directory_name>/test_a.txt

# Confirm group and permissions
ls -la /home/<directory_name>/test_a.txt
# Expected: group is <group_name>, group permissions are rw
```

### FAQ

??? question "A newly added user cannot see the files?"

    Users need to **log out and log back in** for the new group to take effect. Verify with `id <username>`.

??? question "Others cannot edit newly created files?"

    Check if the default ACL is correctly set: `getfacl <directory>`, and confirm it includes `default:group:<group_name>:rwx`.

??? question "How to add a new user to the shared directory?"

    Simply add them to the group — no need to reconfigure directory permissions:

    ```bash
    sudo usermod -aG <group_name> <new_username>
    ```

??? question "How to revoke a user's access?"

    ```bash
    sudo gpasswd -d <username> <group_name>
    ```
