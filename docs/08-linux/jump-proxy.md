我们有时会有需求通过一台服务器来访问另一台服务器（比如在应用服务器有 IP 防火墙时，可以通过 IP 地址在白名单中的一台跳板服务器来访问所有应用服务器）。

比如我有服务器 A 作为跳板（IP 为 100.100.100.100），服务器 B 作为应用（IP 为 200.200.200.200）。（全程使用[密钥登录](/08-linux/pubkey)）

在 VS Code 中的设置：

```
Host jump-server
  HostName 100.100.100.100
  User <jump account>
  IdentityFile "<path to private key>"

Host work-server
  HostName 200.200.200.200
  User <end user account>
  IdentityFile "<path to private key>"
  JumpProxy jump-server
```

在命令行中可以直接：`ssh -J <jump account>@100.100.100.100 -I "<path to private key>" <end user account>@200.200.200.200`

在 XShell 中设置会话文件的“代理”一项即可。在 WinSCP 中则对应配置中的“高级——隧道”。