#!/bin/sh

if [ ! -f "/data/.bitcoin/bitcoin.conf" ]; then
  ln -s /etc/bitcoin.conf /data/.bitcoin/bitcoin.conf
fi

if [ ! -d "/data/.bitcoin/regtest/wallets/test" ]; then
  echo "Creating bitcoin wallet..."
  bitcoin-cli -regtest -rpcconnect=127.0.0.1 createwallet test

  echo "Generating some bitcoins..."
  bitcoin-cli -regtest -rpcconnect=127.0.0.1 -generate 200
  bitcoin-cli -regtest getbalance
else
  echo "Loading bitcoin wallet..."
  bitcoin-cli -regtest -rpcconnect=127.0.0.1 loadwallet test
  bitcoin-cli -regtest -rpcconnect=127.0.0.1 -generate 10
fi
