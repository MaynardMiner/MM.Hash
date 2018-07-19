#!/usr/bin/env bash
echo "Checking And Stopping All Previous Screen Sessions"
for session in $(screen -ls | grep -o '[0-9]*\.$(< /hive/custom/MM.Hash/Build/name.sh)'); do screen -S "${session}" -X quit; done
