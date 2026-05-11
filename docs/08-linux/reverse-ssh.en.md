Use reverse SSH tunnels and a jump server to allow internal network users to connect to work servers via a public relay server — **no VPN required, with improved stability**.

**Motivation**: Optimize connection stability and bypass VPN requirements.

## Architecture Overview

```
User PC                     Jump Server (Public)            Work Server (Internal)
                              ┌─────────────────┐
zhangsan ──── ssh ────> :10001│                 │
lisi     ──── ssh ────> :10002│  Reverse Tunnel │──── autossh ────> localhost:22
wangwu   ──── ssh ────> :10003│                 │
                              └─────────────────┘
```

**Core design**:

- systemd template instances `tunnel@port.service` — one independent process per port
- A single port failure does not affect other users
- Adding/removing users = starting/stopping systemd instances, no config file edits needed

| Location | Role | Description |
|----------|------|-------------|
| **Jump server** | Dedicated `tunnel` user, pipe only | One-time setup |
| **Work server** | systemd template + autossh, one instance per port | **User changes happen here** |
| **User PC** | Each connects to a different port | Only needs SSH config |

## Key & Authentication Design

Three types of keys, each with a distinct purpose:

| Key | Holder | Purpose |
|-----|--------|---------|
| **Tunnel key** `tunnel_key` | Work server | autossh authenticates to jump server, establishes reverse tunnel |
| **Management key** `management_key` | Work server | Remotely manage jump server — push/delete user public keys |
| **User key** × N | Each user | Log into work server + ProxyJump through jump server |

The distribution of user public keys is the core of the design — the same public key is written to both servers, serving different purposes:

```
User provides public key to admin
        │
        ▼
    add-user.sh
        │
        ├──> Work server: ~username/.ssh/authorized_keys
        │    (for SSH login)
        │
        └──> Jump server: /home/tunnel/.ssh/authorized_keys
             with restrict,port-forwarding,permitopen="localhost:PORT"
             (restricted to forwarding only to the user's tunnel port)
```

Authentication flow when a user connects:

1. SSH client authenticates to jump server's `tunnel` user using the user's private key (port-forwarding only)
2. Through the tunnel, reaches work server's port 22
3. SSH client authenticates to work server's user account using the same private key

The same user key pair handles both authentication steps.

## Prerequisites

- A server with a public IP to act as the jump server (e.g., a cloud VPS)
- Work server must be able to SSH to the jump server
- Admin needs root access on both servers

## Deployment Steps

### Step 1: Jump Server — One-time Setup

SSH into the jump server and run:

```bash
# Create tunnel user (no shell login)
sudo useradd -m -s /usr/sbin/nologin tunnel
sudo mkdir -p /home/tunnel/.ssh
sudo chmod 700 /home/tunnel/.ssh
```

If using direct-connect mode (not ProxyJump), also add to `/etc/ssh/sshd_config`:

```
GatewayPorts clientspecified
```

Then restart sshd: `sudo systemctl restart sshd`

!!! tip "ProxyJump mode (recommended)"

    In ProxyJump mode, tunnel ports are bound to the jump server's loopback interface only — not exposed to the public internet. This is more secure and recommended for most scenarios.

### Step 2: Work Server — Installation

1. Copy the script directory (containing `setup.sh`, `tunnel.conf`, `tunnel@.service`, etc.) to the work server

2. Edit `tunnel.conf` with your jump server details:

    ```bash
    # tunnel.conf — environment variables for systemd template instances
    RELAY_HOST=203.0.113.50    # Jump server IP or domain
    RELAY_PORT=22               # Jump server SSH port
    RELAY_USER=tunnel           # Tunnel user on jump server

    # Reverse tunnel bind address — leave empty for ProxyJump mode
    BIND_PREFIX=

    # Management key (for pushing/removing user public keys to jump server)
    RELAY_MGMT_USER=root
    MGMT_KEY=/etc/autossh/management_key
    ```

3. Run the setup script:

    ```bash
    sudo ./setup.sh
    ```

    The script automatically:

    - Creates the `tunnel-runner` system user (minimum privilege)
    - Generates tunnel and management keys in `/etc/autossh/`
    - Installs the systemd template to `/etc/systemd/system/`
    - Fetches the jump server's host key
    - Creates the port registry
    - Starts the initial tunnel instance

4. Follow the prompts from the setup script to configure keys on the jump server:

    ```bash
    # On the jump server:

    # 1. Write the tunnel public key (restrict to port-forwarding only)
    echo 'restrict,port-forwarding,permitopen="localhost:22" ssh-ed25519 AAAA... tunnel-main' | \
        sudo tee /home/tunnel/.ssh/authorized_keys

    # 2. Add the management public key to root's authorized_keys
    echo 'ssh-ed25519 AAAA... tunnel-management' | \
        sudo tee -a /root/.ssh/authorized_keys

    # 3. Set permissions
    sudo chown -R tunnel:tunnel /home/tunnel/.ssh
    sudo chmod 600 /home/tunnel/.ssh/authorized_keys
    ```

### Step 3: Verification

```bash
# On the work server, check tunnel status
systemctl status tunnel@10001

# List all tunnel instances
systemctl list-units 'tunnel@*'

# View port registry
cat /etc/autossh/port-registry.txt

# Test connection from outside
ssh my-server
```

## User Management

### Adding a User

```bash
sudo ./add-user.sh zhangsan \
    --key-file /tmp/zhangsan.pub \
    --port 10001 \
    --remark "Researcher"
```

The script automatically:

1. Creates a system user on the work server (if it doesn't exist)
2. Writes the user's public key to `~/.ssh/authorized_keys`
3. Pushes the key to the jump server (with `restrict,port-forwarding,permitopen` restrictions)
4. Updates the port registry `/etc/autossh/port-registry.txt`
5. Starts and enables the systemd tunnel instance

After completion, send this SSH config to the user (replace with actual values):

```
Host my-server
    HostName localhost
    Port 10001
    ProxyJump tunnel@203.0.113.50
    User zhangsan
    ServerAliveInterval 30
```

You can also pass the public key inline:

```bash
sudo ./add-user.sh lisi \
    --key "ssh-ed25519 AAAA... lisi@laptop" \
    --port 10002 \
    --remark "RA"
```

### Removing a User

```bash
# Keep user home directory and data
sudo ./remove-user.sh zhangsan

# Also delete user home directory
sudo ./remove-user.sh zhangsan --delete-home
```

The script will:

1. Stop and disable the tunnel instance for that port
2. Remove the corresponding authorized_keys entry from the jump server (matches `permitopen` port)
3. Remove the record from the port registry

### Pushing / Updating Keys

If you didn't provide a key when adding a user, or need to update it:

```bash
sudo ./push-key.sh zhangsan --key-file /tmp/zhangsan_new.pub
# or
sudo ./push-key.sh zhangsan --key "ssh-ed25519 AAAA... zhangsan@new-laptop"
```

## systemd Template Management

Tunnels use systemd template instances:

```ini
# /etc/systemd/system/tunnel@.service
[Unit]
Description=Reverse SSH Tunnel - port %i
After=network-online.target ssh.service
Wants=network-online.target

[Service]
Type=simple
User=tunnel-runner
EnvironmentFile=/etc/autossh/tunnel.conf
ExecStart=/usr/bin/autossh -M 0 -N \
    -R %i:localhost:22 \
    -o "ServerAliveInterval=30" \
    -o "ServerAliveCountMax=3" \
    -o "Port=${RELAY_PORT}" \
    -o "StrictHostKeyChecking=yes" \
    -o "UserKnownHostsFile=/etc/autossh/known_hosts" \
    -o "ExitOnForwardFailure=yes" \
    -o "IdentitiesOnly=yes" \
    -i /etc/autossh/tunnel_key \
    ${RELAY_USER}@${RELAY_HOST}
Restart=always
RestartSec=10
StartLimitIntervalSec=300
StartLimitBurst=5

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=/etc/autossh
RuntimeDirectory=tunnel-%i

SyslogIdentifier=tunnel@%i
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Common operations:

```bash
systemctl status tunnel@10001       # Check single tunnel status
systemctl restart tunnel@10001      # Restart a tunnel
systemctl stop tunnel@10001         # Stop
systemctl list-units 'tunnel@*'     # List all instances
journalctl -u tunnel@10001 -f       # Follow logs in real-time
```

## Health Monitoring

Set up a cron job to periodically check tunnel health:

```bash
# Check every 5 minutes
*/5 * * * * /opt/tunnel/health-check.sh
```

The health check script iterates through all ports in the registry, checks systemd service status, and logs failures to syslog (tagged `tunnel-health`).

View health logs:

```bash
grep "tunnel-health" /var/log/syslog
```

## Port Registry

Location: `/etc/autossh/port-registry.txt`

```
# Port  Username  Created     Note
10001   zhangsan  2026-01-15  Admin
10002   lisi      2026-01-16  Researcher
10003   wangwu    2026-01-20  Visiting scholar
```

## Security Measures

| Measure | Description |
|---------|-------------|
| systemd template instances | Independent process per port — single failure doesn't affect others |
| Dedicated `tunnel-runner` user | Does not run as root — least privilege principle |
| `restrict` + `permitopen` | Jump server limits tunnel user to port-forwarding only, no shell; even if key is leaked, can only forward to localhost:22 |
| `StrictHostKeyChecking=yes` | Pinned host keys prevent MITM attacks |
| `ExitOnForwardFailure=yes` | Fails immediately if port binding fails |

!!! warning "Impact of jump server compromise"

    An attacker who gains control of the jump server can **reach the work server's SSH port via the tunnel**, but **still needs valid credentials (private key or password) to log in**. SSH connections are end-to-end encrypted; the jump server cannot decrypt or hijack existing sessions.

    Primary risks:

    - Brute-force SSH attacks or vulnerability exploitation against the work server
    - Tunnel disruption causing denial of service

    Mitigation:

    - Keep the jump server minimal
    - Use strong key-based authentication and disable password login on the work server
    - Use iptables to restrict tunnel user access to tunnel ports only:

    ```bash
    sudo iptables -A OUTPUT -p tcp --match multiport --dports 10001:10010 \
        -o lo -m owner ! --uid-owner tunnel -j DROP
    ```

## Connection Mode Comparison

| Mode | Security | Complexity | Description |
|------|----------|------------|-------------|
| **ProxyJump** (recommended) | High | Low | Tunnel ports bound to loopback only; users connect via SSH ProxyJump |
| Direct connect | Lower | Medium | Requires `GatewayPorts=clientspecified`; ports exposed to public |

ProxyJump mode user SSH config example:

```
Host my-server
    HostName localhost
    Port 10001
    ProxyJump tunnel@203.0.113.50
    User zhangsan
    ServerAliveInterval 30
```

For direct-connect mode, set `BIND_PREFIX=0.0.0.0:` in `tunnel.conf` and have users set `HostName` to the jump server address directly.

!!! tip "Server already has a public IP?"

    If the target server already has a public IP and you just need to bounce through a jump server for IP whitelisting, you don't need a reverse tunnel. Use standard SSH ProxyJump directly:

    ```
    Host jump-server
        HostName 100.100.100.100
        User <jump account>
        IdentityFile "<path to private key>"

    Host work-server
        HostName 200.200.200.200
        User <target account>
        IdentityFile "<path to private key>"
        ProxyJump jump-server
    ```

    CLI equivalent: `ssh -J jump-account@100.100.100.100 target-account@200.200.200.200`

## Script Source Code

The following scripts are from a real deployment. Adapt service names, relay server addresses, etc. to your environment.

??? note "tunnel.conf — Configuration file"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/tunnel.conf"
    ```

??? note "setup.sh — Initial setup"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/setup.sh"
    ```

??? note "add-user.sh — Add user"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/add-user.sh"
    ```

??? note "remove-user.sh — Remove user"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/remove-user.sh"
    ```

??? note "push-key.sh — Push/update public key"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/push-key.sh"
    ```

??? note "health-check.sh — Health check (cron)"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/health-check.sh"
    ```

??? note "polyu-tunnel@.service — systemd template"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/polyu-tunnel@.service"
    ```

??? note "client_ssh_config — Client SSH config template"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/client_ssh_config"
    ```
