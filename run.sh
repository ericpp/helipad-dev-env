#!/bin/sh

echo "Starting Bitcoin/LND containers..."
docker compose up -d
sleep 5

# unlock bitcoin wallet
docker compose exec bitcoind1 /tmp/scripts/init-wallet.sh
docker compose exec bitcoind2 /tmp/scripts/init-wallet.sh
sleep 10

echo "Generating some blocks..."
docker compose exec bitcoind1 bitcoin-cli -regtest -generate 300
sleep 10

# connect lnd nodes
echo "Connecting LND nodes together..."
PUBKEY=$(docker compose exec lnd1 lncli -n regtest getinfo | jq -r .identity_pubkey)
docker compose exec lnd2 lncli -n regtest connect $PUBKEY@lnd1
docker compose exec lnd2 lncli -n regtest listpeers

CHANNELS=$(docker compose exec lnd1 lncli -n regtest listchannels | jq -r .channels)

if [ "$CHANNELS" = "[]" ]; then
  echo "Loading LND wallet..."
  ADDRESS=$(docker compose exec lnd1 lncli -n regtest newaddress p2tr | jq -r .address)
  docker compose exec bitcoind1 bitcoin-cli -regtest sendtoaddress $ADDRESS 10
  docker compose exec bitcoind1 bitcoin-cli -regtest -generate 10

  echo "Opening a channel between LND nodes..."
  PUBKEY=$(docker compose exec lnd2 lncli -n regtest getinfo | jq -r .identity_pubkey)
  docker compose exec lnd1 lncli -n regtest openchannel $PUBKEY 10000000 5000000
  docker compose exec bitcoind1 bitcoin-cli -regtest -generate 10
fi

echo "Opening Helipad development shell..."
docker compose exec -e LND_ADMINMACAROON=/lnd/data/chain/bitcoin/regtest/admin.macaroon -w /opt/helipad helipad-dev /bin/bash

echo "Shutting down containers..."
docker compose down
