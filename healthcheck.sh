#!/bin/bash
UP=0

while getopts ":a:d:h:i:l:n:p:t:u:" option; do
    echo "Checking option: $option"
    case $option in
        a) NEIGHBORAS=$OPTARG;;
        d) DIR=$OPTARG;;
        h) SHOWHELP=1;;
        i) LOCALIP=$OPTARG;;
        n) NEIGHBORIP=$OPTARG;;
        l) LOCALAS=$OPTARG;;
        p) LISTENPORT=$OPTARG;;
        t) TIMEOUT=$OPTARG;;
        u) URL=$OPTARG;;
   esac
done

while `true`
do
    curl "$URL" --fail -s 1> /dev/null
    if [ $? == 0 ]
    then
        if [ $UP == 0 ]
        then
            echo "We're up, adding route"
            gobgp global rib add -a ipv4 10.1.2.3/24 nexthop $LOCALIP
            UP=1
        fi
    else
        if [ $UP == 1 ]
        then
            echo "We're down, removing route"
            gobgp global rib del -a ipv4 10.1.2.3/24 nexthop $LOCALIP
            UP=0
        fi
    fi
    sleep 1
done