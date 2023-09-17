Usually, when we simply edit scripts or configuration files, we don't use SFTP to download, edit, and then upload and overwrite. We can use the Vim editor for editing.

Vim has a certain learning curve and operates differently from conventional text editors. Please refer to this tutorial: [link](https://www.bilibili.com/video/BV13t4y1t7Wg).

Here are some basic operations (highlighted ones must be learned before using Vim) to avoid getting stuck in Vim without being able to exit.

1) Open a file:

```bash
vim run.py
```

2) Some operations in normal mode:

- Arrow keys: Navigation
- `h`: Move left
- `j`: Move down
- `k`: Move up
- `l`: Move right
- `w`: Move to the beginning of the next word
- `e`: Move to the end of the next word
- `b`: Move to the beginning of the previous word
- `gg`: Move to the top
- `G`: Move to the end
- `yy`: Copy the current line
- `yw`: Copy a word
- `p`: Paste
- `2p`: Paste twice
- `dd`: Delete the current line
- `.`: Repeat the previous operation
- `u`: Undo the previous operation
- `ctrl+r`: Redo the previous operation
- `:%s/old str/new str/g`: Global replace

3) Enter insert mode:

- `i`: Insert before the current character
- `I`: Insert at the beginning of the line
- `a`: Insert after the current character
- `A`: Insert at the end of the line
- `o`: Insert a new line below
- `O`: Insert a new line above
- `ci{`: Delete the content inside the `{` brackets and enter insert mode

4) Press `Esc` to exit insert mode, and enter the following to exit:

- `:wq`: Save and exit
- `:q!`: Force exit

Note that the colon `:` is necessary.