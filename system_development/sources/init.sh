#!/bin/bash

WORK_DIR=$1
PROJECT_DIR=$2

echo -e "export WORK_DIR=${WORK_DIR}\nexport PROJECT_DIR=${PROJECT_DIR}\n" > ${WORK_DIR}/env.sh

${WORK_DIR}/run_cmd_forever.sh geany &


${WORK_DIR}/run_cmd_forever.sh kitty &
${WORK_DIR}/run_cmd_forever.sh kitty mc &

sleep infinity &
wait $!

