#!/bin/sh
set -ex

SATS=$1

if [ -z "$SATS" ]; then
  echo "provide sats"
  exit 1
fi

VALUE_MSAT_TOTAL=$(expr $SATS \* 1000)
VALUE_MSAT=$(expr $SATS \* 100)

PUBKEY=$(docker compose exec lnd2 lncli -n regtest getinfo | jq -r .identity_pubkey)

HAX='&#128520;<a href=\"https://google.com/\">'

JSON='{
  "app_name": "app_name '$HAX' name",
  "app_version": "app_version '$HAX' name",
  "value_msat_total": "10000000000000",
  "url": "url '$HAX' name",
  "feedID": "feedID '$HAX' name",
  "podcast": "podcast '$HAX' name",
  "action": "boost",
  "episode": "episode '$HAX' name",
  "episode_guid": "episode_guid '$HAX' name",
  "value_msat": "10000000000000000000",
  "ts": "ts '$HAX' name",
  "name": "name '$HAX' name",
  "sender_name": "sender_name '$HAX' name",
  "message": "message '$HAX' name",
  "reply_address": "reply_address '$HAX' name",
  "remote_feed_guid": "remote_feed_guid '$HAX' name",
  "remote_item_guid": "remote_item_guid '$HAX' name"
}'
echo "$JSON" | jq
HEX=$(echo "$JSON" | xxd -p | tr '\n' '\0')

echo $JSON
echo $HEX

docker compose exec bitcoind1 bitcoin-cli -regtest -generate 10

sleep 5

docker compose exec lnd1 lncli -n regtest connect $PUBKEY@lnd2 || echo
docker compose exec lnd1 lncli -n regtest listpeers

docker compose exec lnd1 lncli -n regtest sendpayment \
 -d "$PUBKEY" \
 -a "$SATS" \
 --keysend \
 --data "7629169=$HEX" \
 --json
