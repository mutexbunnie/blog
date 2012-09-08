#!/bin/ksh


if [ -z $3   ]; then
        echo "Usage $0 script list maxForks"
        exit
fi

forkLimit=$3;

rm -f /tmp/parrjobs

time=`date +%s`
rm    current
mkdir -p output/$time

ln -s  `pwd`/output/$time `pwd`/current

for item in `cat $2`
do
        echo Starting ${item}..

        runningJobs=`jobs -p |wc -l` 
        while  [ $runningJobs  -ge $forkLimit ]; do
                echo "There are $runningJobs running jobs, waiting..."
                sleep 5 
                runningJobs=`jobs -p |wc -l` 
        done    
         ./$1 $item &
        jobs  -p >> /tmp/parrjobs
done

echo "All jobs started, waiting for completion"

runningJobs=`(ps -e |awk '{print $1}'|grep -v "PID"; cat /tmp/parrjobs|sort|uniq)|sort|uniq -d|wc -l`
while  [ $runningJobs -gt 0 ]; do
                echo "There are $runningJobs running jobs, waiting..."
                sleep 5
                runningJobs=`(ps -e |awk '{print $1}'|grep -v "PID"; cat /tmp/parrjobs|sort|uniq)|sort|uniq -d|wc -l`
done

echo "Done!"
rm /tmp/parrjobs

