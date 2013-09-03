#!/bin/bash

#defind vars
PROJECT_NAME="ckt72_we_jb3"
TARGET_BUILD_VARIANT="user"
VERSION=""
IS_ONLY_MAKE_PACHAGE="n"
USAGE="Usage: $0 [-p project] [-t target_build_variant] [-v version] [-z n or y] [-? show_this_message] "
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


if [ $OPTION_COUNT -eq 0 ] ;then
   fShowMenu;
fi

#read user input
while getopts ":p:t:v:z:" opt; do
    case $opt in
        p ) PROJECT_NAME=$OPTARG 
            ;;
        t ) TARGET_BUILD_VARIANT=$OPTARG 
            ;;
        v ) VERSION=$OPTARG 
            ;;
        z ) IS_ONLY_MAKE_PACHAGE=$OPTARG 
            ;;
       \? ) echo $USAGE 
            exit 1 
            ;;
    esac
done

if [ "$IS_ONLY_MAKE_PACHAGE" = "y" ] ;then
   TARGET_BUILD_VARIANT="p_"${TARGET_BUILD_VARIANT}
fi

CKT_HOME=`pwd`
CKT_HOME_OUT_PROJECT=${CKT_HOME}"/out/target/product/$PROJECT_NAME"
CKT_HOME_MTK_MODEM=${CKT_HOME}"/mediatek/custom/common/modem"
PROJECT_CONFIG_FILE="$CKT_HOME/mediatek/config/$PROJECT_NAME/ProjectConfig.mk"

#read version control
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

if [ -z "$VERSION" ] ;then
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

FOLDER_NAME=$HWV_PROJECT_NAME$HWV_VERSION_NAME$HWV_RELEASE_NAME$HWV_CUSTOM_VERSION$VERSION

echo -e "Please confirm the build information:\n\t \033[49;31;5m Project Name:"${PROJECT_NAME}"\n\t  Target Build Version:" ${TARGET_BUILD_VARIANT}"\n\t  Build Version:"${VERSION}"\n\t  Final Package Folder Name:"${FOLDER_NAME}" \033[0m , \n\tit's correctly(y/n): \c "

read confirm
if [ "$confirm" = 'n' ] ;then
  exit
fi

#build target version 
if [ "$TARGET_BUILD_VARIANT" = 'user' ] ;then
   echo -e "Current version is \033[49;31;5m $FOLDER_NAME \033[0m, Begin to release user version, please wait a moment!"
   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME new
   ${CKT_HOME}/mk -o=TARGET_BUILD_VARIANT=user $PROJECT_NAME otapackage
   sh ${CKT_HOME}/ckt/ckt_release.sh
elif [ "$TARGET_BUILD_VARIANT" = 'eng' ] ;then
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

#prepare to make ota different split package
cp -f $CKT_HOME_OUT_PROJECT/obj/PACKAGING/target_files_intermediates/$PROJECT_NAME-target_files-*.zip $HOME/project_build/ckt_version_release/${VERSION}"_"${TARGET_BUILD_VARIANT}".zip"

#copy modem
echo "copy modem to folder..."
cd ../$UPDATE_FOLDER/usb_ota/${UPDATE_FOLDER}".bin"/DATABASE/
MODEM_DIR_T=`sed -n '/^CUSTOM_MODEM/p' "$PROJECT_CONFIG_FILE"`
CUSTOM_MODEM=${MODEM_DIR_T#*=}

#MODEM_NAME_T1=`sed -n '/^DATABASE_SOURCE/p' "$CKT_HOME/ckt/ckt_release.sh"`
#MODEM_NAME_T2=${MODEM_NAME_T1/\"/}
#MODEM_NAME=${MODEM_NAME_T2/\\/}
#eval $MODEM_NAME

cp -f $CKT_HOME_MTK_MODEM/$CUSTOM_MODEM/BPLGUInfoCustomAppSrcP_* ./

#make zip package
echo "make zip package..."
cd $CKT_HOME
zip -qrm ${FOLDER_NAME}".zip" $FOLDER_NAME

mv ${FOLDER_NAME}".zip" ../
cd $HOME/project_build/ckt_version_release/
DIFFERENT_INPUT=`ls -t|awk -v a=$(pwd) '{print a"/"$0}'|sed -n '1,2p'|sed 'H;$!d;g;s/\n/  /g'`
echo $DIFFERENT_INPUT

cd $CKT_HOME
./build/tools/releasetools/ota_from_target_files -k build/target/product/security/ckt72_we_jb3/releasekey -i $DIFFERENT_INPUT  $HOME/project_build/ckt_version_release/update.zip

echo -e "\033[49;31;5m The release package is: $FOLDER_NAME.zip \033[0m DOWN"
