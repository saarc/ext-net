CC_SRC_PATH=github.com/chaincode/fabcar/go
CHANNEL_NAME=mychannel
CCNAME=fabcar
ORDERER_CA=/etc/hyperledger/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


docker exec cli_org1 peer chaincode install -n $CCNAME -v 1.0 -p ${CC_SRC_PATH}
docker exec cli_org2 peer chaincode install -n $CCNAME -v 1.0 -p ${CC_SRC_PATH}
docker exec cli_org3 peer chaincode install -n $CCNAME -v 1.0 -p ${CC_SRC_PATH}
docker exec -e "CORE_PEER_ADDRESS=peer1.org1.example.com:7051" cli_org1 peer chaincode install -n $CCNAME -v 1.0 -p ${CC_SRC_PATH}

docker exec cli_org1 peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME -n $CCNAME -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member')"

sleep 10
docker exec cli_org1 peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n $CCNAME -c '{"Args":["initLedger"]}' 

sleep 10
docker exec cli_org1 peer chaincode query -C $CHANNEL_NAME -n $CCNAME -c '{"Args":["queryAllCars"]}' 


CC_SRC_PATH=github.com/chaincode/sacc
CHANNEL_NAME=newchannel
CCNAME=sacc

docker exec cli_org3 peer chaincode install -n $CCNAME -v 1.0 -p ${CC_SRC_PATH}

docker exec cli_org3 peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME -n $CCNAME -v 1.0 -c '{"Args":["a","100"]}' -P "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member')"

docker exec cli_org3 peer chaincode query -C $CHANNEL_NAME -n $CCNAME -c '{"Args":["query","a"]}' 