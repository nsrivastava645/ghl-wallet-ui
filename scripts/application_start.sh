#!/bin/bash

#give permission for everything in the ghl-wallet-ui directory
sudo chmod -R 777 /home/ec2-user/ghl-wallet-ui

#navigate into our working directory where we have all our github files
cd /home/ec2-user/ghl-wallet-ui

#add npm and node to path
export NVM_DIR="$HOME/.nvm"	
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # loads nvm	
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # loads nvm bash_completion (node is in path now)

cd ./dist

#create our working directory if it doesnt exist
NEWDIR="./new-build"
mkdir -p ${NEWDIR}

#create our working directory if it doesnt exist
OLDDIR="./old-build"
mkdir -p ${OLDDIR}

rm -rf ${OLDDIR} && mv ${NEWDIR} ${OLDDIR} && mv ghl-wallet-ui ${NEWDIR}
