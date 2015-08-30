#!/usr/bin/env bash

# Usage: Call from Xcode Build Phase
#        bin/xcode-build-phase/fabric.sh
#
# Ask a maintainer for the Fabric API keys.
#
# See:
#
# * ./private/fabric.key.example

FABRIC_KEY_FILE='./private/fabric.key'

if [ -e "${FABRIC_KEY_FILE}" ]; then
  source "${FABRIC_KEY_FILE}"
  ./Fabric.framework/run ${FABRIC_API} ${FABRIC_API_SECRET}
else
  SCRIPT_PATH="./bin/xcode-build-phase/fabric.sh:14:"
  REASON="File $FABRIC_KEY_FILE was not found."

  if [ "${CONFIGURATION}" != "Release" ]; then
    SKIPPING="warning: Skipping Fabric.framework/run"
    echo "$SCRIPT_PATH $SKIPPING - $REASON"
  else
    FAILURE="error: Cannot execute Fabric.framework/run"
    DETAILS="Fabric is required for Release configuration."
    echo "$SCRIPT_PATH $FAILURE - $REASON $DETAILS"
    exit 1
  fi
fi

