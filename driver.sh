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

BROADCAST_MSG "preparing tests"
cd java
mvn install
cd target
cp blockchain-java-sdk-0.0.1-SNAPSHOT-jar-with-dependencies.jar blockchain-client.jar
cp blockchain-client.jar ../../network_resources
cd ../../network_resources

BROADCAST_MSG "creating and initializing the channel"
java -cp blockchain-client.jar org.app.network.CreateChannel

BROADCAST_MSG "deploying and instantiating the chaincode"
java -cp blockchain-client.jar org.app.network.DeployInstantiateChaincode

BROADCAST_MSG "registering and enrolling the user"
java -cp blockchain-client.jar org.app.user.RegisterEnrollUser

BROADCAST_MSG "invoking the chaincode"
java -cp blockchain-client.jar org.app.chaincode.invocation.InvokeChaincode

BROADCAST_MSG "querying the chaincode"
java -cp blockchain-client.jar org.app.chaincode.invocation.QueryChaincode
