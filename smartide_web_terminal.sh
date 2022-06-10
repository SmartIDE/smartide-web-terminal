#!/bin/bash

echo "smartide_web_terminal.sh"

echo "Terminal run user:"${TERMINAL_USER}
#rm -rf .eslintignore .eslintrc.js .git .github .gitignore .ide .npmignore .npmrc Dockerfile LICENSE README.md assets package.json package-lock.json smartide_web_terminal.sh views webshell.gif

su ${TERMINAL_USER} -s /bin/bash -c "/home/smartide/.nvm/versions/node/v14.17.6/bin/node /home/webterminal/bin/webshell"