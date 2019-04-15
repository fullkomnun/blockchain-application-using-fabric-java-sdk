#!/bin/bash

set -e

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
git clone https://gerrit.hyperledger.org/r/fabric
cd fabric
git config advice.detachedHead false
# Fabric release-1.4 (Jan 9, 2019)
git checkout 0311c83af4ca5ea223bf343eddb79a76adfe6f49

cd $GOPATH/src/github.com/hyperledger/fabric

git config user.name "jenkins"
git config user.email jenkins@jenkins.com

git am $MY_PATH/set_release_build.patch

# must amend config files to set BCCSP as PKCS#11 see: https://stackoverflow.com/a/54005033
git am $MY_PATH/amend_orderer_config.patch
git am $MY_PATH/amend_core_config.patch

make clean
DOCKER_DYNAMIC_LINK=true GO_TAGS=pkcs11 make orderer-docker peer-docker

chmod -R +rw $TMP

rm -Rf $TMP
