#!/bin/bash                         

##defind vars

#project name
PROJECT_NAME="ckt72_we_jb3"

#target buil variant
TARGET_BUILD_VARIANT="user"

#version
VERSION=""

#interior version
INTERNAL_VERSION=""

#demain is only build
IS_ONLY_BUILD="F"

#the last version which user want to compare
OTA_COMPARED_VERSION=""

#only make package
IS_ONLY_MAKE_PACHAGE="n"

#last version package name
OTA_COMPARED_VERSION_PACKAGE_NAME=""

#user introduction
USAGE="Usage: $0 [-p project] [-t target_build_variant] [-v version] [-m only_build] [-z n or y] [-n only_make_package] [-o ota_compares_version_package_name] [-l ota_compared_version] [-x supper_packaged_option] [-w make_vendor_ota_package] [-? show_this_message] "

#option count
OPTION_COUNT=$#

#record if the menu is showed
IS_MENU_SHOW="T"

#demaid the copyright is showing
IS_SHOW_COPYRIGHT="T"

#demain is make the ota package
IS_MAKE_OTA_PACKAGE="T"

#demain is make the huawei ota package
IS_MAKE_HUAWEI_OTA_PACKAGE="F"

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

#read user input options
while getopts ":p:t:v:i:z:o:l:mnwx" opt; do
    case $opt in
        p ) PROJECT_NAME=$OPTARG 
            ;;
        t ) TARGET_BUILD_VARIANT=$OPTARG 
            ;;
        v ) VERSION=`echo $OPTARG|tr '[:lower:]' '[:upper:]'` 
            ;;
        i ) INTERNAL_VERSION=`echo $OPTARG|tr '[:lower:]' '[:upper:]'` 
            ;;
       \m ) IS_ONLY_BUILD="T" 
            ;;
        z ) IS_ONLY_MAKE_PACHAGE=$OPTARG 
            ;;
        o ) OTA_COMPARED_VERSION_PACKAGE_NAME=$OPTARG 
            ;;
        l ) OTA_COMPARED_VERSION=`echo $OPTARG|tr '[:lower:]' '[:upper:]'`  
            ;;
       \n ) IS_MAKE_OTA_PACKAGE="F" 
            ;;
       \w ) IS_MAKE_HUAWEI_OTA_PACKAGE="T"
            ;;
       \x ) IS_ONLY_MAKE_PACHAGE="y"
            ;;
       \? ) echo $USAGE 
	    IS_SHOW_COPYRIGHT="F"
            exit 1 
            ;;
    esac
done

function showCopyright(){
	echo "*******************************************************************************************"
	echo "*                                                                                         *"
	echo "*                                  CKT VERSION RELEAS                                     *"
	echo "*                                  VERSION beta-v1.0.1                                    *"
	echo "*                           AUTROR HePeijiang ZhaoDan YaoZhilin                           *"
	echo "*                (c) Copyright ckt version release 2013.  All rights reserved.            *"
	echo "*                                                                                         *"
	echo "*******************************************************************************************" 
} 

if [ "T" = "$IS_SHOW_COPYRIGHT" ]; then
	showCopyright;
fi

if [ $OPTION_COUNT -eq 0 ] || [ "$1" = "-x" ]  || [ "$1" = "-l" ] || [ "$1" = "-m" ] || [ "$1" = "-w" ]; then
   fShowMenu;
   IS_MENU_SHOW="T"
fi

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

VENDOR_T=`sed -n '/^VENDOR/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
VENDOR=${VENDOR_T#*=}

#get version param
FOLDER_NAME_PRE=""
HWV_BUILD_VERSION=""
HWV_BUILDINTERNAL_VERSION=""
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

	local HWV_BUILDINTERNAL_VERSION_T=`sed -n '/^HWV_BUILDINTERNAL_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
        checkCommandExc;

	local HWV_BUILD_VERSION_T=`sed -n '/^HWV_BUILD_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
        checkCommandExc;

	HWV_PROJECT_NAME=${HWV_PROJECT_NAME_T#*=}
	local HWV_VERSION_NAME=${HWV_VERSION_NAME_T#*=}
	local HWV_RELEASE_NAME=${HWV_RELEASE_NAME_T#*=}
	local HWV_CUSTOM_VERSION=${HWV_CUSTOM_VERSION_T#*=}
	HWV_BUILD_VERSION=${HWV_BUILD_VERSION_T#*=}
        HWV_BUILDINTERNAL_VERSION=${HWV_BUILDINTERNAL_VERSION_T#*=}

	if [ "$IS_ONLY_MAKE_PACHAGE" = "y" ];then
		VERSION=$HWV_BUILD_VERSION
		INTERNAL_VERSION=$HWV_BUILDINTERNAL_VERSION
	fi

        FOLDER_NAME_PRE=$HWV_PROJECT_NAME$HWV_VERSION_NAME$HWV_RELEASE_NAME$HWV_CUSTOM_VERSION
}

getVersionParam;

#modify external version
if [ -z "$VERSION" ];then
	#defind target build version
	echo -e "\033[49;36;1m"
	read -e -p "Enter The External Version:" -i "$HWV_BUILD_VERSION" BUILD_VERSION
	echo -e "\033[0m \c"

	VERSION=`echo $BUILD_VERSION|tr '[:lower:]' '[:upper:]'`

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

#modify internal version
if [ -z "$INTERNAL_VERSION" ];then
	#defind target build version
	echo -e "\033[49;36;1m"
	read -e -p "Enter The Internal Version:" -i "$HWV_BUILDINTERNAL_VERSION" INTERNAL_VERSION_T
	echo -e "\033[0m \c"

	INTERNAL_VERSION=`echo $INTERNAL_VERSION_T|tr '[:lower:]' '[:upper:]'`

	if [ -z "$INTERNAL_VERSION" ] ;then
	    INTERNAL_VERSION=$HWV_BUILDINTERNAL_VERSION
	fi

	if [ -n "$INTERNAL_VERSION" ] ;then
	    if [ $INTERNAL_VERSION != $HWV_BUILDINTERNAL_VERSION ] ;then   
	       sed -i "s/HWV_BUILDINTERNAL_VERSION \= $HWV_BUILDINTERNAL_VERSION/HWV_BUILDINTERNAL_VERSION \= $INTERNAL_VERSION/g" "$PROJECT_CONFIG_FILE"
               checkCommandExc;
	    fi
	fi
else
   if [ $INTERNAL_VERSION != $HWV_BUILDINTERNAL_VERSION ] ;then
      sed -i "s/HWV_BUILDINTERNAL_VERSION \= $HWV_BUILDINTERNAL_VERSION/HWV_BUILDINTERNAL_VERSION \= $INTERNAL_VERSION/g" "$PROJECT_CONFIG_FILE"
      checkCommandExc;
   fi
fi

function getLastVersion(){
	local T=`echo $VERSION|tr -cd '[0-9\n]'`
	local N=`expr $T \- 1`
	local S=`echo $N|awk '{printf "%03s\n" ,$0}'` #add '0' if length less than 3 at left
	local V_T=${VERSION/$T/$S}
	
	echo $V_T
}

function tipUserInputLastVersion(){
	if [ "$IS_MENU_SHOW"="T" ] && [ -z "$OTA_COMPARED_VERSION" ] && [ "$IS_MAKE_OTA_PACKAGE" = "T" ] && [ "$IS_ONLY_BUILD" = "F" ]; then
		local V_T=`getLastVersion`
		
		echo -e "\033[49;36;1m"
		read -e -p "Enter The Compared Version(For Us To Make Ota Different Package):" -i "$V_T" VSN
		echo -e "\033[0m \c"

		if [ -z "$VSN" ] ;then
		    tipUserInputLastVersion;
		else
		    OTA_COMPARED_VERSION=`echo $VSN|tr '[:lower:]' '[:upper:]'`
		fi
	fi
}
tipUserInputLastVersion;

SHORT_PROJECT_NAME=""

#get last version package name for make ota differnt split package
if [ -z "$OTA_COMPARED_VERSION_PACKAGE_NAME" ] && [ "$IS_MAKE_OTA_PACKAGE" = "T" ] && [ "$IS_ONLY_BUILD" = "F" ];then
	SHORT_PROJECT_NAME_T=${HWV_PROJECT_NAME#*-}
	SHORT_PROJECT_NAME=`echo $SHORT_PROJECT_NAME_T|tr '[:upper:]' '[:lower:]'`

	V_T=`getLastVersion|tr '[:upper:]' '[:lower:]'`

	echo -e "\033[49;36;1m"
	read -e -p "Enter The Compare Version's Package Name(For Us To Make Ota Different Package):" -i "${SHORT_PROJECT_NAME}_${V_T}"_"${TARGET_BUILD_VARIANT}.zip" NAME
	echo -e "\033[0m"

        if [ -z "$NAME" ] ;then
	    fShowMenu;
        else
            OTA_COMPARED_VERSION_PACKAGE_NAME=$NAME
	fi
fi

FOLDER_NAME=${FOLDER_NAME_PRE}${VERSION}"_"${TARGET_BUILD_VARIANT}

echo -e "Please confirm the build information:"
echo -e "\t Project Name:\033[49;31;5m "${PROJECT_NAME}"\033[0m "
echo -e "\t Target Build Version:\033[49;31;5m " ${TARGET_BUILD_VARIANT}"\033[0m "
echo -e "\t External Version:\033[49;31;5m "${VERSION}"\033[0m "
echo -e "\t Internal Version:\033[49;31;5m "${INTERNAL_VERSION}"\033[0m "
echo -e "\t The final package folder name:\033[49;31;5m "${FOLDER_NAME}"\033[0m "
echo -e "\t Is only make package:\033[49;31;5m "${IS_ONLY_MAKE_PACHAGE}"\033[0m "
echo -e "\t Last version package name:\033[49;31;5m "${OTA_COMPARED_VERSION_PACKAGE_NAME}"\033[0m "
echo -e "\t it's correctly(y/n): \c "

read confirm
if [ ! "$confirm" = 'y' ] ;then
  exit
fi

function cleanDust(){
        echo -e "`date '+%Y%m%d  %T'` Begin to clean last release version's dust......!"
	if [ -d "$CKT_HOME/out" ]; then 
		${CKT_HOME}/mk clean
        fi 
	
	rm -rf $CKT_HOME/out
	rm -rf $CKT_HOME/ckt/*.zip
        rm -rf $CKT_HOME/ckt/.bin
}

#build target version 
if [ "$IS_ONLY_MAKE_PACHAGE" = "n" ] ;then
	echo "+=========================================================================================+"
	echo "+=                    `date '+%Y%m%d  %T'` Call 'mk' to make version...                  =+"
	echo "+=========================================================================================+"

	#clear dust
	cleanDust;

	if [ "$TARGET_BUILD_VARIANT" = 'user' ] ;then
	   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME new
	   checkCommandExc;

	   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME otapackage
           checkCommandExc;
	elif [ "$TARGET_BUILD_VARIANT" = 'eng' ] ;then
	   ${CKT_HOME}/mk $PROJECT_NAME new
           checkCommandExc;

	   ${CKT_HOME}/mk $PROJECT_NAME otapackage
	   checkCommandExc;
	fi
fi

if [ "$IS_ONLY_BUILD" = "T" ]  && [ "$IS_MAKE_OTA_PACKAGE" = "T" ]; then
	echo "Build is completed, there has no more task to do, the tools will exit!"
        exit
fi

#make dir
echo "+=========================================================================================+"
echo "+=                  `date '+%Y%m%d  %T'` begin make version release folder...                       =+"
echo "+=========================================================================================+"

cd $FINAL_PACKAGE_SAVE_DIR
rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME

FTP_BACKUP_DIR=`echo ${VERSION}"_"${TARGET_BUILD_VARIANT}"_ftp_backup"|tr '[:upper:]' '[:lower:]'`
rm -rf $FTP_BACKUP_DIR
mkdir $FTP_BACKUP_DIR

cd $FOLDER_NAME
UPDATE_FOLDER=$FOLDER_NAME
mkdir $UPDATE_FOLDER

cd $UPDATE_FOLDER
mkdir sdcard_update
mkdir usb_update

#copy sdcard update
echo -e "`date '+%Y%m%d  %T'` copy sdcard update to folder..."
cd sdcard_update
cp -f $CKT_HOME/out/target/product/$PROJECT_NAME/$PROJECT_NAME-ota-*.zip ./update.zip
checkCommandExc;

#copy usb update
function makeUsbUpdate(){
	mkdir ${FOLDER_NAME}".bin"

	cd ${FOLDER_NAME}".bin"
	cp -rf $CKT_HOME_OUT_PROJECT/EBR1 ./
	cp -rf $CKT_HOME_OUT_PROJECT/boot.img ./
	cp -rf $CKT_HOME_OUT_PROJECT/recovery.img ./
	cp -rf $CKT_HOME_OUT_PROJECT/MT6572_Android_scatter.txt ./
	cp -rf $CKT_HOME_OUT_PROJECT/lk.bin ./
	cp -rf $CKT_HOME_OUT_PROJECT/preloader_ckt72_we_jb3.bin ./
	cp -rf $CKT_HOME_OUT_PROJECT/userdata.img ./
	cp -rf $CKT_HOME_OUT_PROJECT/secro.img ./
	cp -rf $CKT_HOME_OUT_PROJECT/MBR ./
	cp -rf $CKT_HOME_OUT_PROJECT/system.img ./
	cp -rf $CKT_HOME_OUT_PROJECT/cache.img ./
	cp -rf $CKT_HOME_OUT_PROJECT/logo.bin ./

	mkdir DATABASE
	cd DATABASE
	local CUSTOM_MODEM=`grep -w ^CUSTOM_MODEM $PROJECT_CONFIG_FILE|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	cp -f $CKT_HOME_MTK_MODEM/$CUSTOM_MODEM/BPLGUInfoCustomAppSrcP_* ./
        cp -f $CKT_HOME/mediatek/cgen/APDB_MT6572_S01_MAIN2.1_W10.24 ./

	cd ../../
}

echo -e "`date '+%Y%m%d  %T'` make usb update to folder..."
cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$UPDATE_FOLDER/usb_update
makeUsbUpdate;
checkCommandExc;

if [ "$IS_MAKE_OTA_PACKAGE" = "F" ]; then
	echo "Package is maked completed, there has no more task to do, the tools will exit!"
        exit
fi

#make ota different split package
echo "+=========================================================================================+"
echo "+=      `date '+%Y%m%d  %T'` begin to make ota different split package...                =+"
echo "+=========================================================================================+"

function getLastVersionPackage(){
	local FTP_ADDR_T=`sed -n '/^FTP_ADD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
        local FTP_ADDR=${FTP_ADDR_T#*=}

	local FTP_USER_NAME_T=`sed -n '/^FTP_USER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
        local FTP_USER_NAME=${FTP_USER_NAME_T#*=}

	local FTP_USER_PASSORD_T=`sed -n '/^FTP_USER_PASSORD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
        local FTP_USER_PASSORD=${FTP_USER_PASSORD_T#*=}
        
        local FTP_URL=$FTP_USER_NAME":"$FTP_USER_PASSORD"@"$FTP_ADDR

        local TEMP_FOLDER_NAME="Y320U_EMMC/HOAT中间文件/$HWV_PROJECT_NAME/${HWV_PROJECT_NAME}"_"${TARGET_BUILD_VARIANT}";

#lftp $FTP_URL<< EOF
	
	#cd $TEMP_FOLDER_NAME;
        #get $OTA_COMPARED_VERSION_PACKAGE_NAME;
        #bye;
	
#EOF
}

#getLastVersionPackage
cd $FINAL_PACKAGE_SAVE_DIR/

OTA_UPDATE_DIR=`echo ${VERSION}"_"${TARGET_BUILD_VARIANT}"_"${VENDOR}"_ota_update"|tr '[:upper:]' '[:lower:]'`
mkdir -p ./$FOLDER_NAME/$OTA_UPDATE_DIR

if [ -f "$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
	cp -f $OTA_COMPARED_VERSION_PACKAGE_NAME ./$FOLDER_NAME/$OTA_UPDATE_DIR
else
        cd $FOLDER_NAME/$OTA_UPDATE_DIR
	getLastVersionPackage;
	cd -
fi 

if [ ! -f "$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
	checkCommandExc;
fi 

#make update ota package naem
UPDATE_OTA_PACKAGE_NAME=""
UPDATE_OTA_PACKAGE_NAME_VALIDATE=""
PREVIOUS_VERSION=""
function makeUpdateOtaPackageName(){
	#make short project name
	local SHORT_PROJECT_NAME_T=${HWV_PROJECT_NAME#*-}
	SHORT_PROJECT_NAME=`echo $SHORT_PROJECT_NAME_T|tr '[:upper:]' '[:lower:]'`

	local V_N=`echo $VERSION|tr '[:upper:]' '[:lower:]'` 
        local V=""

        if [ "$OTA_COMPARED_VERSION" = "default" ] || [ "$OTA_COMPARED_VERSION" = "d" ] || [ "$OTA_COMPARED_VERSION" = "dflt" ]; then
		local T=`echo $VERSION|tr -cd '[0-9\n]'`
		local N=`expr $T \- 1`
		local S=`echo $N|awk '{printf "%03s\n" ,$0}'` #add '0' if length less than 3 at left
		local V_T=${VERSION/$T/$S}

		PREVIOUS_VERSION=${FOLDER_NAME_PRE}${V_T}
		V=`echo $V_T|tr '[:upper:]' '[:lower:]'`	
	else
		PREVIOUS_VERSION=${FOLDER_NAME_PRE}${OTA_COMPARED_VERSION}
		V=`echo $OTA_COMPARED_VERSION|tr '[:upper:]' '[:lower:]'`
	fi
        
        UPDATE_OTA_PACKAGE_NAME=${SHORT_PROJECT_NAME}_${V}"--"${V_N}"_"${TARGET_BUILD_VARIANT}".zip"
	UPDATE_OTA_PACKAGE_NAME_VALIDATE=${SHORT_PROJECT_NAME}"_"${V_N}"--"${V}"_"${TARGET_BUILD_VARIANT}".zip"
}

makeUpdateOtaPackageName;
OTA_DIFF_FILE=$FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$UPDATE_OTA_PACKAGE_NAME
OTA_DIFF_FILE_VALIDATE=$FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$UPDATE_OTA_PACKAGE_NAME_VALIDATE

cd $CKT_HOME

#buil true ota different split package
./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $OTA_DIFF_FILE
checkCommandExc;

echo "+=========================================================================================+"
echo "+=      `date '+%Y%m%d  %T'` begin to make validate ota different split package...       =+"
echo "+=========================================================================================+"
#buil validate ota different split package
./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i  $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME $OTA_DIFF_FILE_VALIDATE
checkCommandExc;

rm -f $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME

cd $FINAL_PACKAGE_SAVE_DIR

cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip  $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/${SHORT_PROJECT_NAME}"_"${VERSION}"_"${TARGET_BUILD_VARIANT}".zip"
checkCommandExc;

HUAWEI_OTA_PACKAGE_NAME=""
OTA_UPDATE_COMPONENT_NAME=""
FULL_DIR=""
OTA_CONFIG_DIR=""
UPDATE_PACKAGE_DIR=""
CHANAGE_LOG_FILE=""
FILE_LIST_FILE=""

function readVendorOtaConfig(){
    local HUAWEI_OTA_PACKAGE_NAME_T=`sed -n '/^HUAWEI_OTA_PACKAGE_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    HUAWEI_OTA_PACKAGE_NAME=${HUAWEI_OTA_PACKAGE_NAME_T#*=}

    local OTA_UPDATE_COMPONENT_NAME_T=`sed -n '/^OTA_UPDATE_COMPONENT_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    OTA_UPDATE_COMPONENT_NAME=${OTA_UPDATE_COMPONENT_NAME_T#*=}

    local FULL_DIR_T=`sed -n '/^OTA_UPDATE_FULL_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    FULL_DIR=${FULL_DIR_T#*=}

    local OTA_CONFIG_DIR_T=`sed -n '/^OTA_UPDATE_CONFIG_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    OTA_CONFIG_DIR=${OTA_CONFIG_DIR_T#*=}

 local UPDATE_PACKAGE_DIR_T=`sed -n '/^OTA_UPDATE_PACKAGE_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    UPDATE_PACKAGE_DIR=${UPDATE_PACKAGE_DIR_T#*=}

    local CHANAGE_LOG_FILE_T=`sed -n '/^OTA_UPDATE_CHANAGE_LOG_FILE/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    CHANAGE_LOG_FILE=${CHANAGE_LOG_FILE_T#*=}

    local FILE_LIST_FILE_T=`sed -n '/^OTA_UPDATE_FILE_LIST_FILE/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    FILE_LIST_FILE=${FILE_LIST_FILE_T#*=}
}

#  add for make vendor ota file
function makeVendorOtaFile() {
    cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR

    local VSN=""
    local FTS=""
    local SPTH=""
    local DPTH=""
    local ODFL=""
    local U_ZIP_NAME=""

    if [ "$1" = "T" ]; then
        VSN="$FOLDER_NAME_PRE$VERSION"
        FTS="$PREVIOUS_VERSION to ${FOLDER_NAME_PRE}${VERSION}"
        SPTH="$HUAWEI_OTA_PACKAGE_NAME"
        DPTH="$HUAWEI_OTA_PACKAGE_NAME"
        ODFL="$OTA_DIFF_FILE"
        U_ZIP_NAME=${PREVIOUS_VERSION}"_"${TARGET_BUILD_VARIANT}"--"${FOLDER_NAME}"-updatepackage.zip"
    else
        VSN="$PREVIOUS_VERSION"
        FTS="${FOLDER_NAME_PRE}${VERSION} to $PREVIOUS_VERSION"
        SPTH="$HUAWEI_OTA_PACKAGE_NAME"
        DPTH="$HUAWEI_OTA_PACKAGE_NAME"
        ODFL="$OTA_DIFF_FILE_VALIDATE"
        U_ZIP_NAME=${FOLDER_NAME}"--"${PREVIOUS_VERSION}"_"${TARGET_BUILD_VARIANT}"-updatepackage.zip"
    fi

    cp -f $ODFL $HUAWEI_OTA_PACKAGE_NAME

    cp -rf $VERSION_RELEASE_SHELL_FOLDER/data/${VENDOR}"_ota"/$UPDATE_PACKAGE_DIR/$OTA_CONFIG_DIR ./
    checkCommandExc;
    
    rm -rf $FULL_DIR
    mkdir $FULL_DIR

    cd $OTA_CONFIG_DIR
    local VERSION_CONTENT="<component name=\"$OTA_UPDATE_COMPONENT_NAME\" version=\"${VSN}\"\/\>"
    local VERSION_CONTENT="<component name=\"TCPU\" version=\"${VSN}\"\/\>"
    local FEATURE_CONTENT="\<feature\>${FTS}\<\/feature\>"
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

    local SAPTH="\<spath\>$SPTH\<\/spath\>"
    local DPATH="\<dpath\>$DPTH\<\/dpath\>"
    sed -i "16s/.*/$SAPTH/g" "$FILE_LIST_FILE"
    checkCommandExc;

    sed -i "17s/.*/$DPATH/g" "$FILE_LIST_FILE"
    checkCommandExc;

    local OTA_DIFF_MD5_CONTENT="\<md5\>`md5sum $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$HUAWEI_OTA_PACKAGE_NAME | cut -d' ' -f1|tr '[:lower:]' '[:upper:]'`\<\/md5\>"
    local OTA_DIFF_FILE_SIZE_CONTENT="\<size\>`ls -la $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$HUAWEI_OTA_PACKAGE_NAME | cut -d' ' -f5`\<\/size\>"
    sed -i "19s/.*/$OTA_DIFF_MD5_CONTENT/g" "$FILE_LIST_FILE"
    checkCommandExc;

    sed -i "20s/.*/$OTA_DIFF_FILE_SIZE_CONTENT/g" "$FILE_LIST_FILE"
    checkCommandExc;

    cd -

    # copy xml file and ota file to  dir
    echo "copying $CHANAGE_LOG_FILE $FILE_LIST_FILE and $HUAWEI_OTA_PACKAGE_NAME to $FULL_DIR"
    cp $OTA_CONFIG_DIR/$CHANAGE_LOG_FILE $FULL_DIR/
    checkCommandExc;

    cp $OTA_CONFIG_DIR/$FILE_LIST_FILE $FULL_DIR/
    checkCommandExc;

    cp -f $HUAWEI_OTA_PACKAGE_NAME $FULL_DIR/
    checkCommandExc;

    rm -f $HUAWEI_OTA_PACKAGE_NAME

    mv -f $ODFL $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/
    checkCommandExc;

    rm -rf $OTA_CONFIG_DIR

    # package the ota file
    echo "packaging the ota file..."
    zip -rm $U_ZIP_NAME $FULL_DIR/
    echo "package finished!"
    
    cd -
}

if [ "$IS_MAKE_HUAWEI_OTA_PACKAGE" = "F" ]; then
	echo "Ota different split package is maked completed, there has no more task to do, the tools will exit!"
        exit
fi

#make vendor ota file
echo "+=========================================================================================+"
echo "+=      `date '+%Y%m%d  %T'` begin to make vendor ota file...                            =+"
echo "+=========================================================================================+"

readVendorOtaConfig;

makeVendorOtaFile "T";

echo "+=========================================================================================+"
echo "+=      `date '+%Y%m%d  %T'` begin to make validate vendor ota file...                   =+"
echo "+=========================================================================================+"

makeVendorOtaFile "F";

cd $FINAL_PACKAGE_SAVE_DIR
ls -lt
echo -e "`date '+%Y%m%d  %T'` \033[49;31;5m The final package save dir is: `pwd` \033[0m DOWN" 
