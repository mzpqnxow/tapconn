# tapconn - A connect() auditing tool implemented in SystemTap

The tapconn.stp script is a SystemTap script to aid in debugging/troubleshooting/logging network activity. It was written to solve a specific problem, to identify failed connections and trace them back to a user id, given an IP address. It can be extended to do much more.

## Why SystemTap

SystemTap provides a good interface to solve this problem. But other options were also investigated. For example, the least invasive method seemed to be auditd. Unfortunately, auditd SYSCALL msgtype only shows the pointer value for the socket structure when SYS_connect() is called. Because the IP address and port number for a connection are in a sockaddr structure, it is not possible to determine their value from the pointer. This means in effect that the only information we can get 

## Installing and using

A Makefile is provided to install and uninstall the package, which includes a systemd service file

### Install 

```
$ make install
```

### Start

```make start``` or use ```systemctl start tapconn.service``` after installing

### Stop

```make stop``` or use ```systemctl stop tapconn.service``` after installing

## Using manually

If you don't want to run tapconn as a systemd service, ignore the files in systemd/ and use the following command. Note that the hack with the passwd file is required to resolve uid values to usernames at runtime

```
root@host # stap -F -o tapconn.json \
    -S 32,7 \
    tapconn/tapconn.stap \
    $(hostname) \
    $(cat /etc/passwd | cut -d ':' -f 1,3 | tr '\n' '|') > /var/run/tapconn.pid
```

### Uninstall

```make clean```

## Output

The output will look something like this:

```
{ "hostname": "somehost.somedomain", "cmd": "telnet", "dst_ip": "1.2.3.4", "dst_port": 80, "pid": 35769, "ppid": 27361, "uid": 665, "username": "svcscan" }
{ "hostname": "somehost.somedomain", "cmd": "telnet", "dst_ip": "1.2.3.4", "dst_port": 80, "pid": 35769, "ppid": 27361, "uid": 665, "username": "svcscan" }
```

## License

This is released under the GPLv2 license by copyright@mzpqnxow.com
