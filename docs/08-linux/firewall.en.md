To manage access from specific IP addresses, the server can use the `ufw` and `/etc/hosts.allow` methods. Additionally, it can enhance security by combining it with [public key authentication](/08-linux/pubkey/).

## Whitelist

By adding IP addresses to `/etc/hosts.allow` and modifying `ufw`, certain specific IP addresses can be allowed to access the server.

```bash
sudo ufw allow from x.x.x.x/xx to any port 22 proto tcp
```

This can be automated using a Python script.

To add IP addresses to the whitelist:

```bash
python whitelist.py A <IP1> <IP2> ...
```

To remove IP addresses from the whitelist:

```bash
python whitelist.py D <IP1> <IP2> ...
```

Here is the script:

```python
import os
import sys
import ipaddress
from os.path import expanduser
home = expanduser("~")

action = sys.argv[1]
if action not in ['A', 'D']:
    raise ValueError('Script should be called as "python whitelist.py A|D <IP1> <IP2> ...". A - add, D - delete.')

input_ips = set(sys.argv[2:])
add_ips = set()

for ip in input_ips:  # Standardize IP format
    ip = ip.split('/')[0]
    _ = ipaddress.ip_address(ip)
    if ip.endswith('.0.0.0'):
        ip += '/8'
    elif ip.endswith('.0.0'):
        ip += '/16'
    elif ip.endswith('.0'):
        ip += '/24'
    else:
        ip += '/32'
    add_ips.add(ip)

# Read allowed IPs
with open('/etc/hosts.allow', 'r') as f:
    lines = f.readlines()

# Add new IPs
new_lines = []
for line in lines:
    if line.startswith('ALL:'):
        line = line.replace('ALL:', '').replace(' ', '').strip().split(',')
        # print(line)
        if action == "A": ips = set(line) | add_ips
        else: ips = set(line) - add_ips
        new_lines.append(f'ALL:{",".join(ips)}\n')
    else:
        new_lines.append(line)

with open(f'{home}/hosts.allow.tmp', 'w') as f:
    f.write(''.join(new_lines))

os.system('sudo cp /etc/hosts.allow /etc/hosts.allow.bak')
os.system(f'sudo cp {home}/hosts.allow.tmp /etc/hosts.allow')
os.system(f'sudo rm {home}/hosts.allow.tmp')

# Add new IPs to firewall
for ip in add_ips:
    if action == "A": os.system(f'sudo ufw allow from {ip} to any port 22 proto tcp')
    else: os.system(f'sudo ufw delete allow from {ip} to any port 22 proto tcp')

os.system('sudo ufw reload')
```