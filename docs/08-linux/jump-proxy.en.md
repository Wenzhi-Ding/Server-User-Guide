We sometimes need to access another server through a single server (e.g., when there is an IP firewall on the application server, you can access all application servers through a jump server with an IP address on the whitelist).

For example, I have server A as a jump server (IP: 100.100.100.100), and server B as an application server (IP: 200.200.200.200). (Using [key-based authentication](pubkey.md) throughout)

In VS Code settings:

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

You can directly use the command: `ssh -J <jump account>@100.100.100.100 -I "<path to private key>" <end user account>@200.200.200.200`

In XShell, you can simply set the "Proxy" option in the session file. In WinSCP, this corresponds to the "Advanced - Tunnel" configuration.
