#!/bin/bash

echo "smartide_web_terminal.sh"

echo ${TERMINAL_USER}

su ${TERMINAL_USER} -s /bin/bash -c "/home/smartide/.nvm/versions/node/v14.17.6/bin/node /home/webterminal/bin/webshell"