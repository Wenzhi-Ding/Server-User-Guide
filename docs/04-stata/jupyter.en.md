Currently, there are two mainstream solutions for using Stata in Jupyter Lab:

1. PyStata, provided by Stata, allows calling Stata in a Python notebook with the Python kernel.
   * Pros: It integrates closely with Python, allowing direct input of Python data into Stata. After running Stata's statistical commands, the results can be extracted back to Python for further processing.
   * Cons: Syntax highlighting is not currently supported.
   * Example: [PyStata Example](pystata.ipynb)

2. Kyle Barron's [Stata Kernel](https://kylebarron.dev/stata_kernel/).
   * Pros: It provides a native Stata experience and supports syntax highlighting.
   * Cons: It can only use Stata's inflexible export methods.
   * Example: [Stata Kernel Example](stata_kernel.ipynb)

Based on personal experience, if there is no need to process data specifically with Python, using the Stata Kernel provides a better experience.

## 1. PyStata

Refer to the [official tutorial](https://www.stata.com/python/pystata/).

## 2. Stata Kernel

Refer to Kyle Barron's tutorials:

- [Installation](https://kylebarron.dev/stata_kernel/getting_started/)
- [Configuration](https://kylebarron.dev/stata_kernel/using_stata_kernel/configuration/)
- [Magic Commands](https://kylebarron.dev/stata_kernel/using_stata_kernel/magics/)

!!! note "Stata's location needs to be specified during the configuration process"

    Typically, depending on the installed version, the specific executable file location of Stata on a Linux system is as follows:
    
    MP version:
    
    ```bash
    /usr/local/stata17/stata-mp
    ```
    
    BE or SE version:
    
    ```bash
    /usr/local/stata17/stata
    ```