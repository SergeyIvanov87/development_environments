#!/bin/bash

PRIVATE_KEY_PATH=$1

if [ ! -z ${PRIVATE_KEY_PATH} ]; then
	if [ -f ${PRIVATE_KEY_PATH} ]; then
	
		echo "Adding the private key: ${PRIVATE_KEY_PATH} to an ssh-agent by PID: ${SSH_AGENT_PID}"
		ssh-add -l &>/dev/null
		[[ "$?" == 2 ]] && eval "$(ssh-agent -s)"

		chmod 600 ${PRIVATE_KEY_PATH}
		ssh-add ${PRIVATE_KEY_PATH}
		if [ $? -eq 0 ]; then
			echo "SSH private key has been successfully registered"
		fi
	else	
		echo "${PRIVATE_KEY_PATH} is not a file or doesn't exist. Exit"
		exit -2
	fi
else 
	echo "PRIVATE_KEY_PATH is empty. Exit"
	exit -1
fi

exit 0
