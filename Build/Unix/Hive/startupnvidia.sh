#!/usr/bin/env bash 

screen -S $2 -d -m && \
screen -S $2 -X logfile $4 && \
screen -S $2 -X log  && \
screen -S $2 -X stuff $"export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$5\n" && \
screen -S $2 -X stuff $"cd\n" && \
screen -S $2 -X stuff $"cd $1\n" && \
screen -S $2 -X stuff $"$(< $3/config.sh)\n" 