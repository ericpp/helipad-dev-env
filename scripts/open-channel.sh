#!/bin/sh

#PUBKEY=$1

#/opt/bitcoin/lncli -n regtest connect $1@bitcoind1
#/opt/bitcoin/lncli -n regtest connect $1@bitcoind2

#/opt/bitcoin/lncli -n regtest openchannel $1 100000 50000

#/opt/bitcoin/bitcoin-cli -regtest -generate 10

ADDRESS=$(docker compose exec lnd1 lncli -n regtest newaddress p2tr | jq -r .address)

docker compose exec bitcoind1 bitcoin-cli -regtest -generate 10
docker compose exec bitcoind1 bitcoin-cli -regtest sendtoaddress $ADDRESS 10
docker compose exec bitcoind1 bitcoin-cli -regtest -generate 10

sleep 5

PUBKEY=$(docker compose exec lnd2 lncli -n regtest getinfo | jq -r .identity_pubkey)

docker compose exec lnd1 lncli -n regtest openchannel $PUBKEY 100000 50000
docker compose exec bitcoind1 bitcoin-cli -regtest -generate 10

# ADDRESS=$(./bin/lncli -n regtest newaddress np2wkh | grep '"address"' | cut -f 2 -d ':' | cut -f 2 -d '"' | cut -f 1 -d '"')

#./bin/bitcoin-cli -regtest loadwallet test
#./bin/bitcoin-cli -regtest -generate 100
#./bin/bitcoin-cli -regtest sendtoaddress $ADDRESS 10
#./bin/bitcoin-cli -regtest -generate 100

#./bin/lncli -n regtest getinfo | grep identity_pubkey

#./bin/lncli -n regtest getinfo | jq -r .identity_pubkey
