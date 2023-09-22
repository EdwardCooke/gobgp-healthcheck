#!/bin/sh

LISTENPORT=1179

while getopts ":a:d:h:i:l:n:p:t:" option; do
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
   esac
done

echo "Configuring global"
gobgp global as $LOCALAS router-id $LOCALIP listen-port $LISTENPORT

echo "Adding neighbor"
gobgp neighbor add $NEIGHBORIP as $NEIGHBORAS local-as $LOCALAS

echo "Waiting for my neighbor to respond"
while `true`
do
    TEST=`gobgp neighbor $NEIGHBORIP`
    echo $TEST | grep "BGP state = ESTABLISHED" && break
    echo "Not up yet"
    sleep 1
done