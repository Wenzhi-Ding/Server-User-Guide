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