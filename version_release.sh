#!/bin/bash -e                       

##defind vars

# project dir
CKT_HOME=`pwd`

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
IS_EXTERNAL_VERSION_LOCKED="F"

IS_MAKE_FILE="T"

IS_FIRST_RELEASE="F"

IS_REPEAT_BUILD="F"

IS_DO_CHECK="T"

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

#demain is write log to log file
IS_LOG_TO_FILE="T"

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
            IS_ONLY_BUILD="T"
            ;;
       \w ) IS_MAKE_HUAWEI_OTA_PACKAGE="F"
            ;;
       \x ) IS_ONLY_MAKE_PACHAGE="y"
            #IS_MAKE_FILE="F"
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
       \K ) IS_EXTERNAL_VERSION_LOCKED="T"
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
    LOG=`echo $DT $1|awk '{printf "%-83s" ,$0}'`
    
    if [ -f "$LOG_FILE" ] && [ "T" = "$IS_LOG_TO_FILE" ] && [ "$2" = "T" ]; then
        echo $LOG >> $LOG_FILE 
    fi

    if [ "$2" = "T" ]; then
        echo -e $LOG 
    fi
}

function log4model(){
    local TEMP_STR=`makeFixedLengStr "=" 89 "="`
    echo "+$TEMP_STR+"
    echo "+=  $LOG  =+" 
    echo "+$TEMP_STR+"

    if [ -f "$LOG_FILE" ] && [ "T" = "$IS_LOG_TO_FILE" ]; then 
        echo "+$TEMP_STR+" >> $LOG_FILE 
        echo "+=  $LOG  =+" >> $LOG_FILE 
        echo "+$TEMP_STR+" >> $LOG_FILE 
    fi
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

##defind global vars

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
            K ) IS_EXTERNAL_VERSION_LOCKED="T"
                ;;
            X ) IS_MAKE_FILE="F"
                IS_MAKE_HOTA_PACKAGE="F"
                IS_ONLY_MAKE_PACHAGE="y"
                ;;
            D ) IS_KEEP_DEFAULT_CONFIG="T"
                ;;
            F ) IS_FIRST_RELEASE="T"
            	;;
			G ) IS_LOG_TO_FILE="F"
                ;;
            C ) IS_DO_CHECK="F"
                ;;
         esac
    done
}
getDefaultOption

function doCheck(){
    if [ "T" = "$IS_DO_CHECK" ]; then
        if [ $IS_MAKE_FILE = "T" ] && [ $IS_ONLY_MAKE_PACHAGE = "n" ]; then
            . $VERSION_RELEASE_SHELL_FOLDER/checklist.sh
        fi
    fi
}
doCheck

if [ $OPTION_COUNT -eq 0 ] || [ "$1" = "-x" ]  || [ "$1" = "-l" ] || [ "$1" = "-m" ] || [ "$1" = "-n" ] || [ "$1" = "-w" ] || [ "$1" = "-R" ] || [ "$1" = "-I" ] || [ "$1" = "-B" ] || [ "$1" = "-E" ] || [ "$1" = "-X" ] || [ "$1" = "-D" ] || [ "$1" = "-F" ] || [ "$1" = "-O" ]; then
   fShowMenu
   IS_MENU_SHOW="T"
fi

#get version param
HWV_BUILD_VERSION=""
HWV_BUILDINTERNAL_VERSION=""
HWV_PROJECT_NAME=""
HWV_CUSTOM_VERSION=""

function getVersionParam(){
    #read version control
    local HWV_PROJECT_NAME_T=`sed -n '/^HWV_PROJECT_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
 
    local HWV_VERSION_NAME_T=`sed -n '/^HWV_VERSION_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`

    local HWV_RELEASE_NAME_T=`sed -n '/^HWV_RELEASE_NAME/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`

    local HWV_CUSTOM_VERSION_T=`sed -n '/^HWV_CUSTOM_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`

    local HWV_BUILDINTERNAL_VERSION_T=`sed -n '/^HWV_BUILDINTERNAL_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`

    local HWV_BUILD_VERSION_T=`sed -n '/^HWV_BUILD_VERSION/p' "$PROJECT_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`

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

        if [ "F" = "$IS_EXTERNAL_VERSION_LOCKED" ];then
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
        if [ -z "$OTA_COMPARED_VERSION" ]; then
            tipUserInputLastVersion        
        fi
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
        if [ -z "$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
            tipsUserInputComparedVersion 
        else
            FOLDER_NAME=${FOLDER_NAME_PRE}${FINAL_VERSION}"_"${TARGET_BUILD_VARIANT}
        fi 
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
        fi

        if [ $INTERNAL_VERSION != $HWV_BUILDINTERNAL_VERSION ] ;then   
        sed -i "s/HWV_BUILDINTERNAL_VERSION \= $HWV_BUILDINTERNAL_VERSION/HWV_BUILDINTERNAL_VERSION \= $INTERNAL_VERSION/g" "$PROJECT_CONFIG_FILE"
        fi
    fi
}
doConfirm

function makeLogFile(){
    LOG_FILE="$FINAL_PACKAGE_SAVE_DIR/ckt_version_release.log"
    if [ -f "$LOG_FILE" ]; then
        local L_V=`sed -n '/^Build_Number/p' "$LOG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
        if [ "$L_V" = "${FOLDER_NAME_PRE}${FINAL_VERSION}" ]; then
            IS_REPEAT_BUILD="T"
        fi
    fi

    > $LOG_FILE

    local T_BUILD_TIME=`date '+%Y%m%d  %T'`
    echo "Build Time=$T_BUILD_TIME" >> $LOG_FILE
    echo "Build_Number=${FOLDER_NAME_PRE}${FINAL_VERSION}" >> $LOG_FILE
    echo "Project Name=$PROJECT_NAME" >> $LOG_FILE
    echo "Target Build Variant=$TARGET_BUILD_VARIANT" >> $LOG_FILE
    echo "External Version=$VERSION" >> $LOG_FILE
    echo "Internal Version=$INTERNAL_VERSION" >> $LOG_FILE
    echo "Is First Release version=$IS_FIRST_RELEASE" >> $LOG_FILE
    echo "Default Strengthen Option=${ARRY_DEFAUIT_OPTIONS[@]}" >> $LOG_FILE

    if [ "F" = "$IS_FIRST_RELEASE" ] || [ "$IS_MAKE_HOTA_PACKAGE" = "F" ]; then
        echo "Compared Version=$OTA_COMPARED_VERSION" >> $LOG_FILE
        echo "Last Version Package Name=$OTA_COMPARED_VERSION_PACKAGE_NAME" >> $LOG_FILE
    fi

    echo "Is Only Make Package=$IS_ONLY_MAKE_PACHAGE" >> $LOG_FILE
    echo "-------------------------------detail log below---------------------" >> $LOG_FILE
}

if [ "T" = "$IS_LOG_TO_FILE" ]; then
    makeLogFile
fi

function cleanDust(){
    log4line "Begin to clean last release version's dust......!" "T"
    if [ -d "$CKT_HOME/out" ]; then 
        ${CKT_HOME}/mk c
    fi 
    
    rm -rf $CKT_HOME/out
    rm -rf $CKT_HOME/ckt/*.zip
    rm -rf $CKT_HOME/ckt/.bin
}

function doMakeAction(){
    if [ "$IS_ONLY_MAKE_PACHAGE" = "n" ] ;then
        log4line "Call 'mk' to make version..." "F"
        log4model

        #clear dust
        cleanDust

        if [ "$TARGET_BUILD_VARIANT" = 'user' ] ;then
            ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME new

            if [ "T" = "$IS_MAKE_OTAUPDATE" ]; then
                ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME otapackage
            fi
        elif [ "$TARGET_BUILD_VARIANT" = 'eng' ] ;then
            ${CKT_HOME}/mk $PROJECT_NAME new

            if [ "T" = "$IS_MAKE_OTAUPDATE" ]; then
                ${CKT_HOME}/mk $PROJECT_NAME otapackage
            fi
        fi
    fi

    if [ "$IS_ONLY_BUILD" = "T" ] && [ "$IS_MAKE_HOTA_PACKAGE" = "T" ]; then
        log4line "Build is completed, there has no more task to do, the tools will exit!" "T"
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
    
    if [ "F" = "$IS_FIRST_RELEASE" ]; then
        OTA_UPDATE_DIR=`sed -n '/^MIDDLE_HOTA_UPDATE_SOFTWARE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
    fi

    SDCARD_UPDATE=`sed -n '/^SD_CARD_SOFTWARE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`

    USB_UPDATE=`sed -n '/^USB_SOFTWARE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`

    ENG_BOOT_IMG=`sed -n '/^ENG_BOOT_IMAGE_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`

    DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME=`sed -n '/^DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`

    README_FILE_NAME=`sed -n '/^README/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
}

function getFtpParam(){
   local FTP_ADDR_T=`sed -n '/^FTP_ADD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
   FTP_ADDR=`echo ${FTP_ADDR_T#*=} | tr 'P-~!-O' '!-~'`

   local FTP_USER_NAME_T=`sed -n '/^FTP_USER_NAME/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`;
   FTP_USER_NAME=`echo ${FTP_USER_NAME_T#*=} | tr 'P-~!-O' '!-~'`

   local FTP_USER_PASSORD_T=`sed -n '/^FTP_USER_PASSORD/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'`
   FTP_USER_PASSORD=`echo ${FTP_USER_PASSORD_T#*=} | tr 'P-~!-O' '!-~'`
        
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

GIT_URL=""
GIT_HOTA_FOLDER_NAME=""
function makeGitUrl(){
    local CONFIG_GIT_URL_PRE=`sed -n '/^CONFIG_GIT_URL_PRE/p' "$VERSION_RELEASE_CONFIG_FILE"|sed 's/#.*$//g'|sed 's/\ //g'|awk -F "=" '{print $2}'`
    local TMP_FOLDER_NAME=`echo ${HWV_PROJECT_NAME/-/_} | tr '[:upper:]' '[:lower:]'`
    local TMP_DEV_PRE=""
    local TMP_DEV_SUF=""
    local IS_R4=""
    local T_VS=`echo $VERSION | tr '[:upper:]' '[:lower:]'`

    if [ "$HWV_CUSTOM_VERSION" = "$BASE_CUSTOM_COD" ]; then
        TMP_DEV_PRE=${TMP_FOLDER_NAME%*-*}
        TMP_DEV_SUF=${TMP_FOLDER_NAME#*-}
        if [ "u10" = "$TMP_DEV_SUF" ]; then
            TMP_DEV_SUF="hwdsls"
        fi
        
        IS_R4=`echo ${T_VS:$((${#T_VS}-1)):1}`
        if [ "n" = "$IS_R4" ]; then
            GIT_HOTA_FOLDER_NAME="${TMP_DEV_PRE}_r4_${TMP_DEV_SUF}"
        else
            GIT_HOTA_FOLDER_NAME="${TMP_DEV_PRE}_${TMP_DEV_SUF}"
        fi
        
    else
        GIT_HOTA_FOLDER_NAME=`echo ${TMP_FOLDER_NAME}_${HWV_CUSTOM_VERSION} | tr '[:upper:]' '[:lower:]'`
    fi
     
    GIT_URL="$CONFIG_GIT_URL_PRE:int/$GIT_HOTA_FOLDER_NAME"
}
makeGitUrl

function makeFinalDir(){
    local TEMP_STR=`makeFixedLengStr "-" 90 "-"`
    echo "$TEMP_STR"
    log4line "begin make version release folder..." "T"

    cd $FINAL_PACKAGE_SAVE_DIR
    rm -rf $FOLDER_NAME
    mkdir $FOLDER_NAME

    local FTP_BACKUP_DIR_T=`echo ${HWV_CUSTOM_VERSION}_${FINAL_VERSION}"_"${TARGET_BUILD_VARIANT}"_ftp_backup"|tr '[:lower:]' '[:upper:]'`
    FTP_BACKUP_DIR=$FTP_BACKUP_DIR_T
    if [ "T" = "$IS_FIRST_RELEASE" ]; then
        FTP_BACKUP_DIR="${FTP_BACKUP_DIR_T}/$FTP_FOLDER_NAME"
    fi

    rm -rf $FTP_BACKUP_DIR
    if [ "T" = "$IS_MAKE_FILE" ]; then
        mkdir -p $FTP_BACKUP_DIR/
    fi

    cd $FOLDER_NAME
    getFolderParam
    if [ "F" = "$IS_FIRST_RELEASE" ] && [ "T" = "$IS_MAKE_FILE" ]; then
        mkdir $OTA_UPDATE_DIR
    fi

    if [ "T" = "$IS_MAKE_FILE" ]; then
        mkdir $SDCARD_UPDATE
    fi

    mkdir $USB_UPDATE

    if [ "T" = "$IS_MAKE_ENG_BOOT_IMG" ] && [ "$TARGET_BUILD_VARIANT" = 'user' ]; then
        mkdir $ENG_BOOT_IMG
    fi
}

#make dir
makeFinalDir

function makeSdcardUpdate(){
    log4line "copy sdcard update to folder..." "T"
    cd $SDCARD_UPDATE
    cp -f $CKT_HOME/out/target/product/$PROJECT_NAME/$PROJECT_NAME-ota-*.zip ./update.zip
}

#copy sdcard update
if [ "$IS_MAKE_FILE" = "T" ] && [ "T" = "$IS_MAKE_OTAUPDATE" ]; then
    makeSdcardUpdate
fi

#copy usb update
function makeUsbUpdate(){
    log4line "make usb update to folder..." "T"
    cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$USB_UPDATE

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
    
    if [ "$IS_MAKE_HOTA_PACKAGE" = "F" ]; then
        log4line "Package is maked completed, there has no more task to do, the tools will exit!" "T"
        exit 1
    fi
}

makeUsbUpdate

function getLastVersionPackageFromFtp(){
#do not change the EOF code's position for it must be coded lisk this!
ftp -n << EOF
    open $FTP_ADDR
    user $FTP_USER_NAME $FTP_USER_PASSORD
    binary
    cd $FTP_FOLDER_NAME 
    get $OTA_COMPARED_VERSION_PACKAGE_NAME
    bye
EOF
}

IS_HOTA_PACKAGE_FROM_GIT="F"
function getLastVersionPackage(){
    log4line "begin to make ota different split package..." "F"
    log4model

    cd $FINAL_PACKAGE_SAVE_DIR/

    if [ -f "$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
        log4line "use local ota compared version package to make ota different package..." "T"
        cp -f $OTA_COMPARED_VERSION_PACKAGE_NAME ./$FOLDER_NAME/$OTA_UPDATE_DIR
    else
        cd $FOLDER_NAME/$OTA_UPDATE_DIR
        log4line "use remote ota compared version package from ftp server to make ota different package..." "T"
        getLastVersionPackageFromFtp
        cd -
    fi 

    if [ ! -f "$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
        cd $CKT_HOME/
        if [ -d "$CKT_HOME/$GIT_HOTA_FOLDER_NAME" ]; then
            cd $GIT_HOTA_FOLDER_NAME
            if [ -d "$CKT_HOME/$GIT_HOTA_FOLDER_NAME/.git" ]; then
                git pull
            else
                local TMP_T=`date +%s`
                cd $CKT_HOME/
                GIT_HOTA_FOLDER_NAME="$GIT_HOTA_FOLDER_NAME$TMP_T"
                git clone $GIT_URL $GIT_HOTA_FOLDER_NAME
            fi
        else
            git clone $GIT_URL
        fi
        cp -f $GIT_HOTA_FOLDER_NAME/$OTA_COMPARED_VERSION_PACKAGE_NAME $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME
        IS_HOTA_PACKAGE_FROM_GIT="T"
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
    FTP_BACKUP_HOTA_MIDDLE_FILE_NAME=${SHORT_PROJECT_NAME}"_"${TEMP_V}"_"${TARGET_BUILD_VARIANT}".zip"

    local HCV=`echo $HWV_CUSTOM_VERSION|tr '[:lower:]' '[:upper:]'`

    if [ "T" = "$IS_BASE_VERSION_SPECIALLY" ] && [ ! "$HWV_CUSTOM_VERSION" = "$BASE_CUSTOM_COD" ]; then
       FTP_BACKUP_HOTA_MIDDLE_FILE_NAME=${SHORT_PROJECT_NAME}"_"${HCV}"_"${TEMP_V}"_"${TARGET_BUILD_VARIANT}".zip"
    fi

    FTP_BACKUP_HOTA_MIDDLE_FILE_NAME=`echo $FTP_BACKUP_HOTA_MIDDLE_FILE_NAME|tr '[:upper:]' '[:lower:]'`
}

function makeOtaPackage(){
    cd $CKT_HOME

    #make ota different split package
    ./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $OTA_DIFF_FILE

    log4line "begin to make validate ota different split package..." "F"
    log4model

    #buil validate ota different split package
    ./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/${PROJECT_NAME}-target_files-*.zip $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME $OTA_DIFF_FILE_VALIDATE

    cd $FINAL_PACKAGE_SAVE_DIR

    ## if the ota compared version's package download from FTP service, keep it on local machine
    if [ -f "$OTA_COMPARED_VERSION_PACKAGE_NAME" ]; then
        rm -f $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME
    else
        mv -f $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$OTA_COMPARED_VERSION_PACKAGE_NAME ./
    fi

    makeFtpBackupOtaPackageName

    cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip  $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/$FTP_BACKUP_HOTA_MIDDLE_FILE_NAME
}
if [ "F" = "$IS_FIRST_RELEASE" ]; then
    makeOtaPackage
else
    makeFtpBackupOtaPackageName

    cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip  $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/$FTP_BACKUP_HOTA_MIDDLE_FILE_NAME
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
        log4line "begin to make vendor ota file..." "F"
        log4model

        VSN="$FOLDER_NAME_PRE$FINAL_VERSION"
        V_LOW="$PREVIOUS_VERSION"
        V_HEIGHT="${FOLDER_NAME_PRE}${FINAL_VERSION}"
        SPTH="$HUAWEI_OTA_PACKAGE_NAME"
        DPTH="$HUAWEI_OTA_PACKAGE_NAME"
        ODFL="$OTA_DIFF_FILE"
        U_ZIP_NAME=${PREVIOUS_VERSION}"_"${TARGET_BUILD_VARIANT}"--"${FOLDER_NAME}"-updatepackage.zip"
    else
        log4line "begin to make validate vendor ota file..." "F"
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
    
    rm -rf $FULL_DIR
    mkdir $FULL_DIR

    cd $OTA_CONFIG_DIR
    sed -i "s/\$COMPONENT_NAME/${OTA_UPDATE_COMPONENT_NAME}/g" $CHANAGE_LOG_FILE
    
    sed -i "s/\$TARGET_VERSION/${VSN}/g" $CHANAGE_LOG_FILE

    sed -i "s/\$VERSION_LOW/${V_LOW}/g" $CHANAGE_LOG_FILE

    sed -i "s/\$VERSION_HEIGHT/${V_HEIGHT}/g" $CHANAGE_LOG_FILE

    local CHANAGE_LOG_MD5_CONTENT=`md5sum $CHANAGE_LOG_FILE| cut -d' ' -f1|tr '[:lower:]' '[:upper:]'`
    local CHANAGE_LOG_FILE_SIZE_CONTENT=`ls -la $CHANAGE_LOG_FILE| cut -d' ' -f5`
    
    sed -i "s/\$COMPONENT_NAME/${OTA_UPDATE_COMPONENT_NAME}/g" $FILE_LIST_FILE
    
    sed -i "s/\$SPATH/${CHANAGE_LOG_FILE}/g" $FILE_LIST_FILE
    
    sed -i "s/\$DPATH/${CHANAGE_LOG_FILE}/g" $FILE_LIST_FILE
    
    sed -i "s/\$MD5_PATH/${CHANAGE_LOG_MD5_CONTENT}/g" $FILE_LIST_FILE
    
    sed -i "s/\$PATN_SIZE/${CHANAGE_LOG_FILE_SIZE_CONTENT}/g" $FILE_LIST_FILE
    local OTA_DIFF_MD5_CONTENT=`md5sum $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$HUAWEI_OTA_PACKAGE_NAME | cut -d' ' -f1|tr '[:lower:]' '[:upper:]'`
    local OTA_DIFF_FILE_SIZE_CONTENT=`ls -la $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR/$HUAWEI_OTA_PACKAGE_NAME | cut -d' ' -f5`
    
    sed -i "s/\$HOTA_SPATH/${SPTH}/g" $FILE_LIST_FILE
    
    sed -i "s/\$HOTA_DPATH/${DPTH}/g" $FILE_LIST_FILE
 
    sed -i "s/\$MD5_HOTA_PATH/${OTA_DIFF_MD5_CONTENT}/g" $FILE_LIST_FILE

    sed -i "s/\$HOTA_PATH_SIZE/${OTA_DIFF_FILE_SIZE_CONTENT}/g" $FILE_LIST_FILE

    cd -

    # copy xml file and ota file to  dir
    log4line "copying $CHANAGE_LOG_FILE $FILE_LIST_FILE and $HUAWEI_OTA_PACKAGE_NAME to $FULL_DIR" "T"
    cp $OTA_CONFIG_DIR/$CHANAGE_LOG_FILE $FULL_DIR/
 
    cp $OTA_CONFIG_DIR/$FILE_LIST_FILE $FULL_DIR/

    cp -f $HUAWEI_OTA_PACKAGE_NAME $FULL_DIR/

    rm -f $HUAWEI_OTA_PACKAGE_NAME

    mv -f $ODFL $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/

    rm -rf $OTA_CONFIG_DIR

    # package the ota file
    log4line "packaging the ota file..." "T"
    zip -rm $U_ZIP_NAME $FULL_DIR/
    log4line "package finished!" "T"

    if [ "$1" = "F" ]; then
        if [ "$IS_MAKE_HUAWEI_OTA_PACKAGE" = "F" ]; then
            log4line "Ota different split package is maked completed, there has no more task to do, the tools will exit!" "T"
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
        log4line "make hota readme file begin..." "T"
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

        local DEVICE_NAME=`sed -n '/^ro.product.model/p' "$BUILD_PROP_FILE"|sed 's/#.*$//g'|awk -F "=" '{print $2}'`

        sed -i "s/\$DEVICE_NAME/$DEVICE_NAME/g" $README_FILE_NAME
        sed -i "s/\$CURRENT_DATE/${CDATE}/g" $README_FILE_NAME
        if [ "$TARGET_BUILD_VARIANT" = 'user' ] ;then
            sed -i "s/\$IS_FOR_USER/YES/g" $README_FILE_NAME
        else
            sed -i "s/\$IS_FOR_USER/NO/g" $README_FILE_NAME
        fi
        log4line "make hota readme file finish!" "T"
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
        log4line "begine to copy document to $DOCUMENT_FOLDER_NAME..." "T"
        cp -rf $DOC ./$DOCUMENT_FOLDER_NAME
        cd $DOCUMENT_FOLDER_NAME
        rename "s/$OTA_COMPARED_VERSION/$FINAL_VERSION/" *
        log4line "copy document to $DOCUMENT_FOLDER_NAME end!" "T"
    fi
}
copyDocAndTools

function makeEngBootimg(){
    if [ "T" = "$IS_MAKE_ENG_BOOT_IMG" ] && [ "$TARGET_BUILD_VARIANT" = 'user' ]; then
        log4line "begin to make eng boot img file..." "F"
        log4model

        cd $CKT_HOME
        $CKT_HOME/mk bootimage new

        cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$ENG_BOOT_IMG
        cp -rf $CKT_HOME_OUT_PROJECT/boot.img ./
        log4line "make eng boot img file end!" "F"
    fi
}
makeEngBootimg

#if happend some error in the process of sending ota middle package to ftp server
#please connect the manager to dill with it 
function sendBackupFile2Ftp(){
    local FTP_FOLDER_NAME_BASE1=""
    local FTP_FOLDER_NAME_BASE2=""

    if [ "T" = "$IS_SEND_BACKUP_FILE_TO_SERVICE" ]; then
        log4line "begin to sen hota middle files to ftp service..." "T" 
            
        cd $FINAL_PACKAGE_SAVE_DIR/$FTP_BACKUP_DIR/
            if [ "F" = "$IS_FIRST_RELEASE" ] || [ "T" = "$IS_REPEAT_BUILD" ]; then
                #do not change the EOF code's position for it must be coded lisk this!
ftp -n << EOF
    open $FTP_ADDR 
    user $FTP_USER_NAME $FTP_USER_PASSORD
    set ftp:charset gbk
    binary
    cd $FTP_FOLDER_NAME
    put $FTP_BACKUP_HOTA_MIDDLE_FILE_NAME
    bye
EOF
            else
                if [ "T" = "$IS_BASE_VERSION_SPECIALLY" ] && [ "$HWV_CUSTOM_VERSION" = "$BASE_CUSTOM_COD" ]; then
                    FTP_FOLDER_NAME_BASE1="$HWV_PROJECT_NAME"
                    FTP_FOLDER_NAME_BASE2="${HWV_PROJECT_NAME}"_"${TARGET_BUILD_VARIANT}"
                else
                    FTP_FOLDER_NAME_BASE1="${HWV_PROJECT_NAME}_${HWV_CUSTOM_VERSION}"
                    FTP_FOLDER_NAME_BASE2="${HWV_PROJECT_NAME}_${HWV_CUSTOM_VERSION}"_"${TARGET_BUILD_VARIANT}"
                fi
#do not change the EOF code's position for it must be coded lisk this!
ftp -n << EOF
    open $FTP_ADDR 
    user $FTP_USER_NAME $FTP_USER_PASSORD
    set ftp:charset gbk
    binary
    mkdir -m 777 $FTP_FOLDER_NAME_BASE1
    cd $FTP_FOLDER_NAME_BASE1
    mkdir -m 777 $FTP_FOLDER_NAME_BASE2
    cd $FTP_FOLDER_NAME_BASE2
    put $FTP_BACKUP_HOTA_MIDDLE_FILE_NAME
    bye
EOF
            fi
    fi
}

# send HOTA middle file to ftp service to backup
sendBackupFile2Ftp

function changeDirName2Chinese(){
    if [ "T" = "$NEED_CHANGE_DIR_NAME" ];then
        log4line "begin to change english directory name to chinese characters..." "F"
        log4model

        cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/
    
        #HePJ: Because shell is not perfectly support chinese characters, so the chinese folder name can not config 
        local OTA_UPDATE_FOLDER_NAME="OTA升级差分包"
        local SDCARD_UPDATE_FOLDER_NAME="SD卡升级软件包"
        local USB_UPDATE_FOLDER_NAME="USB升级软件包"
        local UPDATE_TOOLS_FOLDER_NAME="升级工具及指导"
        local HOTA_README="HOTA说明文件.txt"

        if [ "F" = "$IS_FIRST_RELEASE" ]; then
            mv -f $OTA_UPDATE_DIR "$OTA_UPDATE_FOLDER_NAME"
        fi
        mv -f $SDCARD_UPDATE "$SDCARD_UPDATE_FOLDER_NAME"
        mv -f $USB_UPDATE "$USB_UPDATE_FOLDER_NAME"
        mv -f $DOWLOAD_TOOLS_DRIVERS_FOLDER_NAME "$UPDATE_TOOLS_FOLDER_NAME"
        mv -f $README_FILE_NAME "$HOTA_README"

        if [ "T" = "$IS_MAKE_ENG_BOOT_IMG" ] && [ "$TARGET_BUILD_VARIANT" = 'user' ]; then
            local ENG_BOOT_IMG_CHINESE="带root权限的bootimage"
            mv -f $ENG_BOOT_IMG "$ENG_BOOT_IMG_CHINESE"
        fi
        log4line "change english directory name to chinese characters end!" "T"
    fi

    ## the code below is unnecessarily, if upadte, please delete it @{ 
    if [ "F" = "$IS_FIRST_RELEASE" ]; then
        cd $FINAL_PACKAGE_SAVE_DIR/$FOLDER_NAME/$OTA_UPDATE_DIR
        local HOTA_README="Hota说明文件.txt"
        mv -f $README_FILE_NAME "$HOTA_README"
    fi
    ## @}
}

#if you shell environment support chinese characters, you can go config.con, set the [-R] option default on
changeDirName2Chinese

function localBackup(){
    if [ "T" = "$IS_LOCAL_BACKUP" ]; then
        log4line "begin to sen final package to local ftp server..." "T"
        local LOCAL_FTP_ZIP="${FOLDER_NAME}.rar"
        cd $FINAL_PACKAGE_SAVE_DIR
        rar a $LOCAL_FTP_ZIP ./$FOLDER_NAME ./$FTP_BACKUP_DIR

ftp -n << EOF
    open $LOCAL_FTP_ADDR
    user $LOCAL_FTP_USER_NAME $LOCAL_FTP_USER_PASSORD
    set ftp:charset gbk
    binary
    put $LOCAL_FTP_ZIP
    bye
EOF
        
    rm -f $LOCAL_FTP_ZIP
    log4line "sen final package to local ftp server end!" "T"
    fi
}

# send version package to local computer,so you can release you version even the VM was not started
localBackup

function commitToGit(){
    if [ "T" = "$IS_HOTA_PACKAGE_FROM_GIT" ]; then
        log4line "send hota package to fit server!" "T" 
        cd $CKT_HOME/$GIT_HOTA_FOLDER_NAME
        git pull
        
        if [ -f "$CKT_HOME/$GIT_HOTA_FOLDER_NAME/$FTP_BACKUP_HOTA_MIDDLE_FILE_NAME" ]; then
            git add $FTP_BACKUP_HOTA_MIDDLE_FILE_NAME
            git commit -m "add $FTP_BACKUP_HOTA_MIDDLE_FILE_NAME to git service"
            git push

            rm -rf $CKT_HOME/$GIT_HOTA_FOLDER_NAME
        fi
    fi
}
commitToGit

cd $FINAL_PACKAGE_SAVE_DIR
ls -lt
log4line "\033[49;31;5m The final package save dir is: `pwd` \033[0m DOWN" "T"
