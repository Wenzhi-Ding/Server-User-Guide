Shared directories can be created on the server, for example `/home/shared/<project_name>`. Only authorized users can read and write these paths. Unauthorized users cannot browse or download files within them, so you can use them with confidence.

## Admin: Configuring Directory Permissions

This section is for administrator reference. Permission management is based on POSIX ACLs, using a JSON configuration file as the single source of truth, with scripts to apply permissions in bulk.

### Configuration File

`permissions.json` declares each user's read-only (ro) or read-write (rw) access to specific paths:

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

### apply.sh — Apply Permissions

Syncs ACL rules based on `permissions.json`. Supports incremental updates (diff only) and full rebuilds.

```bash
# Usage
sudo bash apply.sh                # Incremental update
sudo bash apply.sh --full         # Full rebuild
sudo bash apply.sh --dry-run      # Preview changes without applying
```

??? note "apply.sh source"

    ```bash
    --8<-- "docs/snippets/team/apply.sh"
    ```

### show.sh — View Permissions

Shows a user's effective ACL permissions, comparing configured values with actually effective values.

```bash
# Usage
bash show.sh <username>    # View a specific user
bash show.sh               # View all users
```

??? note "show.sh source"

    ```bash
    --8<-- "docs/snippets/team/show.sh"
    ```

### test.sh — Verify Permissions

Verifies that ACL permission boundaries match `permissions.json`. Tests include: positive access on authorized paths, system directory denial, home directory isolation, unauthorized path denial, etc.

```bash
# Usage
sudo bash test.sh
```

??? note "test.sh source"

    ```bash
    --8<-- "docs/snippets/team/test.sh"
    ```

### FAQ

??? question "How to revoke a user's access?"

    Remove the user's entry from `permissions.json` and re-run `apply.sh`. The script will automatically revoke all ACL entries for that user.
