#!/bin/sh

SATS=$1

if [ -z "$SATS" ]; then
  echo "provide sats"
  exit 1
fi

APP_NAME="Fountain"
APP_VERSION="8.0.6"
VALUE_MSAT_TOTAL=$(expr $SATS \* 1000)
URL="https://feeds.buzzsprout.com/1844352.rss"
ACTION="boost"
VALUE_MSAT=$(expr $SATS \* 100)
TS=574
#PODCAST="Mere Mortals"
#EPISODE="The Art Of NFTs & Aimless Wandering"
#EPISODE_GUID="Buzzsprout-9931017"
#NAME="Podcaster"
#SENDER_NAME="Peter"
#MESSAGE="hello there! 😊😊think Yaël or ☺"

# Identifying the podcast required: use one or more of podcast, guid, feedID and/or url. guid preferred
# guid ( str) The <podcast:guid> tag.
# podcast (str) Title of the podcast
# feedID (int) ID of podcast in PodcastIndex.org directory
# url (str) RSS feed URL of podcast

PODCAST="Testing Podcast"
# GUID="917393e3-1b1e-5cef-ace4-edaa54e1f810"
FEED_ID="920666"
EPISODE="Testing Episode"
EPISODE_GUID="testing-12345"
NAME="Podcaster Paul"
SENDER_NAME="MoneyBagzzz"
MESSAGE="The numbers talk to me!"
REMOTE_FEED_GUID=78ae7a58-679a-50dd-95c0-c8f69e431b78
REMOTE_ITEM_GUID=e1c2e15d-656c-41de-a52c-6771292a7312

PUBKEY=$(docker compose exec lnd2 lncli -n regtest getinfo | jq -r .identity_pubkey)
#REPLY_PUBKEY=$(docker compose exec lnd1 lncli -n regtest getinfo | jq -r .identity_pubkey)
REPLY_PUBKEY="ericpp@fountain.fm"

JSON='{
  "app_name": "'$APP_NAME'",
  "app_version": "'$APP_VERSION'",
  "value_msat_total": '$VALUE_MSAT_TOTAL',
  "url": "'$URL'",
  "feedID": "'$FEED_ID'",
  "podcast": "'$PODCAST'",
  "action": "'$ACTION'",
  "episode": "'$EPISODE'",
  "episode_guid": "'$EPISODE_GUID'",
  "value_msat": '$VALUE_MSAT',
  "ts": '$TS',
  "name": "'$NAME'",
  "sender_name": "'$SENDER_NAME'",
  "message": "'$MESSAGE'",
  "reply_address": "'$REPLY_PUBKEY'",
  "remote_feed_guid": "'$REMOTE_FEED_GUID'",
  "remote_item_guid": "'$REMOTE_ITEM_GUID'"
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
