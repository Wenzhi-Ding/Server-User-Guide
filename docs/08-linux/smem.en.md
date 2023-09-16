Server users often leave certain processes running in the background that are no longer in use, such as certain kernels in Jupyter Lab. Besides occupying memory, they also often consume a large amount of cache. This page provides instructions for users on how to check how much memory and cache a process is using in order to promptly close processes that are wasting system resources.

# Checking Swap Usage

## Regular Users

```bash
smem -p -s swap
```

??? question "Error with the `smem` command"

	**Reason**
	
	It is possible that `smem` is not able to correctly call the specific version of Python it depends on because you are in a Conda (or other) virtual environment.
	
	**Solution**
	
	For example, in Conda, execute the following command 1-2 times to exit the Conda environment:
	
	```bash
	conda deactivate
	```
	
	Afterwards, you will be able to use the `smem` command to check memory and cache usage.
	

<figure><img src="/assets/linux-smem.png"></figure>

Meaning of the columns in the image:

- PID: The process ID, which is needed to kill a process ([tutorial on how to kill a process](/08-linux/basic/#_10))
- User: The user to whom the process belongs
- Command: The command that triggered the process
- **Swap: Cache usage**
- **USS: Memory usage** (Unique Set Size, the main reference for memory management)
- PSS and RSS: Different ways of calculating memory usage

To check your own Swap and total memory usage:

```bash
smem -p -s swap -u
```

## System Administrators

For system administration tasks, the following commands are often needed:

To check the Swap and memory usage of all users and processes:

```bash
sudo smem -p -s swap
```

To check the total Swap and memory usage of each user:

```bash
sudo smem -p -s swap -u
```

To check the Swap and memory usage of all processes belonging to a specific user:

```bash
sudo smem -p -s swap -U <username>
```

# Adjusting Swap

This section is only for reference by system administrators. Regular users should not attempt to adjust Swap on their own (nor do they have the permissions to do so).

Refer to the [solution for high Swap space usage](/08-linux/system-manage/#_4).