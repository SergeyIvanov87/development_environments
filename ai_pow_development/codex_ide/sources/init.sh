#!/bin/bash

WORK_DIR=$1
PROJECT_DIR=$2
SSH_KEYS_DIR=${WORK_DIR}/sshkeys
echo -e "export WORK_DIR=${WORK_DIR}\nexport PROJECT_DIR=${PROJECT_DIR}\nexport SSH_KEYS_DIR=${SSH_KEYS_DIR}" > ${WORK_DIR}/env.sh


PRIVATE_KEY_PATH=
PRIVATE_KEY_NAME=github_sshkey
if [ ! -d "${SSH_KEYS_DIR}" ]; then
    mkdir -p ${SSH_KEYS_DIR}
fi

if [ ! -f ${SSH_KEYS_DIR}/${PRIVATE_KEY_NAME} ]; then
    PRIVATE_KEY_TMP_PATH=`mktemp -d`
    PRIVATE_KEY_PATH=${PRIVATE_KEY_TMP_PATH}/${PRIVATE_KEY_NAME}
    kitty ssh-keygen -t ed25519 -C "is140608/sys_devel_env" -f ${PRIVATE_KEY_PATH}
    ERROR_CODE=$?
    if [ ${ERROR_CODE} -ne 0 ]; then
        echo "Cannot create ssh keys, error: ${ERROR_CODE}"
        PRIVATE_KEY_PATH=
    elif [ ! -f ${PRIVATE_KEY_PATH} ]; then
        kitty sh -c "read -p \"SSH-key hasn't been created! If yout want to have a personal github access, please import your private & public keys as '${SSH_KEYS_DIR}/${PRIVATE_KEY_NAME}' and '${SSH_KEYS_DIR}/${PRIVATE_KEY_NAME}.pub' accordingly\"" > /dev/null 2>&1
        PRIVATE_KEY_PATH=
    else
        mv ${PRIVATE_KEY_PATH} ${SSH_KEYS_DIR}/
        mv ${PRIVATE_KEY_PATH}.pub ${SSH_KEYS_DIR}/
        PUB_KEY_CONTENT=`cat ${SSH_KEYS_DIR}/${PRIVATE_KEY_NAME}.pub`
        PRIVATE_KEY_PATH=${SSH_KEYS_DIR}/${PRIVATE_KEY_NAME}
        kitty --hold echo -e "Please copy this key and register it using you github account:\n${PUB_KEY_CONTENT}\n\nThen close this window to proceed. If you have lost the key, please check out the directory: ${SSH_KEYS_DIR}.\n\nYou may close this terminal window!"
    fi
    # remove tmp dir
    if [ ! -z ${PRIVATE_KEY_TMP_PATH} ]; then
        if [ -d ${PRIVATE_KEY_TMP_PATH} ]; then
            rm -rf ${PRIVATE_KEY_TMP_PATH}
        fi
    fi
else
    PRIVATE_KEY_PATH=${SSH_KEYS_DIR}/${PRIVATE_KEY_NAME}
    echo -e "Using an existing SSH key by the path: ${PRIVATE_KEY_PATH}"
fi

#TERM=$(basename "$(cat "/proc/$PPID/comm")")
if [ ! -z ${PRIVATE_KEY_PATH} ]; then
    kitty ${WORK_DIR}/register_ssh_key.sh ${PRIVATE_KEY_PATH}
fi

${WORK_DIR}/run_cmd_forever.sh geany &
${WORK_DIR}/run_cmd_forever.sh kitty &
${WORK_DIR}/run_cmd_forever.sh kitty mc &
${WORK_DIR}/run_cmd_forever.sh firefox &

sleep infinity &
wait $!
