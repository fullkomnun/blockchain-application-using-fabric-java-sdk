#!/bin/bash
#
# Exit on first error, print all commands.
set -xe

BROADCAST_MSG() {
  local MESSAGE=$1

  echo
  echo "======================================================================="
  echo "   > ${MESSAGE}"
  echo "======================================================================="
  echo
}

BROADCAST_MSG "preparing tests"
cd java
mvn clean
mvn install
cd target
cp blockchain-java-sdk-0.0.1-SNAPSHOT-jar-with-dependencies.jar blockchain-client.jar
cp blockchain-client.jar ../../network_resources
cd ../../network_resources

export ORG_HYPERLEDGER_FABRIC_SDK_LOGLEVEL=TRACE
export ORG_HYPERLEDGER_FABRIC_CA_SDK_LOGLEVEL=TRACE
export ORG_HYPERLEDGER_FABRIC_SDK_LOG_EXTRALOGLEVEL=10

BROADCAST_MSG "creating and initializing the channel"
java -Dorg.hyperledger.fabric.sdk.loglevel=TRACE -Dorg.hyperledger.fabric.sdk.log.extraloglevel=10 -cp blockchain-client.jar org.app.network.CreateChannel

BROADCAST_MSG "deploying and instantiating the chaincode"
java -Dorg.hyperledger.fabric.sdk.loglevel=TRACE -Dorg.hyperledger.fabric.sdk.log.extraloglevel=10 -cp blockchain-client.jar org.app.network.DeployInstantiateChaincode

BROADCAST_MSG "registering and enrolling the user"
java -Dorg.hyperledger.fabric.sdk.loglevel=TRACE -Dorg.hyperledger.fabric.sdk.log.extraloglevel=10 -cp blockchain-client.jar org.app.user.RegisterEnrollUser

BROADCAST_MSG "invoking the chaincode"
java -Dorg.hyperledger.fabric.sdk.loglevel=TRACE -Dorg.hyperledger.fabric.sdk.log.extraloglevel=10 -cp blockchain-client.jar org.app.chaincode.invocation.InvokeChaincode

BROADCAST_MSG "querying the chaincode"
java -Dorg.hyperledger.fabric.sdk.loglevel=TRACE -Dorg.hyperledger.fabric.sdk.log.extraloglevel=10 -cp blockchain-client.jar org.app.chaincode.invocation.QueryChaincode
