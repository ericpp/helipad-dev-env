#!/bin/sh

SATS=$1

APP_NAME="Castamatic"
APP_VERSION="8.0.6"
VALUE_MSAT_TOTAL=$(expr $SATS \* 1000)
URL="https://feeds.buzzsprout.com/1844352.rss"
PODCAST="Mere Mortals"
ACTION="stream"
# ACTION="boost"
EPISODE="The Art Of NFTs & Aimless Wandering"
EPISODE_GUID="Buzzsprout-9931017"
VALUE_MSAT=$(expr $SATS \* 100)
TS=574
NAME="Podcaster"
SENDER_NAME="Peter"
MESSAGE="hello there!"

JSON='{"app_name": "'$APP_NAME'", "app_version": "'$APP_VERSION'", "value_msat_total": '$VALUE_MSAT_TOTAL', "url": "'$URL'", "podcast": "'$PODCAST'", "action": "'$ACTION'", "episode": "'$EPISODE'", "episode_guid": "'$EPISODE_GUID'", "value_msat": '$VALUE_MSAT', "ts": '$TS', "name": "'$NAME'", "sender_name": "'$SENDER_NAME'", "message": "'$MESSAGE'"}'
HEX=$(echo "$JSON" | xxd -p | tr '\n' '\0')

echo $JSON
echo $HEX

PUBKEY=$(docker compose exec lnd2 lncli -n regtest getinfo | jq -r .identity_pubkey)

docker compose exec lnd1 lncli -n regtest sendpayment \
 -d "$PUBKEY" \
 -a "$SATS" \
 --keysend \
 --data "7629169=$HEX"
