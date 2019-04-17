ARG   FABRIC_NODE_BASE_IMAGE
ARG   FABRIC_NODE_TAG

FROM  ${FABRIC_NODE_BASE_IMAGE}:${FABRIC_NODE_TAG}

LABEL maintainer=fullkomnun

ENV SOFTHSM2_CONF=/etc/softhsm/softhsm2.conf

RUN   set -xe; \
      apt update -y && \
      apt install -y --no-install-recommends softhsm2 libtool libltdl-dev && \
      mkdir -p /var/lib/softhsm/tokens/ && \
      export SOFTHSM2_CONF=/etc/softhsm/softhsm2.conf && \
      softhsm2-util --init-token --slot 0 --label "ForFabric" --so-pin 1234 --pin 98765432