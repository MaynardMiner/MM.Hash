screen -S $2 -X stuff $"export GPU_MAX_HEAP_SIZE=100\n"
sleep .5
screen -S $2 -X stuff $"export GPU_USE_SYNC_OBJECTS=1\n"
sleep .5
screen -S $2 -X stuff $"export GPU_SINGLE_ALLOC_PERCENT=100\n"
sleep .5
screen -S $2 -X stuff $"export GPU_MAX_ALLOC_PERCENT=100\n"
sleep .5
screen -S $2 -X stuff $"cd\n"
sleep 1
screen -S $2 -X stuff $"cd $1\n"
sleep 1
screen -S $2 -X stuff $"$(< $3/config.sh) 2>&1 | tee $4\n" 

