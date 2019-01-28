#!/bin/bash

REAL_HOST1="{target-server1}"
REAL_HOST2="{target-server2}"
REAL_BIN_PATH="{target-server-path}"

ssh $REAL_HOST1 "cd $REAL_BIN_PATH && ./{실행스크립트}.sh restart"
ssh $REAL_HOST2 "cd $REAL_BIN_PATH && ./{실행스크립트}.sh restart"