#!/usr/bin/env bash

screen -S $1 -X stuff $"export GPU_MAX_HEAP_SIZE=100\n"
screen -S $1 -X stuff $"export GPU_USE_SYNC_OBJECTS=1\n"
screen -S $1 -X stuff $"export GPU_SINGLE_ALLOC_PERCENT=100\n"
screen -S $1 -X stuff $"export GPU_MAX_ALLOC_PERCENT=100\n"
