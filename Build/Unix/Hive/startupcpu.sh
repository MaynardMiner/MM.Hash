#!/usr/bin/env bash 

screen -S $2 -X stuff $"cd\n"
sleep 1
screen -S $2 -X stuff $"cd $1\n"
sleep 1
screen -S $2 -X stuff $"$(< $3/config.sh) 2>&1 | tee $4\n" 
