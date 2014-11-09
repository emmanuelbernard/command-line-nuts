#!/bin/bash
# Adapted from http://teh-geek.com/?tag=bash

if [[ "$#" -ne "1" ]]; then
    echo -e "Offer the list of processes to kill from their name"
    echo -e "Usage:\n"
    echo -e "    killname searchstring"
    exit 1;
fi
search=$1
# Creates an array that finds Process ID (PID)
pids=(`(ps uax | grep "$search" | grep -v grep | grep -v "$0") | awk '{print $2}'`)
 
#Creates an array that finds the name of process ID (PID)
OIFS=$IFS #save original
IFS=','
commandlines=(`(ps uax | grep "$search" | grep -v grep | grep -v "$0") | awk '{printf $11 " " $12 " " $13 ","}'`)
IFS=$OIFS

len=${#pids[*]}

if [[ $len -eq 0 ]]; then
    echo "No matching process found"
    exit 0;
fi
 
i=0
while [ $i -lt $len ]; do
    j=$((i+1))
    echo "$j: ${pids[$i]} ${commandlines[$i]}"
    let i++
done

echo "" 
echo "What process do you want to kill?"
echo "press CTRL^C to cancel"
read varkill

$shiftedKill=$((varkill-1))
kill -9 "${pids[$shiftedKill]}"
 
echo "${pids[$varkill]} ${commandlines[$varkill]} was killed"

