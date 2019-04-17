#!/bin/bash

set -xe

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

TMP=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
echo "Build tmp directory is $TMP ..."

export GOPATH=$TMP

mkdir -p $GOPATH/src/github.com/hyperledger/
cd $GOPATH/src/github.com/hyperledger/
git clone https://gerrit.hyperledger.org/r/fabric-ca
cd fabric-ca
git config advice.detachedHead false
# Fabric-ca release-1.4 (Jan 10, 2019)
git checkout 27fbd69ab2d0f07212b382eb04aa85c904d2c300

cd $GOPATH/src/github.com/hyperledger/fabric-ca

git config user.name "jenkins"
git config user.email jenkins@jenkins.com

git am $MY_PATH/add_go_tags.patch

make clean
FABRIC_CA_DYNAMIC_LINK=true GO_TAGS=pkcs11 make docker

chmod -R +rw $TMP

rm -Rf $TMP

cd $MY_PATH
# build fabric-ca-softhsm image
docker build -f ./images/fabric-node-softhsm/Dockerfile \
 --build-arg FABRIC_NODE_BASE_IMAGE=hyperledger/fabric-ca \
 --build-arg FABRIC_NODE_TAG=amd64-1.4.0 \
 -t fullkomnun/fabric-ca-softhsm:amd64-1.4.0 \
 ./images/fabric-node-softhsm
