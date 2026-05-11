服务器上可以创建共享目录，比如 `/home/shared/<project_name>`。只有被授权的用户才能读写这些路径，未授权的用户无法浏览或下载其中的文件，可以放心使用。

## 管理员：配置目录权限

此部分供管理员参考。权限管理基于 POSIX ACL，通过一个 JSON 配置文件作为单一数据源，配合脚本批量应用。

### 配置文件

`permissions.json` 声明每个用户对哪些路径拥有读权限（ro）或读写权限（rw）：

```json
{
  "user_a": {
    "rw": ["/home/shared/project_x"],
    "ro": ["/home/data/dataset_a"]
  },
  "user_b": {
    "rw": ["/home/shared/project_x"],
    "ro": []
  }
}
```

### apply.sh — 应用权限

根据 `permissions.json` 同步 ACL 规则。支持增量更新（仅应用差异）和完整重建。

```bash
# 用法
sudo bash apply.sh                # 增量更新
sudo bash apply.sh --full         # 完整重建
sudo bash apply.sh --dry-run      # 预览变更但不应用
```

??? note "apply.sh 源码"

    ```bash
    --8<-- "docs/snippets/team/apply.sh"
    ```

### show.sh — 查看权限

查看指定用户的实际 ACL 权限，同时显示配置值与实际生效值的对比。

```bash
# 用法
bash show.sh <username>    # 查看指定用户
bash show.sh               # 查看所有用户
```

??? note "show.sh 源码"

    ```bash
    --8<-- "docs/snippets/team/show.sh"
    ```

### test.sh — 验证权限

验证 ACL 权限边界是否与 `permissions.json` 一致。测试项包括：授权路径的正向访问、系统目录拒绝、家目录隔离、未授权路径拒绝等。

```bash
# 用法
sudo bash test.sh
```

??? note "test.sh 源码"

    ```bash
    --8<-- "docs/snippets/team/test.sh"
    ```

### 常见问题

??? question "如何取消某个用户的访问？"

    从 `permissions.json` 中移除该用户的条目，重新运行 `apply.sh`。脚本会自动撤销该用户的所有 ACL 条目。
