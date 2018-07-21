#!/usr/bin/env bash

screen -S $1 -X stuff $"$(< $2/config.sh)\n"
