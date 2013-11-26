ckt_version_release
===================
工具名称：CKT VERSION RELEAS
当前版本：beta-v1.0.1
作    者：何培江 姚之林
发布时间：2013年9月9日
===========================================================================
使用说明：
    一、工具下载
       在任意目录（建议为当前用户的Home目录）下使用git check出本工具，命令：git clone https://github.com/hpj831112/ckt_version_release.git。如果命令执行不成功，可以多试几次，直到成功下载本工具，然后进入到项目目录：ckt_version_release进行代码更新
	
    二、目录结构说明
       1、config.conf为本工具的配置项保存文件，用户可以按需进行配置
       2、data目录下存放的是用于生成华为专用升级文件的模板文件，请不要轻易改动
       3、README.md文件，即是本文件
       4、version_release.sh主程序文件
       5、vr_register.sh注册文件
    
    三、按需修改配置项
        配置文件config.conf中有相关配置项的配置说明，请按需进行配置	
    
    四、注册主程序到系统命令
       在项目目录下运行注册程序：./vr_register.sh
       如用户不需要注册此程序到系统命令，稍后的使用中也可以在需要编译打包或仅打包的项目目录下，直接调用version_release.sh脚本。如果用户一经注册，则可以像调用系统命令一样调用本命令，命令为：ckt_release，建议优先运行注册程序 
    
    五、命令参数说明
       1、不带任何options
	  工具会显示系统Menu，用户可以根据Menu的指引完成版本发布
       2、带有超级打包参数[-x]
	  此时本工具会帮助用户完成除版本编译以外的其余全部工作
       3、全部参数说明如下
	   -p: 项目名,如：ckt_we_jb3
	   
	   -t: 目标版本，如：user/eng
	   
	   -v: 外部版本，如：B211
	   
	   -i：内部版本，如：B212
	   
	   -m：编译版本参数，如：ckt_release -m，这样的话，工具仅会编译当前版本而不会做任何其他的事情
	   
	   -z：功能如[-x]，不过此时需要完整参数
	   
	   -o: 做差分包需要的以前版本的OTA中间文件文件zip包，如：u10_b211_user.zip。
	   
	   -l：做差分包需要的以前版本的OTA中间文件文件的版本号。如：u10_b211_user.zip的版本号为B211，为[default/d/dflt]时系统会默认与当前版本的前一个版本做差分，不为default时，必须输入上一个版本的版本号，如：B211，否则结果可能与你想象的不同
	   
	   -n：不做差分包参数，如：ckt_release -x -n，这样的参数形式的话，系统只会帮助用户完成将编译出来的版本进行打包而不会做差分包以及华为特有的差分包
	   
	   -x: 超级打包参数
	   
	   -w: 不生成华为特有差分包的参数，如：ckt_release -x -l d -o u10_b211_user.zip -w，如果这样调用则系统就不会帮助用户生成华为特定的升级包
	   
	   -R：将原英文目录改成版本发布时所需的中文目录名称。请慎用此参数，仅在系统的shell支持中文的情况此参数才能起作用
	   
	   -I：针对外部已经锁定的情况下，定制版一般只变更内部版本号，此参数用以实现最终生成的package中的版本号以内部版本号为基准，如：外部版本号为B212，内部版本号为B214，如果需要最终打包生成的package中的version以内部版本号为准，即是B214，则打包的时候需要增加参数[-I],示例：ckt_release -x -l d -o u10_b211_user.zip -I
	   
	   -B：开启FTP上传备份文件功能，慎用此参数。如果一旦option中包含[-B]参数时，工具会帮助用户上传需要在FTP服务器上备份的中间文件，如：ckt_release -x -l d -o u10_b211_user.zip -B
	   
	   -E：编译ENG 的bootimg，由于目前定制不要求编译ENG版本，但是需要添加ENG 的bootimg，所以此参数专为需求添加
	   
	   -P：是否将基线软件特殊处理，我们目前软件包文件夹命名中一般都带有客户编码，但是基线版本却不携带客户编码，如果编译基线版本的时候，添加此参数的话，版本包中也将携带基线的客户编码，我们的设定为“C00”，如果不为"C00"的话，用户可以更改config.conf中配置项BASE_CUSTOM_COD的值
	   
	   -L：备份软件包到本地。这个参数为实现将ubuntu中已经编译好的软件包copy到windows下备份的功能，从而达到不用开ubuntu也能完成版本发布的功能
	   
	   -K：锁定外部版本号，如果定制中已经锁定了版本号，此参数将把所有版本号锁定为锁定的外部版本号
	   
	   -X：demo版本中提取USB update software的参数，这个参数可以用来提取已经编译成功的版本中的USB update software

       -D：如果所有项均保持默认设置，这个参数可以帮助用户减少很多输入	   

	   -?：显示帮助信息

    六、简单使用例子
	1、使用本工具完成版本编译工作
	   ckt_release -m
	2、使用本工具编译并打包版本且不做差分包
	   ckt_release -n
	3、使用本工具打包且不做差分包
	   ckt_release -x -n
	4、使用本工具完成编译以外的全部版本发布工作
	    ckt_release -x -l d -o u10_b211_user.zip
	5、使用本工具编译版本并当前版本的前一版本对比生成差分包
	   命令：ckt_release -l d
	   之后根据提示输入相应的信息则可以完成整套流程
	6、如果版本已经编译完成，则可以使用以下命令完成除编译版本以外的其余所有工作
	   命令：ckt_release -x -l d 或ckt_release -l d -x
		  
	7、如果不想使用工具菜单进行引导，用户也可以输入完整参数，如：
	   ckt_release -p ckt72_we_jb3 -t user -v B212 -i B212 -o u10_b211_user.zip -l B211
	
    七、使用建议
	1、关于生成差分包时需要对比的上一版本的中间文件：
	   本工具中集成了FTP下载的功能，如果最终文件存放目录下没有包含[-o] option所指定的对比文件时，工具会自动在FTP服务器上下载该文件，考虑网络相关因素，所以建议手动拷贝
	2、关于[-o]、[-l]、[-B]
	   [-o]option 指的是做差分包需要的以前版本的OTA中间文件文件zip包，此项的目的以及原因在于OTA中间文件的取名因具体项目不同而不同，故为了规避由此带来的风险，所以采用用户输入的方式确保该文件的唯一性以及正确性
	   [-l]option
	   同[-o]option一致，也是确保版本号的唯一以及正确性而设立的，所以建议用户填写此项时多加留意
	   [-B]option
	   此参数可以帮助用户自动将中间文件备份到FTP服务器，由于网络原因，请慎用此参数
	3、关于增强参数[-n] [-w] [-R] [-I] [-B]
	   所谓增强参数即是为了增强工具的某一方面的功能而设置的，这几个增强参数的功能主要用以实现用户某一方面的特定要求.
	   [-n]用以帮助部分用户仅希望使用本工具完成编译工作，而不希望生成差分包以及华为特定OTA升级包的情况
	   [-w]用以不生成华为特定OTA升级包的情况，
	   [-R]如果用户的shell环境支持中文的情况下，此参数用以将生成的文件夹重命名为中文目录名，这样可以省略掉手动命名的繁琐细节
	   [-I]针对已经拿TA的外部版本号已经锁定的情况，此参数会帮助用户在生成的最终的文件夹中使用内部版本号作为文件夹名称中的版本号
	   [-B]此参数用以帮助用户将需要备份到FTP的package上传到FTP service，不过由于网络原因，使用此参数时需要谨慎
	4、关于版本号
	   工具中也同时提供了帮助用户修改内部以及外部版本号的功能，触发条件为用户输入的内、外部版本号与当前的内、外部版本号不一致。但是由于一般修改均会提交服务器，故建议用户手动修改版本以确保与服务器同步
	5、关于软件发布文档
	   如果用户在config.conf配置文件中配置了DOC_SAVE_DIR并在该目录下准备好了相应文档的话，工具会将文档copy到软件发布时的相应目录下，使用该功能时需要注意DOC文档存放目录命名需要遵循一定规范，规范为"设备名_客户代码_DOC"，如：Y320-U151_C482_DOC, 如果为基线，则需要客户代码，即是"设备名_DOC"，如：Y320-U151_DOC
	5、垃圾清理
	   本工具默认将上一次编译产生的所有额外文件认定为垃圾文件，再一次编译版本的时候，系统会自动帮助用户清理，如果想要保留上一次编译生成的部分文件，建议先备份

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+                         部分新功能同步更新 2013.11.21                         +
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
一、关于demo版提取usb update software
    目前新增加参数用以实现此功能，可以通过命令：ckt_release -X 进行提取（前提是版本已经new成功或使用本工具编译成功）
	
二、关于DOC文档的自动集成
    要使用该功能必须完成以下两步：
	1、修改config.conf中DOC_SAVE_DIR配置项的值为local machine（ubuntu）上DOC文档的真实保存目录
	2、在local machine（ubuntu）上DOC文档的真实保存目录中已经添加相应的文档文件夹，且目录名必须按照“设备名_客户编码_DOC”的形式命名，如：Y320-U151_C482_DOC
	
三、关于README.TXT中内容需要修改的部分
    README.txt中大部分内容已经自动完成，但是需要我们手动修改如下两项内容
	1、版本HOTA测试目的，一般为内部验证
	2、此HOTA升级是否针对user版本，一般选是
	
四、关于默认参数的配置
    针对很多参数默认是必须配置的，我们在config.conf中也提供了默认参数项的配置项，具体如下：
	配置项为：ARRY_DEFAUIT_OPTIONS
	参数值设置：括号中每个默认参数之间以空格分开，如：(I E K)，这样就的话命令在执行的时候，就会自动帮用户添加-I -E -K参数，即：执行ckt_release 就会如同执行ckt_release -I -E -K效果一样

五、新版本中还提供将编译好的版本打包上传到指定FTP服务器的功能（一般用于紧急情况下，FTP服务器为本地window电脑），此功能由参数[-L]，开启
    要使用此功能一般需要如下3步：
	1、配置本地window为FTP服务器，详细配置步骤可以问度娘
	2、修改config.conf中##FTP control配置模块下local的各配置项
	3、使用工具的时候增加[-L]参数或者配置[-L]参数为默认参数
	
六、关于参数[-K]的说明：
    这个参数时针对外部版本号已经锁定的定制版本设定的，如果定制中外部版号本已经锁定的话，用户可以在使用工具的时候增加这个参数	

	
=================================================================================
信息反馈
    如果使用中出现任何异常或有新的变更，请及时联系我们
