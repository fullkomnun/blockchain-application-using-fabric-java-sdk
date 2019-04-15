#!/usr/bin/env bash

# setup softhsm2
SETUP_SOFTHSM() {
  # Install softhsm2 and opensc for pkcs11 testing (libhsm-bin also an option)
  apt-get update -y
  apt-get install -y --no-install-recommends softhsm2 opensc libtool libltdl-dev

  # Create tokens directory (or you get - ERROR: Could not initialize the library)
  mkdir -p /var/lib/softhsm/tokens/

  export SOFTHSM2_CONF=/etc/softhsm/softhsm2.conf

  # Initialize token for fabric usage
  softhsm2-util --init-token --slot 0 --label "ForFabric" --so-pin 1234 --pin 98765432
}

SETUP_SOFTHSM