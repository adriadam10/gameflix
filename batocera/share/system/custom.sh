#!/bin/bash
if [ "$1" == "start" ]
then 
    # Log to a file in /userdata/system for persistence or troubleshooting
    curl -s -L https://raw.githubusercontent.com/adriadam10/gameflix/main/batocera.sh | bash &> /userdata/system/gameflix_setup.log
fi
