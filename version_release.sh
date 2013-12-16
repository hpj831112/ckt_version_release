#!/bin/bash                         

##defind vars

#project name
PROJECT_NAME="ckt72_we_jb3"

#target buil variant
TARGET_BUILD_VARIANT="user"

#version
VERSION=""

#folder name's version
FINAL_VERSION=""

#interior version
INTERNAL_VERSION=""

#demain is only build
IS_ONLY_BUILD="F"

#demain is do local backup
IS_LOCAL_BACKUP="F"

#the last version which user want to compare
OTA_COMPARED_VERSION=""

#only make package
IS_ONLY_MAKE_PACHAGE="n"

#last version package name
OTA_COMPARED_VERSION_PACKAGE_NAME=""

#demain is external version locked
IS_EXTERNAL_VERSION_LOCAKED="F"

IS_MAKE_FILE="T"

IS_FIRST_RELEASE="F"

#user introduction
USAGE="Usage: $0 [-p project] [-t target_build_variant] [-v version] [-i internal_version] [-m only_build] [-z n or y] [-n only_make_package] [-o ota_compares_version_package_name] [-l ota_compared_version] [-x supper_packaged_option] [-w not_make_vendor_ota_package] [-R change_dir_name_to_chinese] [-I final_folder_name's_version_based_on_internal_versuon] [-B open_ftp_backup_function] [-E make_eng_bootimg] [-L local_backup] [-K is_external_version_locked] [-X not_call_mk] [-F first_release] [-? show_this_message]"

#option count
OPTION_COUNT=$#

#record if the menu is showed
IS_MENU_SHOW="T"

#demaid the copyright is showing
IS_SHOW_COPYRIGHT="T"

#demain is make the ota package
IS_MAKE_HOTA_PACKAGE="T"

#demain is make the huawei ota package
IS_MAKE_HUAWEI_OTA_PACKAGE="T"

#demain need change dir name for chinese
NEED_CHANGE_DIR_NAME="F"

#log info
LOG=""

#demain the final folder's name's version is based on internal version
IS_FOLDER_NAME_BASED_ON_INTERNAL_VERSION="F"

#demain if need us to help user send ftp backup file to FTP service
IS_SEND_BACKUP_FILE_TO_SERVICE="F"

#demain if need us to help user make eng boot img
IS_MAKE_ENG_BOOT_IMG="F"

#demain if dill with base version specialLy
IS_BASE_VERSION_SPECIALLY="T"

#demain every configration is keep the default
IS_KEEP_DEFAULT_CONFIG="F"

#demain if need to make otaupdate package
IS_MAKE_OTAUPDATE="T"

function getConfigFile(){
	cd /sbin
	local VERSION_RELEASE_HOME_T=`readlink ckt_release`
	VERSION_RELEASE_SHELL_FOLDER=${VERSION_RELEASE_HOME_T%*/*}
	VERSION_RELEASE_CONFIG_FILE="$VERSION_RELEASE_SHELL_FOLDER/config.conf"
	cd -
}
getConfigFile

function checkCommandExc(){
	if [ $? -ne 0 ];then
		echo -e "\033[49;31;5m There has some errors during the command executing, please check it! The program will exit! \033[0m EXIT"
        exit 1
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
       fShowMenu
    fi
}

function showHelpInfo(){
    more $VERSION_RELEASE_SHELL_FOLDER/help.txt
}

function showReadme(){
    more $VERSION_RELEASE_SHELL_FOLDER/README.md
}

#read user input options
while getopts ":p:t:v:i:z:o:l:hmnwxRIBSEKPXDFO" opt; do
	case $opt in
	    p ) PROJECT_NAME=$OPTARG 
	        ;;
	    t ) TARGET_BUILD_VARIANT=`echo $OPTARG|tr '[:upper:]' '[:lower:]'`
	        ;;
	    v ) VERSION=`echo $OPTARG|tr '[:lower:]' '[:upper:]'` 
	        ;;
	    i ) INTERNAL_VERSION=`echo $OPTARG|tr '[:lower:]' '[:upper:]'` 
	        ;;
	   \m ) IS_ONLY_BUILD="T" 
	        ;;
	    z ) IS_ONLY_MAKE_PACHAGE=`echo $OPTARG|tr '[:upper:]' '[:lower:]'`
	        ;;
	    o ) OTA_COMPARED_VERSION_PACKAGE_NAME=$OPTARG 
	        ;;
	    l ) OTA_COMPARED_VERSION=`echo $OPTARG|tr '[:lower:]' '[:upper:]'`  
	        ;;
	   \n ) IS_MAKE_HOTA_PACKAGE="F" 
	        ;;
	   \w ) IS_MAKE_HUAWEI_OTA_PACKAGE="F"
	        ;;
	   \x ) IS_ONLY_MAKE_PACHAGE="y"
	        ;;
	   \I ) IS_FOLDER_NAME_BASED_ON_INTERNAL_VERSION="T"
			;;
	   \R ) NEED_CHANGE_DIR_NAME="T"
	        ;;
	   \B ) IS_SEND_BACKUP_FILE_TO_SERVICE="T"
			;;
	   \P ) IS_BASE_VERSION_SPECIALLY="F"
			;;
	   \E ) IS_MAKE_ENG_BOOT_IMG="T"
			;;
	   \L ) IS_LOCAL_BACKUP="T"
			;;
	   \K ) IS_EXTERNAL_VERSION_LOCAKED="T"
			;;
	   \X ) IS_MAKE_FILE="F"
	        IS_MAKE_HOTA_PACKAGE="F" 
			;;
	   \O ) IS_MAKE_OTAUPDATE="F" 
			IS_ONLY_BUILD="T"
            IS_MAKE_HOTA_PACKAGE="F" 
			;;
	   \D ) IS_KEEP_DEFAULT_CONFIG="T"
			;;
	   \F ) IS_FIRST_RELEASE="T"
			;;
	   \? ) echo $USAGE 
			IS_SHOW_COPYRIGHT="F"
	        exit 1 
	        ;;
	   \h ) showHelpInfo
			IS_SHOW_COPYRIGHT="F"
	        exit 1 
	        ;;
	   \S ) showReadme
			IS_SHOW_COPYRIGHT="F"
	        exit 1 
	        ;;
	esac
done

function makeFixedLengStr(){
	local STR=`echo $1|sed -r ":1;s/$/$3/;/.{$2}/!b1"`
	echo $STR
}

function log4line(){
	local DT=`date '+%Y%m%d  %T'`
	LOG=`echo $DT $1|awk '{printf "%-83 s\n" ,$0}'`
}

function log4model(){
	local TEMP_STR=`makeFixedLengStr "=" 89 "="`
	echo "+$TEMP_STR+"
	echo "+=  $LOG  =+" 
	echo "+$TEMP_STR+"
}

function showCopyright(){
	if [ "T" = "$IS_SHOW_COPYRIGHT" ]; then
		echo "*******************************************************************************************"
		echo "*                                                                                         *"
		echo "*                                  CKT VERSION RELEAS                                     *"
		echo "*                                  VERSION beta-v1.0.1                                    *"
		echo "*                           AUTROR HePeijiang ZhaoDan YaoZhilin                           *"
		echo "*                (c) Copyright ckt version release 2013.  All rights reserved.            *"
		echo "*                                                                                         *"
		echo "*******************************************************************************************"
	fi
} 
showCopyright

if [ $OPTION_COUNT -eq 0 ] || [ "$1" = "-x" ]  || [ "$1" = "-l" ] || [ "$1" = "-m" ] || [ "$1" = "-n" ] || [ "$1" = "-w" ] || [ "$1" = "-R" ] || [ "$1" = "-I" ] || [ "$1" = "-B" ] || [ "$1" = "-E" ] || [ "$1" = "-X" ] || [ "$1" = "-D" ] || [ "$1" = "-F" ] || [ "$1" = "-O" ]; then
   fShowMenu
   IS_MENU_SHOW="T"
fi

##defind global vars

# project dir
CKT_HOME=`pwd`

# out dir of the project
CKT_HOME_OUT_PROJECT=${CKT_HOME}"/out/target/product/$PROJECT_NAME"

# model dir of the project
CKT_HOME_MTK_MODEM=${CKT_HOME}"/mediatek/custom/common/modem"

# config file of the project
PROJECT_CONFIG_FILE="$CKT_HOME/mediatek/config/$PROJECT_NAME/ProjectConfig.mk"

# build file of the project
BUILD_PROP_FILE=${CKT_HOME}"/out/target/product/$PROJECT_NAME/system/build.prop"

# the name of the final folder except version
FOLDER_NAME_PRE=""

#short name of project,like U10
SHORT_PROJECT_NAME=""

#make ota different split package saved dir
function makeSaveDirAndGetVendor(){
	local FINAL_PACKAGE_SAVE_DIR_T=`sed -n '/^FINAL_PACKAGE_SAVE_DIR/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
	checkCommandExc

	FINAL_PACKAGE_SAVE_DIR=${FINAL_PACKAGE_SAVE_DIR_T#*=}
	if [ ! -d "$FINAL_PACKAGE_SAVE_DIR" ]; then
        echo -e "\033[49;34;5m $FINAL_PACKAGE_SAVE_DIR \033[0m \033[49;31;5m is not exist, the tool will help you make it, please remenber it!"	
        echo -e " Then, if the dir name on FTP sever is not regulatory, please copy the HOTA package to the root of this dir! \033[0m "			
		mkdir -p "$FINAL_PACKAGE_SAVE_DIR"
	fi 

	local VENDOR_T=`sed -n '/^VENDOR/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
	VENDOR=${VENDOR_T#*=}

	BASE_CUSTOM_COD=`sed -n '/^BASE_CUSTOM_COD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
}
makeSaveDirAndGetVendor

# get default options
function getDefaultOption(){
	ARRY_DEFAUIT_OPTIONS_T=`sed -n '/^ARRY_DEFAUIT_OPTIONS/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'`

	eval "$ARRY_DEFAUIT_OPTIONS_T"

	for i in "${ARRY_DEFAUIT_OPTIONS[@]}"; do 
		 case $i in
		    w ) IS_MAKE_HUAWEI_OTA_PACKAGE="F"
		        ;;
		    I ) IS_FOLDER_NAME_BASED_ON_INTERNAL_VERSION="T"
				;;
		    R ) NEED_CHANGE_DIR_NAME="T"
		        ;;
		    B ) IS_SEND_BACKUP_FILE_TO_SERVICE="T"
			    ;;
			P ) IS_BASE_VERSION_SPECIALLY="F"
			    ;;
			E ) IS_MAKE_ENG_BOOT_IMG="T"
				;;
			L ) IS_LOCAL_BACKUP="T"
				;;
			K ) IS_EXTERNAL_VERSION_LOCAKED="T"
				;;
			X ) IS_MAKE_FILE="F"
			    IS_MAKE_HOTA_PACKAGE="F" 
				;;
			D ) IS_KEEP_DEFAULT_CONFIG="T"
				;;
		 esac
	done 
	checkCommandExc
}
getDefaultOption

#get version param
HWV_BUILD_VERSION=""
HWV_BUILDINTERNAL_VERSION=""
HWV_PROJECT_NAME=""
HWV_CUSTOM_VERSION=""

function getVersionParam(){
	#read version control
	local HWV_PROJECT_NAME_T=`sed -n '/^HWV_PROJECT_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
    checkCommandExc

	local HWV_VERSION_NAME_T=`sed -n '/^HWV_VERSION_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    checkCommandExc

	local HWV_RELEASE_NAME_T=`sed -n '/^HWV_RELEASE_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    checkCommandExc

	local HWV_CUSTOM_VERSION_T=`sed -n '/^HWV_CUSTOM_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    checkCommandExc

	local HWV_BUILDINTERNAL_VERSION_T=`sed -n '/^HWV_BUILDINTERNAL_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    checkCommandExc

	local HWV_BUILD_VERSION_T=`sed -n '/^HWV_BUILD_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    checkCommandExc


	HWV_PROJECT_NAME=${HWV_PROJECT_NAME_T#*=}
	local HWV_VERSION_NAME=${HWV_VERSION_NAME_T#*=}
	local HWV_RELEASE_NAME=${HWV_RELEASE_NAME_T#*=}
	HWV_CUSTOM_VERSION=${HWV_CUSTOM_VERSION_T#*=}
	HWV_BUILD_VERSION=${HWV_BUILD_VERSION_T#*=}
    HWV_BUILDINTERNAL_VERSION=${HWV_BUILDINTERNAL_VERSION_T#*=}

	if [ "$IS_ONLY_MAKE_PACHAGE" = "y" ] ||  [ "T" = "$IS_KEEP_DEFAULT_CONFIG" ];then
		VERSION=$HWV_BUILD_VERSION
		INTERNAL_VERSION=$HWV_BUILDINTERNAL_VERSION
	fi

    FOLDER_NAME_PRE=$HWV_PROJECT_NAME$HWV_VERSION_NAME$HWV_RELEASE_NAME$HWV_CUSTOM_VERSION
}
getVersionParam

function makeVersion(){
	#get external version
	if [ -z "$VERSION" ]; then
		VERSION=$HWV_BUILD_VERSION

		if [ "F" = "$IS_EXTERNAL_VERSION_LOCAKED" ];then
			#defind target build version
			echo -e "\033[49;36;1m"
			read -e -p "Enter The External Version:" -i "$HWV_BUILD_VERSION" BUILD_VERSION
			echo -e "\033[0m \c"

			VERSION=`echo $BUILD_VERSION|tr '[:lower:]' '[:upper:]'`

			if [ -z "$BUILD_VERSION" ] ;then
				VERSION=$HWV_BUILD_VERSION
			fi
		fi
	fi

	#get internal version
	if [ -z "$INTERNAL_VERSION" ];then
		#defind target build version
		echo -e "\033[49;36;1m"
		read -e -p "Enter The Internal Version:" -i "$HWV_BUILDINTERNAL_VERSION" INTERNAL_VERSION_T
		echo -e "\033[0m \c"

		INTERNAL_VERSION=`echo $INTERNAL_VERSION_T|tr '[:lower:]' '[:upper:]'`

		if [ -z "$INTERNAL_VERSION" ] ;then
			INTERNAL_VERSION=$HWV_BUILDINTERNAL_VERSION
		fi
	fi

	#if [ "T" = "$IS_FOLDER_NAME_BASED_ON_INTERNAL_VERSION" ];then
		FINAL_VERSION=$INTERNAL_VERSION
	#else
		#FINAL_VERSION=$VERSION
	#fi
}

if [ "F" = "$IS_KEEP_DEFAULT_CONFIG" ];then
    if [ "T" = "$IS_MAKE_FILE" ]; then
	    makeVersion
	else
	    VERSION=$HWV_BUILD_VERSION
		INTERNAL_VERSION=$HWV_BUILDINTERNAL_VERSION
		FINAL_VERSION=$INTERNAL_VERSION
	fi
else
	#if [ "T" = "$IS_FOLDER_NAME_BASED_ON_INTERNAL_VERSION" ];then
		VERSION=$HWV_BUILD_VERSION
		INTERNAL_VERSION=$HWV_BUILDINTERNAL_VERSION
		FINAL_VERSION=$INTERNAL_VERSION
	#else
		#FINAL_VERSION=$VERSION
	#fi
fi

function getLastVersion(){
	local OCV=`echo $OTA_COMPARED_VERSION|tr '[:upper:]' '[:lower:]'`
	if [ -z "$OCV" ] || [ "$OCV" = "default" ] || [ "$OCV" = "d" ] || [ "$OCV" = "dflt" ]; then
		local T=`echo $FINAL_VERSION|tr -cd '[0-9\n]'`
		local N=`expr $T \- 1`

		# if is custom the default version maybe 100 less than current version
		if [ "T" = "$IS_FOLDER_NAME_BASED_ON_INTERNAL_VERSION" ]; then
			N=`expr $T \- 100`
		fi

		local S=`echo $N|awk '{printf "%03s\n" ,$0}'` #add '0' if length less than 3 at left
		local V_T=${FINAL_VERSION/$T/$S}
	
		echo $V_T
	else
		echo $OTA_COMPARED_VERSION
	fi
}

function tipUserInputLastVersion(){
	if [ "$IS_MENU_SHOW"="T" ] && [ -z "$OTA_COMPARED_VERSION" ] && [ "$IS_MAKE_HOTA_PACKAGE" = "T" ] && [ "$IS_ONLY_BUILD" = "F" ]; then
		local V_T=`getLastVersion`
		
		echo -e "\033[49;36;1m"
		read -e -p "Enter The Compared Version(For Us To Make Ota Different Package):" -i "$V_T" VSN
		echo -e "\033[0m \c"

		if [ -z "$VSN" ] ;then
		    tipUserInputLastVersion
		else
		    OTA_COMPARED_VERSION=`echo $VSN|tr '[:lower:]' '[:upper:]'`
		fi
	else
		local OCV=`echo $OTA_COMPARED_VERSION|tr '[:upper:]' '[:lower:]'`
        if [ "$OCV" = "default" ] || [ "$OCV" = "d" ] || [ "$OCV" = "dflt" ]; then
			OTA_COMPARED_VERSION=`getLastVersion`
		fi
	fi
}

if [ "F" = "$IS_KEEP_DEFAULT_CONFIG" ];then
    if [ "T" = "$IS_MAKE_FILE" ] && [ "F" = "$IS_FIRST_RELEASE" ] && [ "$IS_MAKE_HOTA_PACKAGE" = "T" ]; then
		tipUserInputLastVersion
	fi
else
	OTA_COMPARED_VERSION=`getLastVersion`
fi

function makeDeafaultComparedVersion(){
	if [ -z "$OTA_COMPARED_VERSION_PACKAGE_NAME" ] && [ "$IS_MAKE_HOTA_PACKAGE" = "T" ] && [ "$IS_ONLY_BUILD" = "F" ];then
		local SHORT_PROJECT_NAME_T=${HWV_PROJECT_NAME#*-}
		SHORT_PROJECT_NAME=`echo $SHORT_PROJECT_NAME_T|tr '[:upper:]' '[:lower:]'`
		local HW_CST_VSN=`echo $HWV_CUSTOM_VERSION|tr '[:upper:]' '[:lower:]'` 

		local V_T=`getLastVersion|tr '[:upper:]' '[:lower:]'`

		local CMPR_VSN_NM="${SHORT_PROJECT_NAME}_${V_T}"_"${TARGET_BUILD_VARIANT}.zip"

		if [ "T" = "$IS_BASE_VERSION_SPECIALLY" ] && [ ! "$HWV_CUSTOM_VERSION" = "$BASE_CUSTOM_COD" ]; then
		   CMPR_VSN_NM="${SHORT_PROJECT_NAME}_${HW_CST_VSN}_${V_T}"_"${TARGET_BUILD_VARIANT}.zip"
	    fi

		echo $CMPR_VSN_NM
	fi
}

function tipsUserInputComparedVersion(){
	CMPR_VSN_NM=`makeDeafaultComparedVersion`

	local TIPS_MSG="Enter The Package Name of The Compare Version(For Us To Make Ota Different Package):"

	echo -e "\033[49;36;1m"
	read -e -p "$TIPS_MSG" -i "$CMPR_VSN_NM" NAME
	echo -e "\033[0m"

	if [ -z "$NAME" ] ;then
		fShowMenu
	else
	    OTA_COMPARED_VERSION_PACKAGE_NAME=$NAME
	fi

	FOLDER_NAME=${FOLDER_NAME_PRE}${FINAL_VERSION}"_"${TARGET_BUILD_VARIANT}
}

#get last version package name for make ota differnt split package
if [ "F" = "$IS_KEEP_DEFAULT_CONFIG" ];then
    if [ "T" = "$IS_MAKE_FILE" ] && [ "F" = "$IS_FIRST_RELEASE" ] && [ "$IS_MAKE_HOTA_PACKAGE" = "T" ]; then
	    tipsUserInputComparedVersion  
    else
        FOLDER_NAME=${FOLDER_NAME_PRE}${FINAL_VERSION}"_"${TARGET_BUILD_VARIANT}
	fi
else
	OTA_COMPARED_VERSION_PACKAGE_NAME=`makeDeafaultComparedVersion`
    FOLDER_NAME=${FOLDER_NAME_PRE}${FINAL_VERSION}"_"${TARGET_BUILD_VARIANT}
fi

function doConfirm(){
	echo -e "Please confirm the build information:"
	echo -e "\t Project Name:\033[49;31;5m "${PROJECT_NAME}"\033[0m "
	echo -e "\t Target Build Version:\033[49;31;5m " ${TARGET_BUILD_VARIANT}"\033[0m "
	echo -e "\t External Version:\033[49;31;5m "${VERSION}"\033[0m "
	echo -e "\t Internal Version:\033[49;31;5m "${INTERNAL_VERSION}"\033[0m "
	echo -e "\t The final package folder name:\033[49;31;5m "${FOLDER_NAME}"\033[0m "
	echo -e "\t Is only make package:\033[49;31;5m "${IS_ONLY_MAKE_PACHAGE}"\033[0m "
	
	if [ "F" = "$IS_FIRST_RELEASE" ] || [ "$IS_MAKE_HOTA_PACKAGE" = "F" ]; then
		echo -e "\t Compared version:\033[49;31;5m "${OTA_COMPARED_VERSION}"\033[0m "
		echo -e "\t Last version package name:\033[49;31;5m "${OTA_COMPARED_VERSION_PACKAGE_NAME}"\033[0m "
	fi
	
    read -e -p "it's correctly[y/n]:" -i "y" confirm
	CFM=`echo $confirm |tr '[:upper:]' '[:lower:]'`

	if [ ! "$CFM" = 'y' ] ;then
		exit
	else
		if [ $VERSION != $HWV_BUILD_VERSION ] ;then   
		sed -i "s/HWV_BUILD_VERSION \= $HWV_BUILD_VERSION/HWV_BUILD_VERSION \= $VERSION/g" "$PROJECT_CONFIG_FILE"
		checkCommandExc
		fi

		if [ $INTERNAL_VERSION != $HWV_BUILDINTERNAL_VERSION ] ;then   
		sed -i "s/HWV_BUILDINTERNAL_VERSION \= $HWV_BUILDINTERNAL_VERSION/HWV_BUILDINTERNAL_VERSION \= $INTERNAL_VERSION/g" "$PROJECT_CONFIG_FILE"
		checkCommandExc
		fi
	fi
}
doConfirm

function cleanDust(){
   echo -e "`date '+%Y%m%d  %T'` Begin to clean last release version's dust......!"
	if [ -d "$CKT_HOME/out" ]; then 
		${CKT_HOME}/mk c
   	fi 
	
	rm -rf $CKT_HOME/out
	rm -rf $CKT_HOME/ckt/*.zip
    rm -rf $CKT_HOME/ckt/.bin
}

function doMakeAction(){
	if [ "$IS_ONLY_MAKE_PACHAGE" = "n" ] ;then
		log4line "Call 'mk' to make version..."
		log4model

		#clear dust
		cleanDust

		if [ "$TARGET_BUILD_VARIANT" = 'user' ] ;then
		    ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME new
		    checkCommandExc

		    if [ "T" = "$IS_MAKE_OTAUPDATE" ]; then
		   		${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME otapackage
		    	checkCommandExc
			fi
		elif [ "$TARGET_BUILD_VARIANT" = 'eng' ] ;then
		    ${CKT_HOME}/mk $PROJECT_NAME new
		    checkCommandExc

            if [ "T" = "$IS_MAKE_OTAUPDATE" ]; then
		    	${CKT_HOME}/mk $PROJECT_NAME otapackage
		    	checkCommandExc
            fi
		fi
	fi

	if [ "$IS_ONLY_BUILD" = "T" ]  && [ "$IS_MAKE_HOTA_PACKAGE" = "T" ]; then
	   echo "Build is completed, there has no more task to do, the tools will exit!"
	   exit
	fi
}

#build target version 
if [ "$IS_MAKE_FILE" = "T" ]; then
	doMakeAction
fi

DOCUMENT_FOLDER_NAME=""
SDCARD_UPDATE=""
USB_UPDATE=""
ENG_BOOT_IMG=""
DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME=""
README_FILE_NAME=""
function getFolderParam(){
	DOCUMENT_FOLDER_NAME=`sed -n '/^DOCUMENT_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	checkCommandExc
	
    if [ "F" = "$IS_FIRST_RELEASE" ]; then
		OTA_UPDATE_DIR=`sed -n '/^MIDDLE_HOTA_UPDATE_SOFTWARE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
		checkCommandExc
	fi

	SDCARD_UPDATE=`sed -n '/^SD_CARD_SOFTWARE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	checkCommandExc

	USB_UPDATE=`sed -n '/^USB_SOFTWARE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	checkCommandExc

	ENG_BOOT_IMG=`sed -n '/^ENG_BOOT_IMAGE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	checkCommandExc

	DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME=`sed -n '/^DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	checkCommandExc

	README_FILE_NAME=`sed -n '/^README/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	checkCommandExc
}

function makeFinalDir(){
	local TEMP_STR=`makeFixedLengStr "-" 90 "-"`
	echo "$TEMP_STR"
	echo "`date '+%Y%m%d  %T'` begin make version release folder..."

	cd $FINAL_PACKAGE_SAVE_DIR
	rm -rf $FOLDER_NAME
	mkdir $FOLDER_NAME

	FTP_BACKUP_DIR=`echo ${FINAL_VERSION}"_"${TARGET_BUILD_VARIANT}"_ftp_backup"|tr '[:upper:]' '[:lower:]'`
	rm -rf $FTP_BACKUP_DIR
	mkdir $FTP_BACKUP_DIR

	cd $FOLDER_NAME
	getFolderParam
	if [ "F" = "$IS_FIRST_RELEASE" ]; then
		mkdir $OTA_UPDATE_DIR
	fi
	mkdir $SDCARD_UPDATE
	mkdir $USB_UPDATE

	if [ "T" = "$IS_MAKE_ENG_BOOT_IMG" ] && [ "$TARGET_BUILD_VARIANT" = 'user' ]; then
		mkdir $ENG_BOOT_IMG
	fi
}

#make dir
makeFinalDir

function makeSdcardUpdate(){
	echo -e "`date '+%Y%m%d  %T'` copy sdcard update to folder..."
	cd $SDCARD_UPDATE
	cp -f $CKT_HOME/out/target/product/$PROJECT_NAME/$PROJECT_NAME-ota-*.zip ./update.zip
	checkCommandExc
}

#copy sdcard update
if [ "$IS_MAKE_FILE" = "T" ] && [ "T" = "$IS_MAKE_OTAUPDATE" ]; then
	makeSdcardUpdate
fi

#copy usb update
function makeUsbUpdate(){
	echo -e "`date '+%Y%m%d  %T'` make usb update to folder..."
	cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$USB_UPDATE

	mkdir ${FOLDER_NAME}".bin"

	cd ${FOLDER_NAME}".bin"
	cp -rf $CKT_HOME_OUT_PROJECT/EBR1 ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/boot.img ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/recovery.img ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/MT6572_Android_scatter.txt ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/lk.bin ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/preloader_ckt72_we_jb3.bin ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/userdata.img ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/secro.img ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/MBR ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/system.img ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/cache.img ./
	checkCommandExc

	cp -rf $CKT_HOME_OUT_PROJECT/logo.bin ./
	checkCommandExc

	mkdir DATABASE

	cd DATABASE

	local CUSTOM_MODEM=`grep -w ^CUSTOM_MODEM $PROJECT_CONFIG_FILE|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
	checkCommandExc

	cp -f $CKT_HOME_MTK_MODEM/$CUSTOM_MODEM/BPLGUInfoCustomAppSrcP_* ./
	checkCommandExc

   	cp -f $CKT_HOME/mediatek/cgen/APDB_MT6572_S01_MAIN2.1_W10.24 ./
	checkCommandExc

	cd ../../
	
	if [ "$IS_MAKE_HOTA_PACKAGE" = "F" ]; then
	   echo "Package is maked completed, there has no more task to do, the tools will exit!"
	   exit 1
	fi
}

makeUsbUpdate

function getFtpParam(){
   local FTP_ADDR_T=`sed -n '/^FTP_ADD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
   FTP_ADDR=${FTP_ADDR_T#*=}

   local FTP_USER_NAME_T=`sed -n '/^FTP_USER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
   FTP_USER_NAME=${FTP_USER_NAME_T#*=}

   local FTP_USER_PASSORD_T=`sed -n '/^FTP_USER_PASSORD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
   FTP_USER_PASSORD=${FTP_USER_PASSORD_T#*=}
        
   FTP_URL=$FTP_USER_NAME":"$FTP_USER_PASSORD"@"$FTP_ADDR

   ##local ftp
   local LOCAL_FTP_ADDR_T=`sed -n '/^LOCAL_FTP_ADD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
   LOCAL_FTP_ADDR=${LOCAL_FTP_ADDR_T#*=}

   local LOCAL_FTP_USER_NAME_T=`sed -n '/^LOCAL_FTP_USER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
   LOCAL_FTP_USER_NAME=${LOCAL_FTP_USER_NAME_T#*=}

   local LOCAL_FTP_USER_PASSORD_T=`sed -n '/^LOCAL_FTP_USER_PASSORD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
   LOCAL_FTP_USER_PASSORD=${LOCAL_FTP_USER_PASSORD_T#*=}
        
   LOCAL_FTP_URL=$LOCAL_FTP_USER_NAME":"$LOCAL_FTP_USER_PASSORD"@"$LOCAL_FTP_ADDR
   #LOCAL_FTP_URL=$LOCAL_FTP_ADDR

   FTP_FOLDER_NAME=""

   if [ "T" = "$IS_BASE_VERSION_SPECIALLY" ] && [ "$HWV_CUSTOM_VERSION" = "$BASE_CUSTOM_COD" ]; then
       FTP_FOLDER_NAME="$HWV_PROJECT_NAME/${HWV_PROJECT_NAME}"_"${TARGET_BUILD_VARIANT}"
   else
       FTP_FOLDER_NAME="${HWV_PROJECT_NAME}_${HWV_CUSTOM_VERSION}/${HWV_PROJECT_NAME}_${HWV_CUSTOM_VERSION}"_"${TARGET_BUILD_VARIANT}"
   fi
}
getFtpParam

function getLastVersionPackageFromFtp(){
#do not change the EOF code's position for it must be coded lisk this!
lftp $FTP_URL<< EOF
	set ftp:charset gbk;
	cd Y320U_EMMC;
	cd HOAT中间文件;
	cd $FTP_FOLDER_NAME;
	get $OTA_COMPARED_VERSION_PACKAGE_NAME;
    bye;
EOF
}

function getLastVersionPackage(){
	cd $FINAL_PACKAGE_SAVE_DIR/

	if [ -f "$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
		cp -f $OTA_COMPARED_VERSION_PACKAGE_NAME ./$FOLDER_NAME/$OTA_UPDATE_DIR
	else
		cd $FOLDER_NAME/$OTA_UPDATE_DIR
		getLastVersionPackageFromFtp
		cd -
	fi 

	if [ ! -f "$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
		checkCommandExc
	fi 
}
if [ "F" = "$IS_FIRST_RELEASE" ]; then
	getLastVersionPackage
fi

#make update ota package naem
UPDATE_OTA_PACKAGE_NAME=""
UPDATE_OTA_PACKAGE_NAME_VALIDATE=""
PREVIOUS_VERSION=""

function makeUpdateOtaPrama(){
	#make short project name
	local SHORT_PROJECT_NAME_T=${HWV_PROJECT_NAME#*-}
	SHORT_PROJECT_NAME=`echo $SHORT_PROJECT_NAME_T|tr '[:upper:]' '[:lower:]'`

	local V_N=`echo $FINAL_VERSION|tr '[:upper:]' '[:lower:]'` 
    local V=""
    local OCV=`echo $OTA_COMPARED_VERSION|tr '[:upper:]' '[:lower:]'`
    if [ "$OCV" = "default" ] || [ "$OCV" = "d" ] || [ "$OCV" = "dflt" ]; then
		local V_T=`getLastVersion`

		PREVIOUS_VERSION=${FOLDER_NAME_PRE}${V_T}
		V=`echo $V_T|tr '[:upper:]' '[:lower:]'`	
	else
		PREVIOUS_VERSION=${FOLDER_NAME_PRE}${OTA_COMPARED_VERSION}
		V=`echo $OTA_COMPARED_VERSION|tr '[:upper:]' '[:lower:]'`
	fi
        
    UPDATE_OTA_PACKAGE_NAME=${SHORT_PROJECT_NAME}_${V}"--"${V_N}"_"${TARGET_BUILD_VARIANT}".zip"
	UPDATE_OTA_PACKAGE_NAME_VALIDATE=${SHORT_PROJECT_NAME}"_"${V_N}"--"${V}"_"${TARGET_BUILD_VARIANT}".zip"

	OTA_DIFF_FILE=$FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$UPDATE_OTA_PACKAGE_NAME
	OTA_DIFF_FILE_VALIDATE=$FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$UPDATE_OTA_PACKAGE_NAME_VALIDATE
}
if [ "F" = "$IS_FIRST_RELEASE" ]; then
	makeUpdateOtaPrama
else
	SHORT_PROJECT_NAME=`echo ${HWV_PROJECT_NAME#*-}|tr '[:upper:]' '[:lower:]'`
fi

function makeFtpBackupOtaPackageName(){
	TEMP_V=`echo $FINAL_VERSION|tr '[:lower:]' '[:upper:]'`
	FTP_BACKUP_HOAT_MIDDLE_FILE_NAME=${SHORT_PROJECT_NAME}"_"${TEMP_V}"_"${TARGET_BUILD_VARIANT}".zip"

	local HCV=`echo $HWV_CUSTOM_VERSION|tr '[:lower:]' '[:upper:]'`

	if [ "T" = "$IS_BASE_VERSION_SPECIALLY" ] && [ ! "$HWV_CUSTOM_VERSION" = "$BASE_CUSTOM_COD" ]; then
       FTP_BACKUP_HOAT_MIDDLE_FILE_NAME=${SHORT_PROJECT_NAME}"_"${HCV}"_"${TEMP_V}"_"${TARGET_BUILD_VARIANT}".zip"
    fi

	FTP_BACKUP_HOAT_MIDDLE_FILE_NAME=`echo $FTP_BACKUP_HOAT_MIDDLE_FILE_NAME|tr '[:upper:]' '[:lower:]'`
}

function makeOtaPackage(){
	cd $CKT_HOME

	#make ota different split package
	log4line "begin to make ota different split package..."
	log4model

	./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $OTA_DIFF_FILE
	checkCommandExc

	log4line "begin to make validate ota different split package..."
	log4model

	#buil validate ota different split package
	./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME $OTA_DIFF_FILE_VALIDATE
	checkCommandExc

	cd $FINAL_PACKAGE_SAVE_DIR

	## if the ota compared version's package download from FTP service, keep it on local machine
	if [ -f "$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
		rm -f $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME
	else
		mv -f $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME ./
	fi

    makeFtpBackupOtaPackageName

	cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip  $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/$FTP_BACKUP_HOAT_MIDDLE_FILE_NAME
	checkCommandExc
}
if [ "F" = "$IS_FIRST_RELEASE" ]; then
	makeOtaPackage
else
    makeFtpBackupOtaPackageName

	cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip  $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/$FTP_BACKUP_HOAT_MIDDLE_FILE_NAME
	checkCommandExc
fi

# defind vars for vendor ota package
HUAWEI_OTA_PACKAGE_NAME=""
OTA_UPDATE_COMPONENT_NAME=""
FULL_DIR=""
OTA_CONFIG_DIR=""
UPDATE_PACKAGE_DIR=""
CHANAGE_LOG_FILE=""
FILE_LIST_FILE=""

function readVendorOtaConfig(){
    local HUAWEI_OTA_PACKAGE_NAME_T=`sed -n '/^HUAWEI_OTA_PACKAGE_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    HUAWEI_OTA_PACKAGE_NAME=${HUAWEI_OTA_PACKAGE_NAME_T#*=}

    local OTA_UPDATE_COMPONENT_NAME_T=`sed -n '/^OTA_UPDATE_COMPONENT_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    OTA_UPDATE_COMPONENT_NAME=${OTA_UPDATE_COMPONENT_NAME_T#*=}

    local FULL_DIR_T=`sed -n '/^OTA_UPDATE_FULL_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    FULL_DIR=${FULL_DIR_T#*=}

    local OTA_CONFIG_DIR_T=`sed -n '/^OTA_UPDATE_CONFIG_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    OTA_CONFIG_DIR=${OTA_CONFIG_DIR_T#*=}

    local UPDATE_PACKAGE_DIR_T=`sed -n '/^OTA_UPDATE_PACKAGE_DIR_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    UPDATE_PACKAGE_DIR=${UPDATE_PACKAGE_DIR_T#*=}

    local CHANAGE_LOG_FILE_T=`sed -n '/^OTA_UPDATE_CHANAGE_LOG_FILE/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    CHANAGE_LOG_FILE=${CHANAGE_LOG_FILE_T#*=}

    local FILE_LIST_FILE_T=`sed -n '/^OTA_UPDATE_FILE_LIST_FILE/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
    FILE_LIST_FILE=${FILE_LIST_FILE_T#*=}
}

#  add for make vendor ota file
function makeVendorOtaFileByVar() {
    cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR

    local VSN=""
    local SPTH=""
    local DPTH=""
    local ODFL=""
    local U_ZIP_NAME=""
	local V_LOW=""
	local V_HEIGHT=""

    if [ "$1" = "T" ]; then
		log4line "begin to make vendor ota file..."
		log4model

        VSN="$FOLDER_NAME_PRE$FINAL_VERSION"
		V_LOW="$PREVIOUS_VERSION"
		V_HEIGHT="${FOLDER_NAME_PRE}${FINAL_VERSION}"
        SPTH="$HUAWEI_OTA_PACKAGE_NAME"
        DPTH="$HUAWEI_OTA_PACKAGE_NAME"
        ODFL="$OTA_DIFF_FILE"
        U_ZIP_NAME=${PREVIOUS_VERSION}"_"${TARGET_BUILD_VARIANT}"--"${FOLDER_NAME}"-updatepackage.zip"
    else
		log4line "begin to make validate vendor ota file..."
		log4model

        VSN="$PREVIOUS_VERSION"
		V_LOW="${FOLDER_NAME_PRE}${FINAL_VERSION}"
		V_HEIGHT="$PREVIOUS_VERSION"
        SPTH="$HUAWEI_OTA_PACKAGE_NAME"
        DPTH="$HUAWEI_OTA_PACKAGE_NAME"
        ODFL="$OTA_DIFF_FILE_VALIDATE"
        U_ZIP_NAME=${FOLDER_NAME}"--"${PREVIOUS_VERSION}"_"${TARGET_BUILD_VARIANT}"-updatepackage.zip"
    fi

    cp -f $ODFL $HUAWEI_OTA_PACKAGE_NAME

    cp -rf $VERSION_RELEASE_SHELL_FOLDER/data/${VENDOR}"_ota"/$UPDATE_PACKAGE_DIR/$OTA_CONFIG_DIR ./
    checkCommandExc
    
    rm -rf $FULL_DIR
    mkdir $FULL_DIR

    cd $OTA_CONFIG_DIR
	sed -i "s/\$COMPONENT_NAME/${OTA_UPDATE_COMPONENT_NAME}/g" $CHANAGE_LOG_FILE
    checkCommandExc
	
	sed -i "s/\$TARGET_VERSION/${VSN}/g" $CHANAGE_LOG_FILE
    checkCommandExc

	sed -i "s/\$VERSION_LOW/${V_LOW}/g" $CHANAGE_LOG_FILE
    checkCommandExc

	sed -i "s/\$VERSION_HEIGHT/${V_HEIGHT}/g" $CHANAGE_LOG_FILE
    checkCommandExc

    local CHANAGE_LOG_MD5_CONTENT=`md5sum $CHANAGE_LOG_FILE| cut -d' ' -f1|tr '[:lower:]' '[:upper:]'`
    local CHANAGE_LOG_FILE_SIZE_CONTENT=`ls -la $CHANAGE_LOG_FILE| cut -d' ' -f5`
	
	sed -i "s/\$COMPONENT_NAME/${OTA_UPDATE_COMPONENT_NAME}/g" $FILE_LIST_FILE
	checkCommandExc
	
	sed -i "s/\$SPATH/${CHANAGE_LOG_FILE}/g" $FILE_LIST_FILE
	checkCommandExc
	
	sed -i "s/\$DPATH/${CHANAGE_LOG_FILE}/g" $FILE_LIST_FILE
	checkCommandExc
	
	sed -i "s/\$MD5_PATH/${CHANAGE_LOG_MD5_CONTENT}/g" $FILE_LIST_FILE
	checkCommandExc
	
	sed -i "s/\$PATN_SIZE/${CHANAGE_LOG_FILE_SIZE_CONTENT}/g" $FILE_LIST_FILE
	checkCommandExc

    local OTA_DIFF_MD5_CONTENT=`md5sum $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$HUAWEI_OTA_PACKAGE_NAME | cut -d' ' -f1|tr '[:lower:]' '[:upper:]'`
    local OTA_DIFF_FILE_SIZE_CONTENT=`ls -la $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$HUAWEI_OTA_PACKAGE_NAME | cut -d' ' -f5`
	
	sed -i "s/\$HOTA_SPATH/${SPTH}/g" $FILE_LIST_FILE
	checkCommandExc
	
	sed -i "s/\$HOTA_DPATH/${DPTH}/g" $FILE_LIST_FILE
	checkCommandExc
	
	sed -i "s/\$MD5_HOTA_PATH/${OTA_DIFF_MD5_CONTENT}/g" $FILE_LIST_FILE
	checkCommandExc
	
	sed -i "s/\$HOTA_PATH_SIZE/${OTA_DIFF_FILE_SIZE_CONTENT}/g" $FILE_LIST_FILE
	checkCommandExc

    cd -

    # copy xml file and ota file to  dir
    echo "copying $CHANAGE_LOG_FILE $FILE_LIST_FILE and $HUAWEI_OTA_PACKAGE_NAME to $FULL_DIR"
    cp $OTA_CONFIG_DIR/$CHANAGE_LOG_FILE $FULL_DIR/
    checkCommandExc

    cp $OTA_CONFIG_DIR/$FILE_LIST_FILE $FULL_DIR/
    checkCommandExc

    cp -f $HUAWEI_OTA_PACKAGE_NAME $FULL_DIR/
    checkCommandExc

    rm -f $HUAWEI_OTA_PACKAGE_NAME

    mv -f $ODFL $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/
    checkCommandExc

    rm -rf $OTA_CONFIG_DIR

    # package the ota file
    echo "packaging the ota file..."
    zip -rm $U_ZIP_NAME $FULL_DIR/
    echo "package finished!"

	if [ "$1" = "F" ]; then
		if [ "$IS_MAKE_HUAWEI_OTA_PACKAGE" = "F" ]; then
			echo "Ota different split package is maked completed, there has no more task to do, the tools will exit!"
			exit
		fi
	fi
}

#make vendor ota file
if [ "F" = "$IS_FIRST_RELEASE" ]; then
	readVendorOtaConfig

	makeVendorOtaFileByVar "T"

	makeVendorOtaFileByVar "F"
fi

function copyDocAndTools(){
	cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/
	cp -rf $VERSION_RELEASE_SHELL_FOLDER/data/update_tools ./$DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME

	if [ "F" = "$IS_FIRST_RELEASE" ]; then
		echo "make hota readme file begin" 
		local CDATE=`date '+%Y\\.%m\\.%d %H\\:%M'`
		
        cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR
		cp -rf $VERSION_RELEASE_SHELL_FOLDER/data/${VENDOR}"_ota"/README.txt ./$README_FILE_NAME

		if [ "T" = "$IS_EXTERNAL_VERSION_LOCKED" ]; then
			local LOCKED_VERSION=${FOLDER_NAME_PRE}${VERSION}
			sed -i "s/\$VERSION_LOW/$LOCKED_VERSION/g" $README_FILE_NAME
			sed -i "s/\$VERSION_HEIGHT/$LOCKED_VERSION/g" $README_FILE_NAME
		else
			sed -i "s/\$VERSION_LOW/${PREVIOUS_VERSION}/g" $README_FILE_NAME
			sed -i "s/\$VERSION_HEIGHT/${FOLDER_NAME_PRE}${FINAL_VERSION}/g" $README_FILE_NAME
		fi

		sed -i "s/\$INTERNAL_VERSION_LOW/${PREVIOUS_VERSION}/g" $README_FILE_NAME
		sed -i "s/\$INTERNAL_VERSION_HEIGHT/${FOLDER_NAME_PRE}${INTERNAL_VERSION}/g" $README_FILE_NAME

		local DEVICE_NAME=`sed -n '/^ro.product.model/p' "$BUILD_PROP_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`

		sed -i "s/\$DEVICE_NAME/$DEVICE_NAME/g" $README_FILE_NAME
		sed -i "s/\$CURRENT_DATE/${CDATE}/g" $README_FILE_NAME
		echo "make hota readme file finish"
	fi
	
    cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/
	local DOC_SAVE_DIR=`sed -n '/^DOC_SAVE_DIR/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`

	local DOC=""
	if [ "T" = "$IS_BASE_VERSION_SPECIALLY" ] && [ "$HWV_CUSTOM_VERSION" = "$BASE_CUSTOM_COD" ]; then
		DOC="$DOC_SAVE_DIR/${HWV_PROJECT_NAME}_DOC"
	else
		DOC="$DOC_SAVE_DIR/${HWV_PROJECT_NAME}_${HWV_CUSTOM_VERSION}_DOC"
	fi

	if [ -d "$DOC" ]; then
		cp -rf $DOC ./$DOCUMENT_FOLDER_NAME
		cd $DOCUMENT_FOLDER_NAME
		rename "s/$OTA_COMPARED_VERSION/$FINAL_VERSION/" *
	fi
}
copyDocAndTools

function makeEngBootimg(){
	if [ "T" = "$IS_MAKE_ENG_BOOT_IMG" ] && [ "$TARGET_BUILD_VARIANT" = 'user' ]; then
		log4line "begin to make eng boot img file..."
		log4model

		cd $CKT_HOME
		$CKT_HOME/mk bootimage new
		checkCommandExc;
	
		cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$ENG_BOOT_IMG
		cp -rf $CKT_HOME_OUT_PROJECT/boot.img ./
	fi
}
makeEngBootimg

function sendBackupFile2Ftp(){
	if [ "T" = "$IS_SEND_BACKUP_FILE_TO_SERVICE" ]; then
		echo -e "`date '+%Y%m%d  %T'` begin to sen hoat middle files to ftp service..." 
			
		cd $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/

#do not change the EOF code's position for it must be coded lisk this!
lftp $FTP_URL<< EOF
	set ftp:charset gbk;
	cd Y320U_EMMC;
	cd HOAT中间文件;
	cd $FTP_FOLDER_NAME;
    put $FTP_BACKUP_HOAT_MIDDLE_FILE_NAME;
    bye;
EOF
	fi
}

# send hoat middle file to ftp service to backup
sendBackupFile2Ftp

function changeDirName2Chinese(){
	if [ "T" = "$NEED_CHANGE_DIR_NAME" ];then
		log4line "begin to change english directory name to chinese characters..."
		log4model

		cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/
	
		#HePJ: Because shell is not perfectly support chinese characters, so the chinese folder name can not config 
		local OTA_UPDATE_FOLDER_NAME="OTA升级差分包"
		local SDCARD_UPDATE_FOLDER_NAME="SD卡升级软件包"
		local USB_UPDATE_FOLDER_NAME="USB升级软件包"
		local UPDATE_TOOLS_FOLDER_NAME="升级工具及指导"
		local HOAT_README="HOTA说明文件.txt"

		if [ "F" = "$IS_FIRST_RELEASE" ]; then
			mv -f $OTA_UPDATE_DIR "$OTA_UPDATE_FOLDER_NAME"
		fi
		mv -f $SDCARD_UPDATE "$SDCARD_UPDATE_FOLDER_NAME"
		mv -f $USB_UPDATE "$USB_UPDATE_FOLDER_NAME"
		mv -f $DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME "$UPDATE_TOOLS_FOLDER_NAME"
		mv -f $README_FILE_NAME "$HOAT_README"

		if [ "T" = "$IS_MAKE_ENG_BOOT_IMG" ] && [ "$TARGET_BUILD_VARIANT" = 'user' ]; then
			local ENG_BOOT_IMG_CHINESE="带root权限的bootimage"
			mv -f $ENG_BOOT_IMG "$ENG_BOOT_IMG_CHINESE"
		fi
	fi
}

#if you shell environment support chinese characters, you can go config.con, set the [-R] option default on
changeDirName2Chinese

function localBackup(){
	if [ "T" = "$IS_LOCAL_BACKUP" ]; then
		local LOCAL_FTP_ZIP="${FOLDER_NAME}.rar"
		cd $FINAL_PACKAGE_SAVE_DIR
		rar a $LOCAL_FTP_ZIP ./$FOLDER_NAME ./$FTP_BACKUP_DIR

lftp $LOCAL_FTP_URL<< EOF
	set ftp:charset gbk;
	put $LOCAL_FTP_ZIP;
	bye;
EOF
		
    rm -f $LOCAL_FTP_ZIP
	fi
}

# send version package to local computer,so you can release you version even the VM was not started
localBackup

cd $FINAL_PACKAGE_SAVE_DIR
ls -lt
echo -e "`date '+%Y%m%d  %T'` \033[49;31;5m The final package save dir is: `pwd` \033[0m DOWN" 
