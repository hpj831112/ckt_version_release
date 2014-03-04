#!/bin/bash

function getConfigFile(){
    cd /sbin
    local VERSION_RELEASE_HOME_T=`readlink ckt_release`
    VERSION_RELEASE_SHELL_FOLDER=${VERSION_RELEASE_HOME_T%*/*}
    VERSION_RELEASE_CONFIG_FILE="$VERSION_RELEASE_SHELL_FOLDER/config.conf"
    cd -
}
getConfigFile

ARRY_COMFIRM=("1. 发布版本的工程，是否为clone的或者是独立的、专门用于发布版本的工程？" 
              "2. 发版本前是否有跟最新的基线同步？" 
              "3. PRI目前使用的是否为最新版本？" 
              "4. PRI里面的每一项需求是否都进行了预测试?" 
              "5. 是否对每个问题修改点进行了回归测试？" 
              "6. 是否对Release notes的格式进行检查并确认格式是正确的？" 
              "7. 是否检查Release notes中的软件版本号并确认版本号是正确的\n（注意：如果是copy过来的需要进行修改）？" 
              "8. 是否检查Release notes中的软件发布日期并确认发布日期是正确的\n（注意：如果是copy过来的需要进行修改）？" 
              "9. 是否检查Release notes中的语言个数并确认言语个数是正确的？" 
              "10. Y320（注意：不包含Y321 DTV定制）的器件兼容清单是否用的是最新版本（11.13版）？" 
              "11. 软件发布包中的器件兼容清单是否用的是最新版本（2014.1.12 PM转来的）？并且要添加上验证人、验证结果两列？" 
              "12. 对于Y321 DTV定制，modeom的代码，确认是否merge的是dtv_mpv1这个分支\n（注意：Y320和Y321的是两个分支，不要搞混,Y320定制此项可不做检查）？" 
              "13. 是否有检查projectconfig_ckt.mk中的CKT_ADVANCE_FACTORY_CHECK 字段\n（注意：yes表示有锁网，no表示没有锁网功能. 特别注意：=与yes/no之间不可以有空格！！！！！）？" 
              "14. 是否有检查GMS包的预置情况？要求预置最新提供的GMS包，2013.12.30起必须包含drive.apk应用，三个跟网络自适配的GMS包，不用从代码里面删除？" 
              "15. PRI需求中的GMS包sheet页，这个里面标注no的GMS包，确认删除了没有？" 
              "16. 软件发布通知单里面，SIMLOCK是否支持AT命令解锁这一栏，填写no？" 
              "17. 软件发布通知单里面，软件文件说明一栏的每个文件的名字，是否跟实际的软件包里面的文件名字一致？" 
              "18. 锁定外部版本号的定制，检查锁定完全没有（要锁定三个地方）？" 
              "19. 软件发布包里面，文件夹名称不可出现中文，检查了没有？" 
              "20. 定制软件，如果对语言有定制，检查华为输入法里面多余的语言包删除没有？检查修改了华为输入法的属性文件hwime.properties没有？" 
              "21. PRI中关于如果有日历是从周几开始的定制需要注意，此项需求，默认是跟语言相关的，检查各个语言下的显示没有？" 
              "22. release notes的封面栏检查没有？版本号对不对？" 
              "23. 号码匹配的改动文件检查没有（需要修改两个文件，一个java文件，一个cpp文件。）？" 
              "24. DTV定制的发布文档，SD卡升级说明文件更新到12.9邮件要求的文档没有（Y320定制不做此项检查）？" 
              "25. PRI中的日期格式连接符，如：dd-mm-yyyy中的‘-’是跟语言相关的，每个语种下都修改了没有？" 
              "26. PRI中的GMS包描述中，如果magazine这个是NO，请跟PM确认（如果不需要，请务必在代码里面彻底删除这个apk，务必删除！），确认是否不需要预置这个apk？" 
              "27. 编完版本后，重点检查一下情景模式铃音设置的字串：单卡版本不可出现sim1的字样，双卡版本必须有sim1、sim2之分.这一项检查没有？" 
              "28. 天气时钟apk里面预置的四个中国城市，删除没有（删除方法请参照余杰邮件说明）？" 
              "29. 默认语言自适配，这个用小白卡插入验证了没有（是否默认语言能够适配成功，需要修改mcctable.jave文件，可以用小白卡验证此需求）？" 
              "30. 默认LCD亮屏时间，PRI有没有特殊定制？如果有，检查CktPoweroffService.java这里修改成PRI的设定值没有？")

for i in "${ARRY_COMFIRM[@]}"; do 
    echo -e "\033[33m $i \033[0m"
    
    unset TMP_CONFIRM
    unset CONFIRM
    
    read -e -p " If you do so[yes/no/NA]? :" -i "yes" TMP_CONFIRM
    CONFIRM=`echo $TMP_CONFIRM |tr '[:upper:]' '[:lower:]'`

    if [ "$CONFIRM" = 'yes' ] || [ "$CONFIRM" = "na" ];then
        echo -e "\033[36m You said $CONFIRM, the checking will continue!\n \033[0m"
    else
        echo -e "\033[31m May you forget do this confirm, the tools will exit!\n \033[0m"
        exit
    fi
    
done

echo "以下3项请编译完版本务必检查!!!"
ARRY_COMFIRM_AFTER=("1. HOTA升级包，正向、反向验证，是否都是采用的USB下载方式进行的？" 
                    "2. 软件版本的hota包的中间文件，有没有上传ftp备份（务必上传备份！）？" 
                    "3. HOTA说明文件检查没有（1、设备名称：HUAWEI（缺少空格！）Y320-U10 ，这里要有空格！！！）？")

for i in "${ARRY_COMFIRM_AFTER[@]}"; do
    echo -e "\033[31m $i \033[0m"   
done
echo -e "\n"
