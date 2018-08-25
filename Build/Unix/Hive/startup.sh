#!/usr/bin/env bash

screen -S $1 -X stuff $"$(< $2/config.sh) 2>&1 | tee $1.log\n" 
