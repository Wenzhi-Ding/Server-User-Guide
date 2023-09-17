## Running DO Files

Assuming the uploaded DO file is `reg.do`. You can directly run `reg.do` by executing the following code:

```bash
stata-mp reg.do
```

Please make sure to correctly set the paths for input and output files.

??? question "Is it `stata-mp` or `stata`?"

	`stata-mp` corresponds to Stata's MP version (multi-core version), which has faster execution speed (and a higher price).
	
	`stata` corresponds to Stata's SE version (single-core version).
	
	It is generally recommended to use `stata-mp` by default.

??? question "Getting `command not found` error"

	<figure><img src="/assets/stata-not-found.png"></figure>
	
	**Cause**
	
	1. The Stata application has not been added to the `PATH` environment variable.
	2. Stata is not installed on this server.
	
	**Solution**
	
	Please contact the administrator to install Stata and create a symbolic link to the executable in `/usr/bin`.

## Logging Stata Output (LOG)

Suppose we want to save all the output from Stata during its execution to the file `/home/user/project/log.smcl`. Simply add the following code at the beginning of the DO file.
	
If you want to replace the existing log file with each run:

```stata
log using "/home/user/project/log.smcl", replace smcl
set linesize 255
```

If you want to append the log from each run to the existing log file:

```stata
log using "/home/user/project/log.smcl", append smcl
set linesize 255
```

Note that SMCL is a Stata-specific log format that needs to be opened with Stata. You can also output in TXT format:

```stata
log using "/home/user/project/log.txt", append txt
set linesize 255
```

## Running Stata in the Background

If you don't need to see the results in the SSH terminal and only want to view the log file after the code has finished running, you can use the following command:

```bash
stata-mp -b reg.do
```

It is recommended to combine this approach with the "Logging Stata Output" method mentioned above.