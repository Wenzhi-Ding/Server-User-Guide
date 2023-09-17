## Windows

If you want to use certain programs (such as Stata, SAS) on a server in a graphical interface on Windows, there are two solutions.

### Xmanager

After installing [Xmanager](https://www.netsarang.com), which is compatible with Xshell, you can automatically bring up the graphical interface by using the relevant commands in Xshell.

Please note that Xmanager does not have an official free version, so you may need to consider purchasing it from relevant channels if you want to use it.

### Xming

[Xming](https://en.wikipedia.org/wiki/Xming) needs to be used in conjunction with PuTTY.

1) Download the Xming client from [here](https://sourceforge.net/projects/xming/) and install it.

2) Launch Xming.

3) When connecting to the server in PuTTY, add the `-X` parameter to the SSH command, like this:

```bash
ssh -X <username>@<host>
```

4) Use the relevant commands to bring up the graphical interface through Xming.

??? question "Graphical interface error, failed to start properly"

    **Cause**

    This may be due to conflicting port usage.

    **Solution**

    Completely exit all PuTTY and Xming instances, and then restart them.

## macOS

On macOS, you need to use [XQuartz](https://en.wikipedia.org/wiki/XQuartz) in conjunction with Terminal.

1) Download the XQuartz client from [here](https://www.xquartz.org/) and install it.

2) Launch XQuartz.

3) When connecting to the server in Terminal, add the `-X` parameter to the SSH command, like this:

```bash
ssh -X <username>@<host>
```

4) Use the relevant commands to bring up the graphical interface through XQuartz.

??? question "Graphical interface error, failed to start properly"

    **Cause**

    This may be due to conflicting port usage.

    **Solution**

Completely exit all Terminal and XQuartz instances, and then restart them.