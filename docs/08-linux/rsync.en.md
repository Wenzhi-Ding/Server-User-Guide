Occasionally, we have a need to synchronize data between servers, such as:

- Synchronizing data between two servers in the same center
- Downloading data from data providers like WRDS

## SSH & SFTP

For servers that allow SSH login, we recommend using SFTP and the `rsync` command to accomplish this task.

??? question "What are the advantages of `rsync` compared to other transfer methods?"

	The `rsync -avuz` command can automatically compare the modification dates of files, skip those that haven't been modified, and avoid wasting time and bandwidth on full updates every time. Additionally, it automatically compresses, transfers, and decompresses files, greatly improving synchronization speed.

Let's take the example of downloading SDC New Issues data from WRDS. The specific process is as follows:

1) First, log in to the data source server (`source`) via SFTP and determine the path of the data.

<figure><img src="/assets/rsync-sftp.png"></figure>

Copy the data path:

```bash
/wrdslin/tfn/sasdata/sdc_ni
```

2) Set the local path to receive this data, such as `/data/dataset/sdc`.

3) Synchronize using the following command:

```bash
rsync -avuz <username>@<remote_host>:/wrdslin/tfn/sasdata/sdc_ni/* /data/dataset/sdc
```

Generally, after executing this command, you will be prompted to enter a password. Simply enter the login password for `<remote_host>`.

??? question "The cursor doesn't move when entering the password."

	In macOS and Linux systems, the cursor doesn't indicate how many characters you've entered when typing a password. If you see the cursor not moving, don't worry about it. Just enter the password normally and press Enter.

??? question "SSH login not at default port"

	```bash
	rsync -avuz -e "ssh -p 22222" <username>@<remote_host>:/wrdslin/tfn/sasdata/sdc_ni/* /data/dataset/sdc
	```

4) You can check the download progress through the SSH interface or SFTP.

## FTP

Some data providers only offer FTP as a download method. In this case, we recommend using the `lftp` command for synchronization.

You can refer to this webpage for basic operations: [Linux China](https://linux.cn/article-5460-1.html)

Usually, I use the `mirror <source> <target>` command to directly synchronize the entire folder.

## AWS S3

Some data providers offer AWS S3 services for downloading data. You can refer to the relevant tutorials for specific operation methods of S3.