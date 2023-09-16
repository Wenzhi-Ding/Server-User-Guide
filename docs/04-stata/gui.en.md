!!! Prerequisites

    To use the graphical interface of Stata, you need to first configure X11.

    - [Windows](/en/08-linux/gui/#windows)
    - [macOS](/en/08-linux/gui/#macos)

After connecting to the SSH terminal, you can access the Stata graphical interface by entering the following command. However, please note that this interface requires a high internet speed and network stability. If the server is located in Hong Kong, it is not recommended to use this method outside of Hong Kong as the interface refresh will be very slow.

```bash
xstata-mp
```

<figure><img src="/assets/stata-gui.png"></figure>

??? question "Is it `xstata-mp` or `xstata`?"

    `xstata-mp` corresponds to the MP version (multi-core version) of Stata, which has faster processing speed (and a higher price).

    `xstata` corresponds to the SE version (single-core version) of Stata.

    It is generally recommended to use `xstata-mp` by default.

??? question "Getting `command not found` error"

    <figure><img src="/assets/stata-not-found.png"></figure>

    **Reasons**

    1. The Stata application has not been added to the `PATH` environment variable.
    2. Stata is not installed on this server.

    **Solution**

    Please contact the administrator to install Stata and create a symbolic link to the executable file in `/usr/bin`.