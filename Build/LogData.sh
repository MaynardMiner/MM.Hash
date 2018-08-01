#!/usr/bin/env bash
screen -S $1 -X stuff $"pwsh -command LogData.ps1 -API $2 -MinerPath $3 -GPUS $4 -WorkingDir $5\n"

