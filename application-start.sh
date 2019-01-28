#!/bin/bash

APPLICATION_ID="{application-id}"
PWD=`pwd`
HOME="{application-home}"
CONFIG_HOME=$HOME/{config-path}
JAVA_HOME={JDK_HOME}
JAVA_BIN=$JAVA_HOME/bin

PID_FILE="{application-id}.pid"
JAR_FILE="{application-id}.jar"
REAL_JAR="{application-id}-running.jar"

JAR_HOME=$HOME/apps
JAVA_OPTS="-Xms1g -Xmx1g -XX:-HeapDumpOnOutOfMemoryError -Dname=$APPLICATION_ID"
JAVA_OPTS="$JAVA_OPTS -XX:+UseG1GC -XX:G1ReservePercent=20"
JAVA_OPTS="$JAVA_OPTS -Xloggc:$HOME/logs/gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=10M -XX:-PrintGCDetails -XX:+PrintGCDateStamps -XX:-PrintTenuringDistribution"

MAIN_CLASS="{application-main-class}"
START_ARGS="--spring.config.location=$CONFIG_HOME/application.yaml --logging.config=$CONFIG_HOME/logback.xml"
HA_CHAEK="IGNORE"

case "$1" in
restart)
    HA_CHECK=`curl -f -s -v "http://ha-target:port/health" && echo "OK" || echo "FAIL"`
    if [ "$HA_CHECK" = "FAIL" ]; then
        echo "WAIT HA SERVICE START"
        COUNT=$(($COUNT+1))
        echo "loop count $COUNT"
        if [ $COUNT -gt 4 ]; then
            echo "HA SERVICE NOT STARTED"
            exit -1
        fi
        sleep 5
    fi

    echo `cat $PID_FILE`
    kill -15 `cat $PID_FILE`
    while kill -0 `cat $PID_FILE` >/dev/null 2>&1
    do
        echo "WAIT KILL"
        sleep 1
    done
    echo STOPPED
    rm $PID_FILE
    cp $JAR_HOME/$JAR_FILE $JAR_HOME/$REAL_JAR
    $JAVA_BIN/java $JAVA_OPTS -Dname=cameo -jar $JAR_HOME/$REAL_JAR $START_ARGS > /dev/null &
    # $JAVA_BIN/java $JAVA_OPTS -Dname=cameo -jar $JAR_HOME/$REAL_JAR > /dev/null &
    echo "$!" > $PID_FILE
    echo STARTED
    ;;
stop)
    HA_CHECK=`curl -f -s -v "http://ha-target:port/health" && echo "OK" || echo "FAIL"`
    if [ "$HA_CHECK" -eq "FAIL" ]; then
        echo "HA SERVICE NOT STARTED"
        exit -1
    fi
    if [ -f $PID_FILE ]; then
        kill -15 `cat $PID_FILE`

        while kill -0 `cat $PID_FILE` >/dev/null 2>&1
        do
            sleep 1
        done

        echo STOPPED
        rm $PID_FILE
    else
        echo "It seems that the process isn't running."
    fi
    ;;
esac