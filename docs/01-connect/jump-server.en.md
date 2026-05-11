If your team has set up a jump server (reverse SSH tunnel), you can connect to the work server through it — no VPN required, with a more stable connection.

If you don't know how to connect to the server yet, please follow the [Windows](win.md) or [macOS](mac.md) guide first.

## Preparation

You need to send your SSH public key to the admin. The admin will configure it on both the jump server and the target server so you can connect through the jump server to the target.

If you already have an SSH key pair (see [Passwordless Login](../08-linux/pubkey.md)), your public key is typically at:

- Linux / macOS / WSL: `~/.ssh/id_rsa.pub` or `~/.ssh/id_ed25519.pub`
- Windows: `C:\Users\YourUsername\.ssh\id_rsa.pub`

Send the contents of the public key file to the admin.

Also ask the admin for the following connection details:

| Item | Example | Description |
|------|---------|-------------|
| Jump server address | `203.0.113.50` | Public IP or domain name |
| Tunnel username | `tunnel` | Always `tunnel`, no need to change |
| Your tunnel port | `10001` | A unique port assigned by admin |
| Your server username | `zhangsan` | Your account on the target server |

## Configure SSH Connection

Edit `~/.ssh/config` and add the following (replace port and username with what admin provided):

```
Host my-server
    HostName localhost
    Port 10001
    ProxyJump tunnel@203.0.113.50
    User zhangsan
    ServerAliveInterval 30
```

Where:

- `my-server`: A custom alias; connect with `ssh my-server`
- `Port`: Your tunnel port assigned by admin (not 22)
- `ProxyJump`: Jump server address and tunnel user (always `tunnel`)
- `User`: Your username on the target server
- `ServerAliveInterval 30`: Sends a keep-alive every 30 seconds

!!! tip "VS Code users"

    VS Code Remote SSH uses the same `~/.ssh/config` file. After configuring, click "Remote Explorer" in the left sidebar to see the host.

Save the file, then run in the terminal:

```bash
ssh my-server
```

On first connection, you'll be prompted to accept the server fingerprint — type `yes`.

## WinSCP Configuration

WinSCP connects through the jump server via SSH tunnel. The tunnel and target server authentication are configured separately in advanced settings.

1. Open WinSCP and set up the login:
    - File protocol: `SFTP`
    - Host name: `localhost`
    - Port number: Your tunnel port (e.g., `10001`)
    - User name: Your server username (e.g., `zhangsan`)

2. Click "Advanced..." to open advanced site settings

3. Configure the tunnel (jump server): select "Connection → Tunnel" on the left
    - Check "Connect through SSH tunnel"
    - Host name: Jump server address (e.g., `203.0.113.50`)
    - Port number: `22`
    - User name: `tunnel`
    - Private key file: Select your private key file (if prompted to convert to `.ppk` format, accept it)

4. Configure main connection authentication: select "SSH → Authentication" on the left
    - Private key file: Select your private key file (accept the format conversion prompt as well)

5. Click "OK" to save, then click "Login" to connect
