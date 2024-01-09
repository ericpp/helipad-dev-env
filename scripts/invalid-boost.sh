#!/bin/sh

SATS=$1

if [ -z "$SATS" ]; then
  echo "provide sats"
  exit 1
fi

FEED_ID=745047
ITEM_ID=14695552499
TS=1255

PUBKEY=$(docker compose exec lnd2 lncli -n regtest getinfo | jq -r .identity_pubkey)
REPLY_PUBKEY=$(docker compose exec lnd1 lncli -n regtest getinfo | jq -r .identity_pubkey)

JSON='{
  "feedID": "'$FEED_ID'",
  "itemID": "'$ITEM_ID'",
  "ts": '$TS'
}'
HEX=$(echo "$JSON" | xxd -p | tr '\n' '\0')

echo $JSON
echo $HEX

docker compose exec bitcoind1 bitcoin-cli -regtest -generate 10

sleep 5

docker compose exec lnd1 lncli -n regtest connect $PUBKEY@lnd2
docker compose exec lnd1 lncli -n regtest listpeers

docker compose exec lnd1 lncli -n regtest sendpayment \
 -d "$PUBKEY" \
 -a "$SATS" \
 --keysend \
 --data "7629169=$HEX"
