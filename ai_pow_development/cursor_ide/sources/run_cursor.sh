#!/bin/bash

cursor
killall electron
ps -ef | grep electron | cut -F 2 | xargs kill -9
