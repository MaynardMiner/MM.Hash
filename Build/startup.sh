#!/usr/bin/env bash
cd $(< /hive/custom/MM.Hash/Build/dir.sh)
screen -S $(< /hive/custom/MM.Hash/Build/name.sh) -X stuff $'./config.sh\n'
