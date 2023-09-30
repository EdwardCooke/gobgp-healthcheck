#!/bin/sh

set -e

LISTENPORT=179

while [ "$1" != "" ]
do
    [ "$1" == "--local-ip" ] && LOCALIP=$2 && shift
    [ "$1" == "--neighbor-ip" ] && NEIGHBORIP=$2 && shift
    [ "$1" == "--local-as" ] && LOCALAS=$2 && shift
    [ "$1" == "--listen-port" ] && LISTENPORT=$2 && shift
    shift
done

[ -z $LOCALIP ] && SHOWHELP=1 && echo "Local IP not set"
[ -z $NEIGHBORIP ] && SHOWHELP=1 && echo "Neighbor IP not set"
[ -z $LOCALAS ] && SHOWHELP=1 && echo "Local AS not set"
[ -z $LISTENPORT ] && SHOWHELP=1 && echo "Listen port not set"

if [ "$SHOWHELP" == "1" ]
then
    echo "Usage"
    echo '--local-ip <LOCAL IP ADDRESS> (required)'
    echo '--local-as <OUR AUTONOMOUS SYSTEM ID> (required)'
    echo '--neighbor-ip <NEIGHBOR IP ADDRESS> (required)'
    echo '--listen-port <LISTENING PORT> (defaults to 179)'
fi

echo "Configuring global"
gobgp global as $LOCALAS router-id $LOCALIP listen-port $LISTENPORT

echo "Adding neighbor"
gobgp neighbor add $NEIGHBORIP local-as $LOCALAS

echo "Waiting for my neighbor to respond"
while `true`
do
    TEST=`gobgp neighbor $NEIGHBORIP`
    echo $TEST | grep "BGP state = ESTABLISHED" && break
    echo "Not up yet"
    sleep 1
done
echo "We're up!"