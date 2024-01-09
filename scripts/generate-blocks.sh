#!/bin/sh

BLOCKS=10

if [ ! -z "$1" ]; then
  BLOCKS=$1
fi

docker compose exec bitcoind1 bitcoin-cli -regtest -generate $BLOCKS
