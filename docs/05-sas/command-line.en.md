Assuming the uploaded SAS code file is named `export.sas`. To directly run `export.sas`, execute the following code:

```bash
sas export.sas
```

Please make sure to correctly set the paths for the input and output files.

??? question "Getting `command not found` error"
	
	**Reasons**
	
	1. The SAS application has not been added to the `PATH` environment variable.
	2. SAS is not installed on this server.
	
	**Solution**
	
	Please contact the administrator to install SAS and create a symbolic link to the executable file in `/usr/bin`.