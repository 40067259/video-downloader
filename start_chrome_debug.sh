#!/bin/bash
# 启动Chrome with verbose logging for native messaging
google-chrome \
  --enable-logging=stderr \
  --v=1 \
  --vmodule=native_messaging*=3 \
  2>&1 | grep -i "native\|messaging\|videodl" | tee /tmp/chrome_native_debug.log
