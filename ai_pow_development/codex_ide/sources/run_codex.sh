#!/bin/bash

codex-desktop
killall electron
ps -ef | grep electron | cut -F 2 | xargs kill -9
