# Server User Guide

This manual provides multiple usage guides from basic to advanced.

Please click translate button at the top of the page to view this site in other languages.

The English version is contributed by [Nikhil](https://github.com/nikhil-nix). Contents are synced to 17/09/2023.

## User Feedback

If you encounter any of the following during the use of the server:

1. Issues not covered in this guide;
2. Problems that cannot be quickly resolved in the guide.

Please contact Wenzhi Ding (WeChat, Slack, or email) or [submit issues on GitHub](https://github.com/Wenzhi-Ding/Server-User-Guide/issues). He will help resolve them and update this guide.

Feel free to directly edit the page and [submit pull requests on GitHub](https://github.com/Wenzhi-Ding/Server-User-Guide/pulls)!

If you see a section in the guide that requires contacting an "administrator" but you don't understand its meaning, you can ignore it. These requirements only apply to certain servers.



## Quick Table of Contents

### Necessary Steps

!!! warning "Please complete these steps"

    For users of this center's server, please make sure to browse through these two sections before proceeding with other operations.

- [Connecting to the Server](01-connect/win.md)
- [Basic Linux Commands](08-linux/basic.md)

### Recommended Steps

If you plan to use Python or Jupyter, please refer to:

- [uv](02-uv/install.md)
- [Jupyter Lab](03-jupyter/install.md)

Stata and SAS can also be used through the above methods.

- [Using Stata in Jupyter](04-stata/jupyter.md)
- [Using SAS in Jupyter](05-sas/jupyter.md)

If you only plan to use Stata or SAS lightly, you can refer to:

||Stata|SAS|
|:-|:-|:-|
|Not writing code on the server|[Stata Command Line](04-stata/command-line.md)|[SAS Command Line](05-sas/command-line.md)|
|Need to view data and write code on the server|[Stata GUI](04-stata/gui.md)|[SAS GUI](05-sas/gui.md)|

### Other Recommended Readings

- Program interruption after network disconnection: [Stable Running of Programs in the Background on Linux](08-linux/screen.md)
- Server crash: [Avoiding Excessive Resource Usage](08-linux/smem.md)
- Need a graphical interface for operation: [Linux's Graphical Interface](08-linux/gui.md)
- Other reference: [How to use servers? - Seasoning - Zhihu](https://www.zhihu.com/question/506241986/answer/3457669268)