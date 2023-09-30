#!/bin/bash

CONFIGURATORPID=$1

# loop and make sure this pid directory is always existing, when it's not, that means the healthchecker is dead
while [ -d "/proc/$CONFIGURATORPID" ]
do
    sleep 1
done

# healthchecker is dead, kill gobgpd so the container terminates
while `true`
do
    pkill gobgpd
done 