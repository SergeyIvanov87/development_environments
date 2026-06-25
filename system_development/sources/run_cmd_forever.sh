#!/bin/bash


CMD=$@

while true;
do
	${CMD} > /dev/null 2>&1
done
