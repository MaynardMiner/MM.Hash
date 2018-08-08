#!/usr/bin/env bash

cd `dirname $0`

[ -t 1 ] && . colors

. /hive-config/wallet.conf

#[[ -z $CUSTOM_MINER ]] && echo -e "${RED}No CUSTOM_MINER is set${NOCOLOR}" && exit 1
#. /hive/custom/$CUSTOM_MINER/h-manifest.conf

. h-manifest.conf

#echo $CUSTOM_MINER
#echo $CUSTOM_LOG_BASENAME
#echo $CUSTOM_CONFIG_FILENAME

[[ -z $CUSTOM_LOG_BASENAME ]] && echo -e "${RED}No CUSTOM_LOG_BASENAME is set${NOCOLOR}" && exit 1
[[ -z $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}No CUSTOM_CONFIG_FILENAME is set${NOCOLOR}" && exit 1
[[ ! -f $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}Custom config ${YELLOW}$CUSTOM_CONFIG_FILENAME${RED} is not found${NOCOLOR}" && exit 1
CUSTOM_LOG_BASEDIR=`dirname "$CUSTOM_LOG_BASENAME"`
[[ ! -d $CUSTOM_LOG_BASEDIR ]] && mkdir -p $CUSTOM_LOG_BASEDIR

if ! [ -x "$(command -v pwsh)" ]; then
sudo apt-get install p7zip-full
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list
sudo apt-get update
sudo apt-get install -y powershell
fi

pwsh -command "&.\MM.Hive.ps1 $(< /hive/custom/$CUSTOM_NAME/$CUSTOM_NAME.conf) $CUSTOM_USER_CONFIG" && . colors $@ 2>&1 | tee $CUSTOM_LOG_BASENAME.log 
