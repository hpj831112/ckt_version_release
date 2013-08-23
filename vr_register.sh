#!/bin/bash

CURRENT_PATH=`pwd`

echo -e "Please input the password of root: \c"
read -s PWD
PASSWORD=$PWD

#make soft link to /sbin
sudo ln -sf $CURRENT_PATH/version_release.sh /sbin/ckt_release<< EOF
 $PASSWORD
EOF

sudo chown -Rf ckt /sbin/ckt_release<< EOF
 $PASSWORD
EOF
