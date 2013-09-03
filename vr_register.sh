#!/bin/bash

CURRENT_PATH=`pwd`

echo -e "Please input the password of root: \c"
read -s PWD
PASSWORD=$PWD

sudo rm -f /sbin/ckt_release<< EOF
 $PASSWORD
EOF

#make soft link to /sbin
sudo ln -sf $CURRENT_PATH/version_release.sh /sbin/ckt_release<< EOF
 $PASSWORD
EOF

#change owner
sudo chown -Rf ckt /sbin/ckt_release<< EOF
 $PASSWORD
EOF

#change permission
sudo chmod -f 777 ckt /sbin/ckt_release<< EOF
 $PASSWORD
EOF

cd $HOME
rm -rf ckt_version_release
mkdir ckt_version_release
cp -f $CURRENT_PATH/config.conf $HOME/ckt_version_release/config.conf
