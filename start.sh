#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

docker-compose -f docker-compose.yml down

#docker-compose -f docker-compose.yml up -d ca.example.com orderer.example.com peer0.org1.example.com couchdb
docker-compose -f docker-compose.yml up -d orderer.example.com \
            ca.org1.example.com peer0.org1.example.com peer1.org1.example.com \
            ca.org2.example.com peer0.org2.example.com \
            ca.org3.example.com peer0.org3.example.com \
            cli_org1 cli_org2 cli_org3


docker ps -a

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
#docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx
docker exec cli_org1 peer channel create -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx 
# Join peer0.org1.example.com to the channel.
#docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b mychannel.block

# Join peer0.org1.example.com to the channel.
docker exec peer0.org1.example.com peer channel join -b /etc/hyperledger/configtx/mychannel.block
docker exec peer1.org1.example.com peer channel join -b /etc/hyperledger/configtx/mychannel.block

# Join peer0.org2.example.com to the channel.
docker exec peer0.org2.example.com peer channel join -b /etc/hyperledger/configtx/mychannel.block
# Join peer0.org3.example.com to the channel.
docker exec peer0.org3.example.com peer channel join -b /etc/hyperledger/configtx/mychannel.block

docker exec cli_org1 peer channel update -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/Org1MSPanchors.tx 


# # second channel operation
docker exec cli_org1 peer channel create -o orderer.example.com:7050 -c newchannel -f /etc/hyperledger/configtx/newchannel.tx 

sleep 5

docker exec peer1.org1.example.com peer channel join -b /etc/hyperledger/configtx/newchannel.block
docker exec peer0.org3.example.com peer channel join -b /etc/hyperledger/configtx/newchannel.block

docker exec cli_org1 peer channel update -o orderer.example.com:7050 -c newchannel -f /etc/hyperledger/configtx/NewOrg1MSPanchors.tx
