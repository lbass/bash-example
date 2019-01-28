#!/bin/bash

NEXUS_URL="http://jar-repositoty:port/nexus/service/local/artifact/maven/redirect"
NEXUS_SNAPSHOTS="snapshots"
GROUP_ID="{jar-group-id}"
ARTIFACT_ID="{artifact-id}"
VERSION="0.0.1-SNAPSHOT"

APPS_PATH="/downloadPath"
JAR_FILE_NAME="{fileName}.jar"

COMMAND="$APPS_PATH/$JAR_FILE_NAME $NEXUS_URL?r=$NEXUS_SNAPSHOTS&g=$GROUP_ID&a=$ARTIFACT_ID&v=$VERSION&p=jar"
wget -O $COMMAND

REAL_HOST1="{target-server}"
REAL_HOST2="{target-server}"
REAL_APPS_PATH="{target-path}"

COMMAND="$APPS_PATH/$JAR_FILE_NAME $REAL_HOST1:$REAL_APPS_PATH"
rsync -av $COMMAND

COMMAND="$APPS_PATH/$JAR_FILE_NAME $REAL_HOST2:$REAL_APPS_PATH"
rsync -av $COMMAND
