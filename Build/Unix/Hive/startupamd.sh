#!/usr/bin/env bash 

screen -S $2 -d -m && \
screen -S $2 -X logfile $4 && \
screen -S $2 -X log  && \
screen -S $2 -X stuff $"export GPU_MAX_HEAP_SIZE=100\n" && \
screen -S $2 -X stuff $"export GPU_USE_SYNC_OBJECTS=1\n" && \
screen -S $2 -X stuff $"export GPU_SINGLE_ALLOC_PERCENT=100\n" && \
screen -S $2 -X stuff $"export GPU_MAX_ALLOC_PERCENT=100\n" && \
screen -S $2 -X stuff $"cd\n" && \
screen -S $2 -X stuff $"cd $1\n" && \
screen -S $2 -X stuff $"$(< $3/config.sh)\n" 