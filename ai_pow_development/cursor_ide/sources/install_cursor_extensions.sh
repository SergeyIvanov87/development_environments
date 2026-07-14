#!/bin/bash

WORK_DIR=${1}
for ext in `cat ${WORK_DIR}/cursor_extension_list;`
do
    if ! cursor --list-extensions | grep ${ext} ; then
        cursor --install-extension ${ext}
    fi
done
