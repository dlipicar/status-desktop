#!/usr/bin/env bash

RPC_ADDR="${RPC_ADDR:-localhost}"
RPC_PORT="${RPC_PORT:-8545}"
MAILSERVER_PORT="${MAILSERVER_PORT:-30303}"
# might be provided by parent
if [[ -z "${PUBLIC_IP}" ]]; then
    PUBLIC_IP=$(curl -s https://ipecho.net/plain)
fi

# query local 
RESP_JSON=$(
    curl -sS --retry 3 --retry-connrefused \
        -X POST http://${RPC_ADDR}:${RPC_PORT}/ \
        -H 'Content-type: application/json' \
        -d '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}'
)
if [[ "$?" -ne 0 ]]; then
    echo "RPC port not up, unable to query enode address!" 1>&2
    exit 1
fi

# extract enode from JSON response
ENODE_RAW=$(echo "${RESP_JSON}" | jq -r '.result.enode')
# drop arguments at the end of enode address
ENODE_CLEAN=$(echo "${ENODE_RAW}" | grep -oP '\Kenode://[^?]+')

ENODE=$(echo "${ENODE_CLEAN}" | sed \
    -e "s/:30303/:${MAILSERVER_PORT}/")

echo "${ENODE}"
