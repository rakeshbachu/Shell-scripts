#!/bin/bash
source /export/home/sfuser/.bash_profile
da=`date`

pid=`pgrep java`
if [ $pid -ne 0 ]
then
        pid1=$pid
        #heap
        hp=`jstat -gcutil $pid | awk '{print $4;}'`
        ahp=`echo $hp | awk '{print $2;}'`


else
        pid1="Java process is not running"
fi

#load
load=`uptime`


#filesystem
fs=`df -kh | awk '{print $5,$6;}'`


#recent exceptions in log
cd $jbosslog
logerr=`tac server.log | grep -m 100000 ERROR | grep exception`


        now=`date +"%s"`
        x=`date +"%s" -r /tmp/clean.log`
        if [ $((now-x)) -gt 7200 ]
        then
        logrot="if you are seeing this message and /usr/local is more than 70 --> logrotation is not running on this server"
        fi

printf '{"date":"%s","pid":"%s","heap":"%s","load":"%s","filesys":"%s","logrot":"%s"}\n' "$da" "$pid1" "$ahp" "$load" "$fs" "$logrot"}'