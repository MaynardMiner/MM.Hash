#!/usr/bin/bash
screen -S $1 -X stuff $"export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$2\n"
screen -S $1 -X stuff $"export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$2\n"
