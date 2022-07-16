推荐使用Git对代码进行版本管理（或备份）。

一般而言服务器都会安装Git。如果发现提示Git未安装，请提示管理员安装。

对于不熟悉Git的用户，推荐使用VSCode编程使用VSCode内置的Git及GitHub插件，可以实现简单的版本管理和代码同步工作。

## Git原理

可以通过该视频了解：[Git工作流和核心原理 | GitHub基本操作 | VS Code里使用Git和关联GitHub](https://www.bilibili.com/video/BV1r3411F7kn)

## 初次使用Git

设置用户名与邮箱：

```bash
git config --global user.name "Forest Gump"
git config --global user.email "fg@gmail.com"
```

以上设置在每台服务器的每个账号仅需要做一次即可，主要用于标识每次修改的提交者的信息。

## 使用Git命令行

### 初始化项目管理

在项目文件夹中初始化Git：

```bash
git init
```

通常由于Git对大文件的支持不佳，我们不管理如大型数据集之类的文件。可以创建`.gitignore`文件并添加如下内容即可忽略掉这些路径下的文件。关于`.gitignore`的详细用法，可以参考GitHub的[教程](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files)。

```
02_rdata
03_wdata
04_result
```

通常Git默认会创建名字为`master`的分支。出于政治正确的考虑，现在GitHub已经转而使用`main`作为默认的分支名。

在本地可以按以下方式重命名分支：

```bash
git branch -m main
```

如果该项目在GitHub、Gitee等网站有对应的远程仓库：

```
git remote add origin git@github.com:XXXX/XXXX.git
git branch --set-upstream-to=origin/main main
```

该地址在GitHub对应项目仓库的Code——Clone——SSH中复制。

### 每次更新内容并提交

添加所有已修改的文件到工作区：

```bash
git add --all
```

将工作区提交到本地仓库：

```bash
git commit -m "Some description"
```

将本地仓库与远程仓库（通常是GitHub上存储的）同步：

```bash
git pull
git push
```

### 其他有用命令

查看当前分支状态：

```bash
git status
```