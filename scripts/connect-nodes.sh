#!/bin/sh

# connect lnd nodes
PUBKEY=$(docker compose exec lnd1 lncli -n regtest getinfo | jq -r .identity_pubkey)
docker compose exec lnd2 lncli -n regtest connect $PUBKEY@lnd1
docker compose exec lnd2 lncli -n regtest listpeers
