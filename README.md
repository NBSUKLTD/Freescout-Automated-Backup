# Freescout Automated Backup Script
### Not Blowing Smoke Limited
[www.notblowingsmoke.com](#www.notblowingsmoke.com)

With no simple backup soloution for FreeScout built in or available via a module, this simple bash script will perform a backup of the entire filesystem, take a MySQL dump of the database and then bundle them together into a single tarball datestamped. Then upload to your remote FTP storage and discard the local copies.

 ### Install required packages :dizzy:
#### Ubuntu/Debian (apt package manager)
```
   apt update
   apt install pv gzip mysql-client curl
```
#### CentOS/RHEL (yum package manager)
```
   yum update
   yum install pv gzip mysql curl
```
#### Fedora (dnf package manager)
```
    dnf update
    dnf install pv gzip mysql curl
```
#### Alpine Linux (apk package manager):
```
    apk update
    apk add pv gzip mysql-client curl
```
#### Setup CRON Job: 
```
crontab -e
# Freescout Backup Script (runs twice daily)
0 */12 * * * /bin/bash /home/[USER]/[DIR]/backup.sh >/dev/null 2>&1
```
