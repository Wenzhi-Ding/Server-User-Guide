## Accessing Data

Due to the different purposes of each server, the data directories will not be publicly available on this website. Please request the data directory of the server you are using via WeChat, Slack, or email.

To save disk space, please try not to copy the raw data from the database to your own directory. You can directly read the path in your program to access the data. Afterwards, you can store the data that you have filtered according to your needs in your own directory.

If the server's disk space usage is too high, the administrator will identify users with high disk usage and request them to delete redundant data.

## Data Permission Management

This section is for reference by administrators.

```bash
sudo chmod -R 740
sudo chmod 770 `sudo find <database path> -type d`
```

This command combination sets all files to be readable by group users but not writable.

Note that the folder itself needs to be set as readable, writable, and executable by group users. If the folder itself is not writable, it will cause the data reading to fail in Pandas. This may be because Pandas defaults to creating a cache in the same path when reading.