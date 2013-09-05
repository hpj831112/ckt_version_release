#!/bin/bash

echo "*******************************************************************************************"
echo "*                                                                                         *"
echo "*                                  CKT VERSION RELEAS                                     *"
echo "*                                  VERSION beta-v1.0                                      *"
echo "*                           AUTROR HePeijiang ZhaoDan YaoZhilin                           *"
echo "*                (c) Copyright ckt version release 2013.  All rights reserved.            *"
echo "*                                                                                         *"
echo "*******************************************************************************************"                           

##defind vars

#project name
PROJECT_NAME="ckt72_we_jb3"

#target buil variant
TARGET_BUILD_VARIANT="user"

#version
VERSION=""

#only make package
IS_ONLY_MAKE_PACHAGE="n"

#user introduction
USAGE="Usage: $0 [-p project] [-t target_build_variant] [-v version] [-z n or y] [-x supper_packaged_option] [-? show_this_message] "

#option count
OPTION_COUNT=$#

#if there has not a option, show menu for user chooose
function fShowMenu(){
    local option1="ckt72_we_jb3-user"
    local option2="ckt72_we_jb3-eng"
    local option3="ckt72_we_lca-user"
    local option4="ckt72_we_lca-eng"
    echo -e "\033[49;34;5m ckt_release Menu...  Please choose a option:\033[0m \n\t 1.$option1\n\t 2.$option2\n\t 3.$option3\n\t 4.$option4\nInput the order of the project you choosed:\c"
    read order
    if [ "$order" = "1" ] ;then
       PROJECT_NAME=${option1%*-*}
       TARGET_BUILD_VARIANT=${option1#*-}
    elif [ "$order" = "2" ] ;then
       PROJECT_NAME=${option2%*-*}
       TARGET_BUILD_VARIANT=${option2#*-}
    elif [ "$order" = "3" ] ;then
       PROJECT_NAME=${option3%*-*}
       TARGET_BUILD_VARIANT=${option3#*-}
    elif [ "$order" = "4" ] ;then
       PROJECT_NAME=${option4%*-*}
       TARGET_BUILD_VARIANT=${option4#*-}
    else
       echo "Sorry you must input the muber order of the option!"
       fShowMenu;
    fi
}


if [ $OPTION_COUNT -eq 0 ] || [ "$1" = "-x" ] ;then
   fShowMenu;
fi

#read user input options
while getopts ":p:t:v:z:x" opt; do
    case $opt in
        p ) PROJECT_NAME=$OPTARG 
            ;;
        t ) TARGET_BUILD_VARIANT=$OPTARG 
            ;;
        v ) VERSION=$OPTARG 
            ;;
        z ) IS_ONLY_MAKE_PACHAGE=$OPTARG 
            ;;
       \x ) IS_ONLY_MAKE_PACHAGE="y"
            ;;
       \? ) echo $USAGE 
            exit 1 
            ;;
    esac
done

#defind global vars
CKT_HOME=`pwd`
CKT_HOME_OUT_PROJECT=${CKT_HOME}"/out/target/product/$PROJECT_NAME"
CKT_HOME_MTK_MODEM=${CKT_HOME}"/mediatek/custom/common/modem"
PROJECT_CONFIG_FILE="$CKT_HOME/mediatek/config/$PROJECT_NAME/ProjectConfig.mk"

cd /sbin
VERSION_RELEASE_HOME_T=`readlink ckt_release`
VERSION_RELEASE_SHELL_FOLDER=${VERSION_RELEASE_HOME_T%*/*}
VERSION_RELEASE_CONFIG_FILE="$VERSION_RELEASE_SHELL_FOLDER/config.conf"
cd -

#make ota different split package saved dir
OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR_T=`sed -n '/^OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR=${OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR_T#*=}

#get version param
FOLDER_NAME_PRE=""
HWV_BUILD_VERSION=""
HWV_PROJECT_NAME=""

function getVersionParam(){
	#read version control
	local HWV_PROJECT_NAME_T=`sed -n '/^HWV_PROJECT_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
	local HWV_VERSION_NAME_T=`sed -n '/^HWV_VERSION_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
	local HWV_RELEASE_NAME_T=`sed -n '/^HWV_RELEASE_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
	local HWV_CUSTOM_VERSION_T=`sed -n '/^HWV_CUSTOM_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
	local HWV_BUILD_VERSION_T=`sed -n '/^HWV_BUILD_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`

	HWV_PROJECT_NAME=${HWV_PROJECT_NAME_T#*=}
	local HWV_VERSION_NAME=${HWV_VERSION_NAME_T#*=}
	local HWV_RELEASE_NAME=${HWV_RELEASE_NAME_T#*=}
	local HWV_CUSTOM_VERSION=${HWV_CUSTOM_VERSION_T#*=}
	HWV_BUILD_VERSION=${HWV_BUILD_VERSION_T#*=}

	if [ "$IS_ONLY_MAKE_PACHAGE" = "y" ];then
		VERSION=$HWV_BUILD_VERSION
	fi

        FOLDER_NAME_PRE=$HWV_PROJECT_NAME$HWV_VERSION_NAME$HWV_RELEASE_NAME$HWV_CUSTOM_VERSION
}

getVersionParam;

if [ -z "$VERSION" ];then
	#defind target build version
	echo -e "Current build version is: \033[49;31;5m $HWV_BUILD_VERSION \033[0m, would you like to build the version? If is please click Enter to continue, else please input your build version: \c "

	#make folder name add set build version in project config file
	read BUILD_VERSION
	VERSION=$BUILD_VERSION

	if [ -z "$BUILD_VERSION" ] ;then
	    VERSION=$HWV_BUILD_VERSION
	fi

	if [ -n "$VERSION" ] ;then
	    if [ $VERSION != $HWV_BUILD_VERSION ] ;then   
	       sed -i "s/HWV_BUILD_VERSION \= $HWV_BUILD_VERSION/HWV_BUILD_VERSION \= $VERSION/g" "$PROJECT_CONFIG_FILE"
	    fi
	fi
else
   if [ $VERSION != $HWV_BUILD_VERSION ] ;then
      sed -i "s/HWV_BUILD_VERSION \= $HWV_BUILD_VERSION/HWV_BUILD_VERSION \= $VERSION/g" "$PROJECT_CONFIG_FILE"
   fi
fi

FOLDER_NAME=${FOLDER_NAME_PRE}${VERSION}"_"${TARGET_BUILD_VARIANT}

echo -e "Please confirm the build information:\n\t \033[49;31;5m Project Name:"${PROJECT_NAME}"\n\t  Target Build Version:" ${TARGET_BUILD_VARIANT}"\n\t  Build Version:"${VERSION}" \n\t The final package folder name: "${FOLDER_NAME}"\n\t Is only make package: "${IS_ONLY_MAKE_PACHAGE}"\033[0m \n\tit's correctly(y/n): \c "

read confirm
if [ "$confirm" = 'n' ] ;then
  exit
fi

function cleanDust(){
        echo -e "`date '+%Y%m%d  %T'` Begin to clean last release version's dust......!"
	${CKT_HOME}/mk clean
	rm -rf $CKT_HOME/out
	rm -rf $CKT_HOME/ckt/*.zip
        rm -rf $CKT_HOME/ckt/.bin
}

#build target version 
if [ "$IS_ONLY_MAKE_PACHAGE" = "n" ] ;then
	echo "+=========================================================================================+"
	echo "+=                    `date '+%Y%m%d  %T'` Call 'mk' to make version...                    =+"
	echo "+=========================================================================================+"

	#clear dust
	cleanDust;

	if [ "$TARGET_BUILD_VARIANT" = 'user' ] ;then
	   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME new
	   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME otapackage
	   sh ${CKT_HOME}/ckt/ckt_release.sh
	elif [ "$TARGET_BUILD_VARIANT" = 'eng' ] ;then
	   ${CKT_HOME}/mk $PROJECT_NAME new
	   ${CKT_HOME}/mk $PROJECT_NAME otapackage
	   sh ${CKT_HOME}/ckt/ckt_release.sh
	fi
fi

#make dir
echo "+=========================================================================================+"
echo "+=                  `date '+%Y%m%d  %T'` begin make ota package...                         =+"
echo "+=========================================================================================+"

rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME
cd $FOLDER_NAME
UPDATE_FOLDER=$FOLDER_NAME
OTA_FOLDER=${FOLDER_NAME}"_ota"
mkdir $UPDATE_FOLDER
mkdir $OTA_FOLDER
cd $UPDATE_FOLDER
mkdir sdcard_ota
mkdir usb_ota

#copy sdcard ota
echo -e "`date '+%Y%m%d  %T'` copy sdcard ota to folder..."
cd sdcard_ota
cp -f $CKT_HOME/out/target/product/$PROJECT_NAME/$PROJECT_NAME-ota-*.zip ./update.zip

#copy usb ota
echo -e "`date '+%Y%m%d  %T'` copy usb ota to folder..."
cd ../usb_ota
cp -f $CKT_HOME/ckt/.zip ./usb_ota.zip
unzip ./usb_ota.zip
mv ./ckt/.bin ${UPDATE_FOLDER}".bin"
rm -rf ./ckt
rm -f ./usb_ota.zip

#copy middle ota
echo -e "`date '+%Y%m%d  %T'` copy midlle ota to folder..."
cd ../../$OTA_FOLDER
cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip ./

#copy modem
echo -e "`date '+%Y%m%d  %T'` copy modem to folder..."
cd ../$UPDATE_FOLDER/usb_ota/${UPDATE_FOLDER}".bin"/DATABASE/
MODEM_DIR_T=`sed -n '/^CUSTOM_MODEM/p' "$PROJECT_CONFIG_FILE"`
CUSTOM_MODEM=${MODEM_DIR_T#*=}

cp -f $CKT_HOME_MTK_MODEM/$CUSTOM_MODEM/BPLGUInfoCustomAppSrcP_* ./

#make ota different split package
echo "+=========================================================================================+"
echo "+=      `date '+%Y%m%d  %T'` begin to make ota different split package...                  =+"
echo "+=========================================================================================+"
cd $OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR
DELETE_LINE_INPUT=`ls -t|awk -v a=$(pwd) '{print a"/"$0}'|sed -n '2, 10000p'|sed 'H;$!d;g;s/\n/  /g'`
rm -rf $DELETE_LINE_INPUT

DIFFERENT_INPUT=`ls -t|awk -v a=$(pwd) '{print a"/"$0}'|sed -n '1p'|sed 'H;$!d;g;s/\n/  /g'`

#make update ota package naem
UPDATE_OTA_PACKAGE_NAME=""
SHORT_PROJECT_NAME=""
PREVIOUS_VERSION=""
function makeUpdateOtaPackageName(){
	local T=`echo $VERSION|tr -cd '[0-9\n]'`
	local N=`expr $T \- 1`
	local S=`echo $N|awk '{printf "%03s\n" ,$0}'` #add '0' if length less than 3 at left
        local V_T=${VERSION/$T/$S}

        PREVIOUS_VERSION=${FOLDER_NAME_PRE}${V_T}
        local V=`echo $V_T|tr '[:upper:]' '[:lower:]'`
        
	#make short project name
        local SHORT_PROJECT_NAME_T=${HWV_PROJECT_NAME#*-}
	SHORT_PROJECT_NAME=`echo $SHORT_PROJECT_NAME_T|tr '[:upper:]' '[:lower:]'`

        local V_N=`echo $VERSION|tr '[:upper:]' '[:lower:]'` 
        
        UPDATE_OTA_PACKAGE_NAME=${SHORT_PROJECT_NAME}_${V}"--"${V_N}"_"${TARGET_BUILD_VARIANT}".zip"
}

makeUpdateOtaPackageName;
OTA_DIFF_FILE=$OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR/$UPDATE_OTA_PACKAGE_NAME

cd $CKT_HOME
./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $DIFFERENT_INPUT $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $OTA_DIFF_FILE

cd $OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR
mv $CKT_HOME/$FOLDER_NAME ./

cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip $OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR/${SHORT_PROJECT_NAME}"_"${VERSION}"_"${TARGET_BUILD_VARIANT}".zip"

echo -e "`date '+%Y%m%d  %T'` The release package is: \033[49;31;5m $FOLDER_NAME.zip \033[0m and the ota different split package is \033[49;31;5m update.zip \033[0m DOWN"


#  add for make vendor ota file
function makeVendorOtaFile() {
    VENDOR="huawei"
    OTA_UPDATE_FOLDER="ota_update_file";
    OTA_DIFF_FILE_MD5=$(md5sum ${OTA_DIFF_FILE} | cut -d' ' -f1)
    OTA_DIFF_FILE_SIZE=$(ls -la $OTA_DIFF_FILE | cut -d' ' -f5)
    FULL_DIR="full"
    INCREMENT_DIR="increment"
    OTA_CONFIG_DIR="config"
    UPDATE_PACKAGE_DIR="updatepackage"

    echo "making ${VENDOR} ota file, please wait..."

    cd $OTA_DIFFERENT_SPLIT_PACKAGE_SAVE_DIR

    echo "copying template... "

    mkdir $OTA_UPDATE_FOLDER
    cd $OTA_UPDATE_FOLDER

    cp -rf $VERSION_RELEASE_SHELL_FOLDER/data/${VENDOR}"_ota"/$UPDATE_PACKAGE_DIR ./
    cd $UPDATE_PACKAGE_DIR
    mkdir $FULL_DIR
    mkdir $INCREMENT_DIR

    #  modify xml about the ota info
    echo "modify ota xml config file..."

    cd $OTA_CONFIG_DIR

    CHANAGE_LOG_FILE="chanagelog.xml"
    FILE_LIST_FILE="filelist.xml"

    FEATURE_CONTENT="<feature>${PREVIOUS_VERSION} to ${FOLDER_NAME_PRE}${VERSION}</feature>"

    OTA_DIFF_MD5_CONTENT="<md5>"${OTA_DIFF_MD5}"</md5>"
    OTA_DIFF_FILE_SIZE_CONTENT="<size>"${OTA_DIFF_FILE_SIZE}"</size>"

    sed -i '7c'${FEATURE_CONTENT}'' $CHANAGE_LOG_FILE
    sed -i '12c'${FEATURE_CONTENT}'' $CHANAGE_LOG_FILE 

    CHANAGE_LOG_MD5=`md5sum ${CHANAGE_LOG_FILE} | cut -d' ' -f1`
    CHANAGE_LOG_FILE_SIZE=`ls -la ${CHANAGE_LOG_FILE} | cut -d' ' -f5`
    CHANAGE_LOG_MD5_CONTENT="<md5>"${CHANAGE_LOG_MD5}"</md5>"
    CHANAGE_LOG_FILE_SIZE_CONTENT="<size>"${CHANAGE_LOG_FILE_SIZE}"</size>"

    sed -i '12c'${CHANAGE_LOG_MD5_CONTENT}'' $FILE_LIST_FILE
    sed -i '13c'"${CHANAGE_LOG_FILE_SIZE_CONTENT}"'' $FILE_LIST_FILE 
    
    sed -i '16c'<spath>${UPDATE_OTA_PACKAGE_NAME}</spath>'' $FILE_LIST_FILE
    sed -i '17c'<dpath>${UPDATE_OTA_PACKAGE_NAME}</dpath>'' $FILE_LIST_FILE
    sed -i '19c'${FILE_LIST_MD5_CONTENT}'' $FILE_LIST_FILE
    sed -i '20c'${FILE_LIST_FILE_SIZE_CONTENT}'' $FILE_LIST_FILE

    cd ..

    # copy xml file and ota file to  dir
    echo "copying ${CHANAGE_LOG_FILE}  ${FILE_LIST_FILE} and ${UPDATE_OTA_PACKAGE_NAME} to ${FULL_DIR} and ${INCREMENT_DIR}"
    cp ${OTA_CONFIG_DIR}/${CHANAGE_LOG_FILE} ${FULL_DIR}/
    cp ${OTA_CONFIG_DIR}/${FILE_LIST_FILE} ${FULL_DIR}/
    cp ${OTA_DIFF_FILE} ${FULL_DIR}/ 
    cp ${OTA_CONFIG_DIR}/${CHANAGE_LOG_FILE} ${INCREMENT_DIR}/
    cp ${OTA_CONFIG_DIR}/${FILE_LIST_FILE} ${INCREMENT_DIR}/
    cp ${OTA_DIFF_FILE} ${INCREMENT_DIR}/
    cd .. 

    # package the ota file
    echo "packaging the ota file..."
    zip updatepackage.zip updatepackage/
    rm -rf "updatepackage"
    echo "package finished!"

    # print the final info, donesss
}

makeVendorOtaFile;
