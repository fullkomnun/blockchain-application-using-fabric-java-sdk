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

BROADCAST_MSG "generating docker-compose.yml"

ca_org1_keyfile_token="{{ ca_org1_keyfile }}"
ca_org1_keyfile=$(find ./crypto-config/peerOrganizations/org1.example.com/ca/ -name "*sk" -type f -exec basename "{}" ';')
ca_org2_keyfile_token="{{ ca_org2_keyfile }}"
ca_org2_keyfile=$(find ./crypto-config/peerOrganizations/org2.example.com/ca/ -name "*sk" -type f -exec basename "{}" ';')

echo "${ca_org1_keyfile_token} = ${ca_org1_keyfile}"
echo "${ca_org2_keyfile_token} = ${ca_org2_keyfile}"

sed -e "s/${ca_org1_keyfile_token}/${ca_org1_keyfile}/g" \
    -e "s/${ca_org2_keyfile_token}/${ca_org2_keyfile}/g" \
    < docker-compose-template.yml \
    > docker-compose.yml

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

BROADCAST_MSG "generating anchor peers updates"
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./config/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

BROADCAST_MSG "copying artifacts to network_resources"
rm -rf ../network_resources/crypto-config
mv ./crypto-config ../network_resources/
rm -rf ../network_resources/config
mv ./config ../network_resources/