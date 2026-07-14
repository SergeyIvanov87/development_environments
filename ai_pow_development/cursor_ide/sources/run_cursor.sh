#!/bin/bash

env XDG_DATA_DIRS=/usr/share:/usr/local/share cursor \
  --no-sandbox \
  --disable-setuid-sandbox \
  --disable-gpu \
  --use-gl=swiftshader \
  --disable-dev-shm-usage \
  --password-store="basic" \
  --verbose

killall electron
ps -ef | grep electron | cut -F 2 | xargs kill -9
