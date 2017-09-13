#!/bin/bash
check_statusof_java()
{
        echo "`/etc/init.d/<<your startup script>> status | awk 'FNR == 1 {print $5}' | cut -c 3-10`"
}

fetch_pid()
{
        pid=`pgrep java`
        echo "$pid"
}

start_tms_process()
{
        startout=echo"`/etc/init.d/tms start`"
        if [ $startout == *"Tomcat started"* ];then
                echo "tomcat started successfully"
        fi
        sleep 10
        pid=$(fetch_pid)
        if [ -z $pid ]; then
                echo "mail to dl"
                mailcat=`tail -50 /local/customers/plateau/.tms/logs/catalina.out`
                `echo "$mailcat" | mailx -r $host -s "server failed to restart" <<your mail id>>`
        else
                echo "pid $pid is running even after 10 seconds successfully"
                exit
        fi
}

echo "script started running at `date`"
path="<<path of your lib files>>/lib"
#echo $path
sts=$(check_statusof_java)
echo $sts
host=`hostname`"@something.com"

run="running"
if [ $sts = $run ]; then
        echo "process is running exiting"
        exit
else
        if [ -d '<<path of your lib files>>'/lib ]; then
                echo "directory found but process is not running going to restart now"
                start_tms_process
        else
                `echo "library directory <<path of your lib files>>/lib are missing" | mailx -r $host -s "files are missing in this server" <<your mail id>>`
        fi
fi
