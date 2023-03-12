#!/bin/bash

TRASHGHOLD=${1:-20}
SLEEP_TIME=${2:-5}

while : ; do
    TAKE_SPACE_PERCENT=$(df -hP | awk '{if($NF=="/") print int($5)}')
   ((FREE_SPACE=100-${TAKE_SPACE_PERCENT}))

    if [ "$FREE_SPACE" -lt "$TRASHGHOLD" ]; then
        echo -e "\033[38;5;202mWARNING: Free disk space is below ${TRASHGHOLD}%!\033[0m"
    fi

    echo "Watch every ${SLEEP_TIME} seconds..."
    echo "Enter Ctrl + c to exit"
    echo "===================================="
    echo ""

   
    sleep ${SLEEP_TIME}
done