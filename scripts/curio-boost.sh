#!/bin/sh

set -ex

SATS=$1

if [ -z "$SATS" ]; then
  echo "provide sats"
  exit 1
fi

VALUE_MSAT_TOTAL=$(expr $SATS \* 1000)
VALUE_MSAT=$(expr $SATS \* 100)

SENDER_NAME="MoneyBagzzz"
MESSAGE="The numbers talk to me!"

PUBKEY=$(docker compose exec lnd2 lncli -n regtest getinfo | jq -r .identity_pubkey)
REPLY_PUBKEY=$(docker compose exec lnd1 lncli -n regtest getinfo | jq -r .identity_pubkey)

JSON='{
  "podcast": "CurioCaster",
  "feedId": 4935828,
  "episode": "CurioCaster Live Value Test Episode",
  "action": "boost",
  "app_name": "CurioCaster",
  "url": "https://curiocaster.com/rss/feed.xml",
  "value_msat_total": '$VALUE_MSAT_TOTAL',
  "message": "'$MESSAGE'",
  "sender_name": "'$SENDER_NAME'",
  "reply_address": "'$REPLY_PUBKEY'",
  "remote_feed_guid": "b8b6971e-403e-568f-a4e6-7aa2b45e50d4",
  "remote_item_guid": "72a3b402-8491-4cd9-823e-a621fd81b86f",
  "value_msat": '$VALUE_MSAT',
  "name": "Podcastindex.org"
}'
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
