It is recommended to use Git for code version management (or backup).

Generally, servers are usually installed with Git. If you find that Git is not installed, please prompt the administrator to install it.

For users who are not familiar with Git, it is recommended to use VSCode programming with the built-in Git and GitHub plugins, which can achieve simple version management and code synchronization.

## Git Principles

You can learn more about it through this video: [Git Workflow and Core Principles | Basic GitHub Operations | Using Git and GitHub in VS Code](https://www.bilibili.com/video/BV1r3411F7kn)

## First-time Use of Git

Set your username and email:

```bash
git config --global user.name "Forest Gump"
git config --global user.email "fg@gmail.com"
```

These settings only need to be done once for each account on each server, and they are mainly used to identify the information of the committer for each modification.

## Using Git Command Line

### Initializing Project Management

Initialize Git in the project folder:

```bash
git init
```

Usually, because Git does not support large files well, we do not manage files such as large datasets. You can create a `.gitignore` file and add the following content to ignore files in these paths. For detailed usage of `.gitignore`, you can refer to the tutorial on GitHub [here](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files).

```bash
02_rdata
03_wdata
04_result
```

By default, Git usually creates a branch named `master`. For politically correct reasons, GitHub has now switched to using `main` as the default branch name.

You can rename the branch locally as follows:

```bash
git branch -m main
```

If the project has a corresponding remote repository on websites like GitHub or Gitee:

```bash
git remote add origin git@github.com:XXXX/XXXX.git
git branch --set-upstream-to=origin/main main
```

You can copy this address from the Code - Clone - SSH section of the corresponding project repository on GitHub.

### Updating Content and Committing

Add all modified files to the working area:

```bash
git add --all
```

Commit the working area to the local repository:

```bash
git commit -m "Some description"
```

Synchronize the local repository with the remote repository (usually stored on GitHub):

```bash
git pull
git push
```

### Other Useful Commands

Check the current branch status:

```bash
git status
```