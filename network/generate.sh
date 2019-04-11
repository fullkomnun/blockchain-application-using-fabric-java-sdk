#!/bin/bash
#
# Exit on first error, print all commands.
set -e

BROADCAST_MSG() {
  local MESSAGE=$1

  echo
  echo "======================================================================="
  echo "   > ${MESSAGE}"
  echo "======================================================================="
  echo
}

rm -rf "./crypto-config/"

mkdir -p "./crypto-config/"

BROADCAST_MSG "generating key material"
cryptogen generate --config=./crypto-config.yaml --output="./crypto-config/"
#find ./crypto-config/ -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'

rm -rf "./config/"

mkdir -p "./config/"

SYSTEM_CHANNEL_NAME="system"
BROADCAST_MSG "generating genesis block"
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./config/genesis.block -channelID $SYSTEM_CHANNEL_NAME
#configtxgen -inspectBlock ./config/genesis.block

CHANNEL_NAME="mychannel"
BROADCAST_MSG "generating config transaction"
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./config/channel.tx -channelID $CHANNEL_NAME
#configtxgen -inspectChannelCreateTx ./config/channel.tx

BROADCAST_MSG "copying artifacts to network_resources"
rm -rf ../network_resources/crypto-config
mv ./crypto-config ../network_resources/
rm -rf ../network_resources/config
mv ./config ../network_resources/
