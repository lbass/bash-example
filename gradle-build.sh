#!/bin/bash
chmod +x gradlew
chmod -R +x ./
./gradlew {gralde-task-name} -x test -Pprofile={gradle-proile} --stacktrace