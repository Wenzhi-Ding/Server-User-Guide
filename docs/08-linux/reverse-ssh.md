通过反向 SSH 隧道和跳板服务器，让内网用户无需 VPN 即可通过公网中转服务器稳定连接工作服务器。

**动机**：优化连接稳定性，绕开 VPN 连接要求。

## 架构概述

```
用户电脑                    跳板服务器 (公网)              工作服务器 (内网)
                              ┌─────────────┐
zhangsan ──── ssh ────> :10001│             │
lisi     ──── ssh ────> :10002│  反向隧道    │──── autossh ────> localhost:22
wangwu   ──── ssh ────> :10003│             │
                              └─────────────┘
```

**核心设计**：

- systemd 模板实例 `tunnel@端口.service`，每个端口一个独立进程
- 单个端口故障不影响其他用户
- 增删用户只需启停对应的 systemd 实例，无需编辑配置文件

| 位置 | 角色 | 说明 |
|------|------|------|
| **跳板服务器** | 专用 `tunnel` 用户，纯管道 | 一次性配置，后续不动 |
| **工作服务器** | systemd 模板 + autossh，每端口一个实例 | **增减用户只在此操作** |
| **用户电脑** | 各连不同端口，用各自账户登录 | 只需配置 SSH config |

## 密钥与认证设计

系统中有三类密钥，各司其职：

| 密钥 | 持有者 | 用途 |
|------|--------|------|
| **隧道密钥** `tunnel_key` | 工作服务器 | autossh 认证到跳板服务器，建立反向隧道 |
| **管理密钥** `management_key` | 工作服务器 | 远程操作跳板服务器，推送/删除用户公钥 |
| **用户密钥** × N | 各用户自己 | 登录工作服务器 + ProxyJump 经过跳板 |

用户公钥的分发是整个设计的核心——同一把公钥写入两台服务器，作用不同：

```
用户提供公钥给管理员
        │
        ▼
    add-user.sh
        │
        ├──> 工作服务器: ~用户名/.ssh/authorized_keys
        │    （用于 SSH 登录）
        │
        └──> 跳板服务器: /home/tunnel/.ssh/authorized_keys
             加 restrict,port-forwarding,permitopen="localhost:端口"
             （限制为仅能转发到该用户的隧道端口）
```

用户连接时的认证流程：

1. SSH 客户端用用户私钥认证到跳板服务器的 `tunnel` 用户（仅允许端口转发）
2. 通过隧道到达工作服务器的 22 端口
3. SSH 客户端用同一个私钥认证到工作服务器的用户账户

整个过程使用同一把用户密钥完成两次认证。

## 前置条件

- 一台具有公网 IP 的服务器作为跳板（如云服务器）
- 工作服务器能通过 SSH 连接到跳板服务器
- 管理员具有两台服务器的 root 权限

## 部署步骤

### 第一步：跳板服务器 — 一次性配置

SSH 登录跳板服务器，执行以下操作：

```bash
# 创建 tunnel 用户（无 shell 登录权限）
sudo useradd -m -s /usr/sbin/nologin tunnel
sudo mkdir -p /home/tunnel/.ssh
sudo chmod 700 /home/tunnel/.ssh
```

如果使用直连模式（非 ProxyJump），还需要在 `/etc/ssh/sshd_config` 中添加：

```
GatewayPorts clientspecified
```

然后重启 sshd：`sudo systemctl restart sshd`

!!! tip "ProxyJump 模式（推荐）"

    ProxyJump 模式下隧道端口仅绑定跳板服务器的 loopback 接口，不暴露公网，更安全。大多数场景推荐此模式。

### 第二步：工作服务器 — 安装

1. 将脚本目录（含 `setup.sh`、`tunnel.conf`、`tunnel@.service` 等）复制到工作服务器

2. 编辑 `tunnel.conf`，填写跳板服务器信息：

    ```bash
    # tunnel.conf — systemd 模板实例的环境变量
    RELAY_HOST=203.0.113.50    # 跳板服务器 IP 或域名
    RELAY_PORT=22               # 跳板服务器 SSH 端口
    RELAY_USER=tunnel           # 跳板服务器上的隧道用户

    # 反向隧道绑定地址 — 留空使用 ProxyJump 模式
    BIND_PREFIX=

    # 管理密钥（用于推送/删除用户公钥到跳板服务器）
    RELAY_MGMT_USER=root
    MGMT_KEY=/etc/autossh/management_key
    ```

3. 运行安装脚本：

    ```bash
    sudo ./setup.sh
    ```

    脚本会自动完成：

    - 创建 `tunnel-runner` 系统用户（最小权限运行隧道）
    - 在 `/etc/autossh/` 生成隧道密钥和管理密钥
    - 安装 systemd 模板到 `/etc/systemd/system/`
    - 获取跳板服务器的主机密钥
    - 创建端口分配表
    - 启动初始隧道实例

4. 按照安装脚本输出的提示，在跳板服务器上完成密钥配置：

    ```bash
    # 在跳板服务器上执行

    # 1. 写入隧道公钥（restrict 限制为仅端口转发）
    echo 'restrict,port-forwarding,permitopen="localhost:22" ssh-ed25519 AAAA... tunnel-main' | \
        sudo tee /home/tunnel/.ssh/authorized_keys

    # 2. 将管理公钥加入 root 的 authorized_keys（用于远程推送用户公钥）
    echo 'ssh-ed25519 AAAA... tunnel-management' | \
        sudo tee -a /root/.ssh/authorized_keys

    # 3. 设置权限
    sudo chown -R tunnel:tunnel /home/tunnel/.ssh
    sudo chmod 600 /home/tunnel/.ssh/authorized_keys
    ```

### 第三步：验证

```bash
# 在工作服务器上检查隧道状态
systemctl status tunnel@10001

# 查看所有隧道实例
systemctl list-units 'tunnel@*'

# 查看端口分配表
cat /etc/autossh/port-registry.txt

# 从外部连接测试
ssh my-server
```

## 用户管理

### 添加用户

```bash
sudo ./add-user.sh zhangsan \
    --key-file /tmp/zhangsan.pub \
    --port 10001 \
    --remark "研究人员"
```

脚本会自动完成以下操作：

1. 在工作服务器创建系统用户（如不存在）
2. 写入用户公钥到 `~/.ssh/authorized_keys`
3. 通过管理密钥将公钥推送到跳板服务器（带 `restrict,port-forwarding,permitopen` 限制）
4. 更新端口分配表 `/etc/autossh/port-registry.txt`
5. 启动并启用对应的 systemd 隧道实例

完成后，将以下 SSH 配置发给用户（请替换实际信息）：

```
Host my-server
    HostName localhost
    Port 10001
    ProxyJump tunnel@203.0.113.50
    User zhangsan
    ServerAliveInterval 30
```

也可以通过 `--key` 参数直接传入公钥字符串：

```bash
sudo ./add-user.sh lisi \
    --key "ssh-ed25519 AAAA... lisi@laptop" \
    --port 10002 \
    --remark "RA"
```

### 删除用户

```bash
# 保留用户主目录和数据
sudo ./remove-user.sh zhangsan

# 同时删除用户主目录
sudo ./remove-user.sh zhangsan --delete-home
```

脚本会执行：

1. 停止并禁用该端口的隧道实例
2. 从跳板服务器删除对应的 authorized_keys 条目（匹配 `permitopen` 端口）
3. 从端口分配表移除记录

### 单独推送/更新公钥

如果添加用户时未提供密钥，或需要更新密钥：

```bash
sudo ./push-key.sh zhangsan --key-file /tmp/zhangsan_new.pub
# 或
sudo ./push-key.sh zhangsan --key "ssh-ed25519 AAAA... zhangsan@new-laptop"
```

## systemd 模板管理

隧道使用 systemd 模板实例管理，定义如下：

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

# 安全加固
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

常用操作：

```bash
systemctl status tunnel@10001       # 查看单个隧道状态
systemctl restart tunnel@10001      # 重启单个隧道
systemctl stop tunnel@10001         # 停止
systemctl list-units 'tunnel@*'     # 查看所有实例
journalctl -u tunnel@10001 -f       # 实时查看日志
```

## 健康监控

建议配置 cron 定期检查隧道状态：

```bash
# 每 5 分钟检查一次
*/5 * * * * /opt/tunnel/health-check.sh
```

健康检查脚本会遍历端口分配表中的所有实例，检查 systemd 服务状态，并将故障信息写入 syslog（`polyu-tunnel-health` 标签）。

查看健康日志：

```bash
grep "polyu-tunnel-health" /var/log/syslog
```

## 端口分配表

位置：`/etc/autossh/port-registry.txt`

```
# 端口  用户名   创建日期     备注
10001   zhangsan 2026-01-15  管理员
10002   lisi     2026-01-16  研究员
10003   wangwu   2026-01-20  访问学者
```

## 安全措施

| 措施 | 说明 |
|------|------|
| systemd 模板实例 | 每端口独立进程，单点故障不影响他人 |
| 专用系统用户 `tunnel-runner` | 不以 root 运行，最小权限原则 |
| `restrict` + `permitopen` | 跳板服务器限制 tunnel 用户仅可端口转发，无法开 shell；即使密钥泄露也只能转发到 localhost:22 |
| `StrictHostKeyChecking=yes` | 预存主机密钥，防止中间人攻击 |
| `ExitOnForwardFailure=yes` | 端口绑定失败立即报错，不静默运行 |

!!! warning "跳板服务器被攻破的影响"

    攻击者获得跳板服务器控制权后，可以**通过网络直连工作服务器的 SSH 端口**，但**仍需有效的账户凭证（私钥或密码）才能登录**。SSH 连接是端到端加密的，跳板无法解密或劫持已有会话。

    主要风险：

    - 攻击者可对工作服务器进行 SSH 暴力破解或漏洞利用
    - 可中断隧道造成拒绝服务

    缓解措施：

    - 跳板服务器保持最小化部署
    - 工作服务器使用强密钥认证并禁用密码登录
    - 使用 iptables 限制 tunnel 用户只能访问隧道端口：

    ```bash
    sudo iptables -A OUTPUT -p tcp --match multiport --dports 10001:10010 \
        -o lo -m owner ! --uid-owner tunnel -j DROP
    ```

## 连接模式对比

| 模式 | 安全性 | 配置复杂度 | 说明 |
|------|--------|------------|------|
| **ProxyJump**（推荐） | 高 | 低 | 隧道端口仅绑定 loopback，用户通过 SSH ProxyJump 中转 |
| 直连 | 较低 | 中 | 需开启 `GatewayPorts=clientspecified`，端口暴露公网 |

ProxyJump 模式下用户 SSH config 示例：

```
Host my-server
    HostName localhost
    Port 10001
    ProxyJump tunnel@203.0.113.50
    User zhangsan
    ServerAliveInterval 30
```

直连模式需将 `tunnel.conf` 中 `BIND_PREFIX` 改为 `0.0.0.0:`，用户 SSH config 中 `HostName` 直接填跳板服务器地址。

!!! tip "服务器本身有公网 IP？"

    如果目标服务器本身有公网 IP，只是需要通过跳板来绕过 IP 白名单，不需要反向隧道。直接用标准 SSH ProxyJump 即可：

    ```
    Host jump-server
        HostName 100.100.100.100
        User <跳板账户>
        IdentityFile "<私钥路径>"

    Host work-server
        HostName 200.200.200.200
        User <目标账户>
        IdentityFile "<私钥路径>"
        ProxyJump jump-server
    ```

    命令行等价写法：`ssh -J 跳板账户@100.100.100.100 目标账户@200.200.200.200`

## 脚本源码

以下脚本取自实际部署，已脱敏。请根据实际环境修改服务名称、跳板服务器地址等。

??? note "setup.sh — 首次安装"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/setup.sh"
    ```

??? note "add-user.sh — 添加用户"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/add-user.sh"
    ```

??? note "remove-user.sh — 删除用户"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/remove-user.sh"
    ```

??? note "push-key.sh — 推送/更新公钥"

    ```bash
    --8<-- "docs/08-linux/_tunnel_scripts/push-key.sh"
    ```
