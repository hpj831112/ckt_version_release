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

#last version package name
LAST_VERSION_PACKAGE_NAME=""

#user introduction
USAGE="Usage: $0 [-p project] [-t target_build_variant] [-v version] [-z n or y] [-O last version_package_name] [-x supper_packaged_option] [-? show_this_message] "

#option count
OPTION_COUNT=$#

function checkCommandExc(){
	if [ $? -ne 0 ];then
	  echo -e "\033[49;31;5m There has some errors during the command executing, please check it! The program will exit! \033[0m EXIT"
          exit 1;
	fi
}

#if there has not a option, show menu for user chooose
function fShowMenu(){
    local option1="ckt72_we_jb3-user"
    local option2="ckt72_we_jb3-eng"
    local option3="ckt72_we_lca-user"
    local option4="ckt72_we_lca-eng"

    echo -e "\033[49;34;5m ckt_release Menu...  Please choose a option: "
    echo -e "\t 1.$option1"
    echo -e "\t 2.$option2"
    echo -e "\t 3.$option3"
    echo -e "\t 4.$option4 \033[0m "
    echo -e "Input the order of the project you choosed:\c"

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
while getopts ":p:t:v:z:o:x" opt; do
    case $opt in
        p ) PROJECT_NAME=$OPTARG 
            ;;
        t ) TARGET_BUILD_VARIANT=$OPTARG 
            ;;
        v ) VERSION=$OPTARG 
            ;;
        z ) IS_ONLY_MAKE_PACHAGE=$OPTARG 
            ;;
        O ) LAST_VERSION_PACKAGE_NAME=$OPTARG 
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
FINAL_PACKAGE_SAVE_DIR_T=`sed -n '/^FINAL_PACKAGE_SAVE_DIR/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
checkCommandExc;

FINAL_PACKAGE_SAVE_DIR=${FINAL_PACKAGE_SAVE_DIR_T#*=}
if [ ! -d "$FINAL_PACKAGE_SAVE_DIR" ]; then 
        echo -e "The final files save dir is not exist, now begin to make it! Please remenber the folder name \033[49;34;5m $FINAL_PACKAGE_SAVE_DIR \033[0m "
	mkdir -p "$FINAL_PACKAGE_SAVE_DIR" 
fi 


#get version param
FOLDER_NAME_PRE=""
HWV_BUILD_VERSION=""
HWV_PROJECT_NAME=""

function getVersionParam(){
	#read version control
	local HWV_PROJECT_NAME_T=`sed -n '/^HWV_PROJECT_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
        checkCommandExc;

	local HWV_VERSION_NAME_T=`sed -n '/^HWV_VERSION_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
        checkCommandExc;

	local HWV_RELEASE_NAME_T=`sed -n '/^HWV_RELEASE_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
        checkCommandExc;

	local HWV_CUSTOM_VERSION_T=`sed -n '/^HWV_CUSTOM_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
        checkCommandExc;

	local HWV_BUILD_VERSION_T=`sed -n '/^HWV_BUILD_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
        checkCommandExc;

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
	echo -e "Current build version is: \033[49;31;5m $HWV_BUILD_VERSION \033[0m would you like to build the version?"
        echo "If is please click Enter to continue, else please input your build version: \c "

	#make folder name add set build version in project config file
	read BUILD_VERSION
	VERSION=$BUILD_VERSION

	if [ -z "$BUILD_VERSION" ] ;then
	    VERSION=$HWV_BUILD_VERSION
	fi

	if [ -n "$VERSION" ] ;then
	    if [ $VERSION != $HWV_BUILD_VERSION ] ;then   
	       sed -i "s/HWV_BUILD_VERSION \= $HWV_BUILD_VERSION/HWV_BUILD_VERSION \= $VERSION/g" "$PROJECT_CONFIG_FILE"
               checkCommandExc;
	    fi
	fi
else
   if [ $VERSION != $HWV_BUILD_VERSION ] ;then
      sed -i "s/HWV_BUILD_VERSION \= $HWV_BUILD_VERSION/HWV_BUILD_VERSION \= $VERSION/g" "$PROJECT_CONFIG_FILE"
      checkCommandExc;
   fi
fi

#get last version package name for make ota differnt split package
if [ -z "$LAST_VERSION_PACKAGE_NAME" ];then
	echo -e "\033[49;31;5m You must input the last version package name for us to make ota differnt split package, \033[0m, The name is: \c "
        read NAME
        if [ -z "$NAME" ] ;then
	    fShowMenu;
        else
            LAST_VERSION_PACKAGE_NAME=$NAME
	fi
fi

FOLDER_NAME=${FOLDER_NAME_PRE}${VERSION}"_"${TARGET_BUILD_VARIANT}

echo -e "Please confirm the build information:"
echo -e "\t Project Name:\033[49;31;5m "${PROJECT_NAME}"\033[0m "
echo -e "\t Target Build Version:\033[49;31;5m " ${TARGET_BUILD_VARIANT}"\033[0m "
echo -e "\t Build Version:\033[49;31;5m "${VERSION}"\033[0m "
echo -e "\t The final package folder name:\033[49;31;5m "${FOLDER_NAME}"\033[0m "
echo -e "\t Is only make package:\033[49;31;5m "${IS_ONLY_MAKE_PACHAGE}"\033[0m "
echo -e "\t Last version package name:\033[49;31;5m "${LAST_VERSION_PACKAGE_NAME}"\033[0m "
echo -e "\t it's correctly(y/n): \c "

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
	   checkCommandExc;

	   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME otapackage
           checkCommandExc;

	   sh ${CKT_HOME}/ckt/ckt_release.sh
	elif [ "$TARGET_BUILD_VARIANT" = 'eng' ] ;then
	   ${CKT_HOME}/mk $PROJECT_NAME new
           checkCommandExc;

	   ${CKT_HOME}/mk $PROJECT_NAME otapackage
	   checkCommandExc;

	   sh ${CKT_HOME}/ckt/ckt_release.sh
	fi
fi

#make dir
echo "+=========================================================================================+"
echo "+=                  `date '+%Y%m%d  %T'` begin make ota package...                         =+"
echo "+=========================================================================================+"

cd $FINAL_PACKAGE_SAVE_DIR
rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME

cd $FOLDER_NAME
UPDATE_FOLDER=$FOLDER_NAME
OTA_FOLDER=${FOLDER_NAME}"_ota"
mkdir $UPDATE_FOLDER
mkdir $OTA_FOLDER
mkdir ota_update_file

cd $UPDATE_FOLDER
mkdir sdcard_ota
mkdir usb_ota

#copy sdcard ota
echo -e "`date '+%Y%m%d  %T'` copy sdcard ota to folder..."
cd sdcard_ota
cp -f $CKT_HOME/out/target/product/$PROJECT_NAME/$PROJECT_NAME-ota-*.zip ./update.zip
checkCommandExc;

#copy usb ota
echo -e "`date '+%Y%m%d  %T'` copy usb ota to folder..."
cd ../usb_ota
cp -f $CKT_HOME/ckt/.zip ./usb_ota.zip

checkCommandExc;

unzip ./usb_ota.zip
mv ./ckt/.bin ${UPDATE_FOLDER}".bin"
rm -rf ./ckt
rm -f ./usb_ota.zip

#copy middle ota
echo -e "`date '+%Y%m%d  %T'` copy midlle ota to folder..."
cd ../../$OTA_FOLDER
cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip ./

checkCommandExc;

#copy modem
echo -e "`date '+%Y%m%d  %T'` copy modem to folder..."
cd ../$UPDATE_FOLDER/usb_ota/${UPDATE_FOLDER}".bin"/DATABASE/
MODEM_DIR_T=`sed -n '/^CUSTOM_MODEM/p' "$PROJECT_CONFIG_FILE"`
CUSTOM_MODEM=${MODEM_DIR_T#*=}

cp -f $CKT_HOME_MTK_MODEM/$CUSTOM_MODEM/BPLGUInfoCustomAppSrcP_* ./

checkCommandExc;

#make ota different split package
echo "+=========================================================================================+"
echo "+=      `date '+%Y%m%d  %T'` begin to make ota different split package...                  =+"
echo "+=========================================================================================+"

function getLastVersionPackage(){
	local FTP_ADDR_T=`sed -n '/^FTP_ADD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
        local FTP_ADDR=${FTP_ADDR_T#*=}

	local FTP_USER_NAME_T=`sed -n '/^FTP_USER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
        local FTP_USER_NAME=${FTP_USER_NAME_T#*=}

	local FTP_USER_PASSORD_T=`sed -n '/^FTP_USER_PASSORD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
        local FTP_USER_PASSORD=${FTP_USER_PASSORD_T#*=}
        
        local FTP_URL=$FTP_USER_NAME":"$FTP_USER_PASSORD"@"$FTP_ADDR

        echo $FTP_URL
        local TEMP_FOLDER_NAME="Y320U_EMMC/HOAT中间文件/$HWV_PROJECT_NAME/${HWV_PROJECT_NAME}"_"${TARGET_BUILD_VARIANT}";

#lftp $FTP_URL<< EOF
	#cd $TEMP_FOLDER_NAME;
        #get $LAST_VERSION_PACKAGE_NAME;
        #exit;
	
#EOF
}

#getLastVersionPackage
cd $FINAL_PACKAGE_SAVE_DIR/

if [ -f "$LAST_VERSION_PACKAGE_NAME" ]; then
	mv $LAST_VERSION_PACKAGE_NAME ./$FOLDER_NAME/ota_update_file
else
        cd $FOLDER_NAME/ota_update_file
	getLastVersionPackage;
	cd -
fi 

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
OTA_DIFF_FILE=$FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/ota_update_file/$UPDATE_OTA_PACKAGE_NAME

cd $CKT_HOME
./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/ota_update_file/$LAST_VERSION_PACKAGE_NAME $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $OTA_DIFF_FILE
checkCommandExc;

rm -f $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/ota_update_file/$LAST_VERSION_PACKAGE_NAME

cd $FINAL_PACKAGE_SAVE_DIR

cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip  $FINAL_PACKAGE_SAVE_DIR/${SHORT_PROJECT_NAME}"_"${VERSION}"_"${TARGET_BUILD_VARIANT}".zip"
checkCommandExc;

echo -e "`date '+%Y%m%d  %T'` The release package is: \033[49;31;5m $FOLDER_NAME.zip \033[0m and the ota different split package is \033[49;31;5m update.zip \033[0m DOWN"


#  add for make vendor ota file
function makeVendorOtaFile() {
    cd $FOLDER_NAME/ota_update_file

    local VENDOR_T=`sed -n '/^VENDOR/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    local VENDOR=${VENDOR_T#*=}

    local OTA_UPDATE_COMPONENT_NAME_T=`sed -n '/^OTA_UPDATE_COMPONENT_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    local OTA_UPDATE_COMPONENT_NAME=${OTA_UPDATE_COMPONENT_NAME_T#*=}

    local FULL_DIR_T=`sed -n '/^OTA_UPDATE_FULL_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    local FULL_DIR=${FULL_DIR_T#*=}

    local OTA_CONFIG_DIR_T=`sed -n '/^OTA_UPDATE_CONFIG_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    local OTA_CONFIG_DIR=${OTA_CONFIG_DIR_T#*=}

 local UPDATE_PACKAGE_DIR_T=`sed -n '/^OTA_UPDATE_PACKAGE_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    local UPDATE_PACKAGE_DIR=${UPDATE_PACKAGE_DIR_T#*=}

    local CHANAGE_LOG_FILE_T=`sed -n '/^OTA_UPDATE_CHANAGE_LOG_FILE/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    local CHANAGE_LOG_FILE=${CHANAGE_LOG_FILE_T#*=}

    local FILE_LIST_FILE_T=`sed -n '/^OTA_UPDATE_FILE_LIST_FILE/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    local FILE_LIST_FILE=${FILE_LIST_FILE_T#*=}

    cp -rf $VERSION_RELEASE_SHELL_FOLDER/data/${VENDOR}"_ota"/$UPDATE_PACKAGE_DIR ./
    checkCommandExc;

    cd $UPDATE_PACKAGE_DIR
    mkdir $FULL_DIR

    cd $OTA_CONFIG_DIR
    local VERSION_CONTENT="<component name=\"$OTA_UPDATE_COMPONENT_NAME\" version=\"${FOLDER_NAME_PRE}${VERSION}\"\/\>"
    local VERSION_CONTENT="<component name=\"TCPU\" version=\"${FOLDER_NAME_PRE}${VERSION}\"\/\>"
    local FEATURE_CONTENT="\<feature\>$PREVIOUS_VERSION to ${FOLDER_NAME_PRE}${VERSION}\<\/feature\>"
    sed -i "3s/.*/$VERSION_CONTENT/g" "$CHANAGE_LOG_FILE"
    checkCommandExc;

    sed -i "7s/.*/$FEATURE_CONTENT/g" "$CHANAGE_LOG_FILE"
    checkCommandExc;

    sed -i "12s/.*/$FEATURE_CONTENT/g" "$CHANAGE_LOG_FILE"
    checkCommandExc;

    local CHANAGE_LOG_MD5_CONTENT="\<md5\>"`md5sum $CHANAGE_LOG_FILE | cut -d' ' -f1|tr '[:lower:]' '[:upper:]'`"\<\/md5\>"
    local CHANAGE_LOG_FILE_SIZE_CONTENT="\<size\>"`ls -la $CHANAGE_LOG_FILE | cut -d' ' -f5`"\<\/size\>"
    sed -i "12s/.*/$CHANAGE_LOG_MD5_CONTENT/g" "$FILE_LIST_FILE"
    checkCommandExc;

    sed -i "13s/.*/$CHANAGE_LOG_FILE_SIZE_CONTENT/g" "$FILE_LIST_FILE"
    checkCommandExc;

    local SAPTH="\<spath\>$UPDATE_OTA_PACKAGE_NAME\<\/spath\>"
    local DPATH="\<dpath\>$UPDATE_OTA_PACKAGE_NAME\<\/dpath\>"
    sed -i "16s/.*/$SAPTH/g" "$FILE_LIST_FILE"
    checkCommandExc;

    sed -i "17s/.*/$DPATH/g" "$FILE_LIST_FILE"
    checkCommandExc;

    local OTA_DIFF_MD5_CONTENT="\<md5\>`md5sum $OTA_DIFF_FILE | cut -d' ' -f1|tr '[:lower:]' '[:upper:]'`\<\/md5\>"
    local OTA_DIFF_FILE_SIZE_CONTENT="\<size\>`ls -la $OTA_DIFF_FILE | cut -d' ' -f5`\<\/size\>"
    sed -i "19s/.*/$OTA_DIFF_MD5_CONTENT/g" "$FILE_LIST_FILE"
    checkCommandExc;

    sed -i "20s/.*/$OTA_DIFF_FILE_SIZE_CONTENT/g" "$FILE_LIST_FILE"
    checkCommandExc;

    cd ..

    # copy xml file and ota file to  dir
    echo "copying $CHANAGE_LOG_FILE $FILE_LIST_FILE and $UPDATE_OTA_PACKAGE_NAME to $FULL_DIR"
    cp $OTA_CONFIG_DIR/$CHANAGE_LOG_FILE $FULL_DIR/
    checkCommandExc;

    cp $OTA_CONFIG_DIR/$FILE_LIST_FILE $FULL_DIR/
    checkCommandExc;

    cp $OTA_DIFF_FILE $FULL_DIR/ 
    rm -f $OTA_DIFF_FILE
    checkCommandExc;

    rm -rf $OTA_CONFIG_DIR
    cd .. 

    # package the ota file
    echo "packaging the ota file..."
    zip -rm "updatepackage.zip" updatepackage/
    echo "package finished!"
}

#make vendor ota file
echo "+=========================================================================================+"
echo "+=      `date '+%Y%m%d  %T'` begin to make vendor ota file...                  =+"
echo "+=========================================================================================+"
makeVendorOtaFile;
