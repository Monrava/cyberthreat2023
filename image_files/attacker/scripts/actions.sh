#!/bin/bash -i
HISTFILE=~/.bash_history
set -o history 
pwd 
ls -la
whoami
ls /root
df -h 
echo $SHELL 
cat /proc/1/cgroup
ps aux 
nohup watch -n1 curl -s ifconfig.co & 
grep Cap /proc/1/status
ls -la /proc/
unshare -Urm
