#!/bin/bash

#defind vars
PROJECT_NAME=$1
TARGET_BUILD_VARIANT=$2

#if there has not o option, show menu for user chooose
function fShowProjectNameMenu(){
    echo -e "ckt_release Menu...  Please choose a project:\n1.ckt72_we_jb3\n2.ckt72_we_lca\n3.banyan_addon\nInput the order of the project you choosed:\c"
    read order
    if [ "$order" = "1" ] ;then
       PROJECT_NAME="ckt72_we_jb3"
    elif [ "$order" = "2" ] ;then
        PROJECT_NAME="ckt72_we_lca"
    elif [ "$order" = "3" ] ;then
        PROJECT_NAME="banyan_addon"
    else
       echo "Sorry you must input the muber order of the project!"
       fShowProjectNameMenu;
    fi
}

function fShowTargetMenu(){
    echo -e "ckt_release Menu...  Please choose a build version:\n1.user\n2.eng\n3.p_user\n4.p_eng\nInput the order of the build version you choosed:\c"
    read target
    if [ "$target" = "1" ] ;then
       TARGET_BUILD_VARIANT="user"
    elif [ "$target" = "2" ] ;then
       TARGET_BUILD_VARIANT="eng"
    elif [ "$target" = "3" ] ;then
       TARGET_BUILD_VARIANT="p_user"
    elif [ "$target" = "4" ] ;then
       TARGET_BUILD_VARIANT="p_eng"
    else
       echo "Sorry you must input the muber order of the build version!"
       fShowTargetMenu;
    fi
}

if [ -z "$PROJECT_NAME" ] ;then
   fShowProjectNameMenu;
fi

if [ -z "$TARGET_BUILD_VARIANT" ] ;then
   fShowTargetMenu;
fi

CKT_HOME=`pwd`
CKT_HOME_OUT_PROJECT=${CKT_HOME}"/out/target/product/$PROJECT_NAME"
CKT_HOME_MTK_MODEM=${CKT_HOME}"/mediatek/custom/common/modem"

#read version control
PROJECT_CONFIG_FILE="$CKT_HOME/mediatek/config/$PROJECT_NAME/ProjectConfig.mk"
HWV_PROJECT_NAME_T=`sed -n '/^HWV_PROJECT_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
HWV_VERSION_NAME_T=`sed -n '/^HWV_VERSION_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
HWV_RELEASE_NAME_T=`sed -n '/^HWV_RELEASE_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
HWV_CUSTOM_VERSION_T=`sed -n '/^HWV_CUSTOM_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
HWV_BUILD_VERSION_T=`sed -n '/^HWV_BUILD_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`

#get version param
HWV_PROJECT_NAME=${HWV_PROJECT_NAME_T#*=}
HWV_VERSION_NAME=${HWV_VERSION_NAME_T#*=}
HWV_RELEASE_NAME=${HWV_RELEASE_NAME_T#*=}
HWV_CUSTOM_VERSION=${HWV_CUSTOM_VERSION_T#*=}
HWV_BUILD_VERSION=${HWV_BUILD_VERSION_T#*=}

#defind target build version
FOLDER_NAME=$HWV_PROJECT_NAME$HWV_VERSION_NAME$HWV_RELEASE_NAME$HWV_CUSTOM_VERSION$HWV_BUILD_VERSION
echo -e "Current version is: \033[49;31;5m $FOLDER_NAME \033[0m, would you like to build the version? If is please click Enter to continue, else please input your build version: \c "

#make folder name add set build version in project config file
read BUILD_VERSION
VERSION=$BUILD_VERSION
if [ -n "$VERSION" ] ;then
    if [ $VERSION != $HWV_BUILD_VERSION ] ;then
       FOLDER_NAME=$HWV_PROJECT_NAME$HWV_VERSION_NAME$HWV_RELEASE_NAME$HWV_CUSTOM_VERSION$VERSION
       sed -i "s/HWV_BUILD_VERSION \= $HWV_BUILD_VERSION/HWV_BUILD_VERSION \= $VERSION/g" "$PROJECT_CONFIG_FILE"
    fi
fi

#build target version 
if [ $TARGET_BUILD_VARIANT = 'user' ] ;then
   echo "Begin to release user version, please wait a moment!"
   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME new
   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME otapackage
   sh ${CKT_HOME}/ckt/ckt_release.sh
elif [ $TARGET_BUILD_VARIANT = 'eng' ] ;then
   echo "Begin to release engineering version, please wait a moment!"
   ${CKT_HOME}/mk $PROJECT_NAME new
   ${CKT_HOME}/mk $PROJECT_NAME otapackage
   sh ${CKT_HOME}/ckt/ckt_release.sh
else
   echo "The version is maked, make the release package, please wait a moment!"
   TARGET_BUILD_VARIANT=${TARGET_BUILD_VARIANT#*_}
fi

#make dir
echo "making dir..."
rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME
cd $FOLDER_NAME
UPDATE_FOLDER=${FOLDER_NAME}"_"${TARGET_BUILD_VARIANT}
OTA_FOLDER=${FOLDER_NAME}"_"${TARGET_BUILD_VARIANT}"_ota"
mkdir $UPDATE_FOLDER
mkdir $OTA_FOLDER
cd $UPDATE_FOLDER
mkdir sdcard_ota
mkdir usb_ota

#copy sdcard ota
echo "copy sdcard ota to folder..."
cd sdcard_ota
cp -f $CKT_HOME/out/target/product/$PROJECT_NAME/$PROJECT_NAME-ota-*.zip ./update.zip

#copy usb ota
echo "copy usb ota to folder..."
cd ../usb_ota
cp -f $CKT_HOME/ckt/.zip ./usb_ota.zip
unzip ./usb_ota.zip
mv ./ckt/.bin ${UPDATE_FOLDER}".bin"
rm -rf ./ckt
rm -f ./usb_ota.zip

#copy middle ota
echo "copy midlle ota to folder..."
cd ../../$OTA_FOLDER
cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip ./

#copy modem
echo "copy modem ota to folder..."
cd ../$UPDATE_FOLDER/usb_ota/${UPDATE_FOLDER}".bin"/DATABASE/
MODEM_DIR_T=`sed -n '/^CUSTOM_MODEM/p' "$PROJECT_CONFIG_FILE"`
CUSTOM_MODEM=${MODEM_DIR_T#*=}

MODEM_NAME_T1=`sed -n '/^DATABASE_SOURCE/p' "$CKT_HOME/ckt/ckt_release.sh"`
MODEM_NAME_T2=${MODEM_NAME_T1/\"/}
MODEM_NAME=${MODEM_NAME_T2/\\/}
eval $MODEM_NAME

cp -f $DATABASE_SOURCE ./

#make zip package
echo "make zip package..."
cd $CKT_HOME
zip -qrm ${FOLDER_NAME}".zip" $FOLDER_NAME

mv ${FOLDER_NAME}".zip" ../
cd ../

echo -e "\033[49;31;5m The release package is: $FOLDER_NAME.zip \033[0m DOWN"
