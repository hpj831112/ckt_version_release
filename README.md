ckt_version_release
===================
软件名称：CKT VERSION RELEAS
当前版本：beta-v1.0.1
作    者：何培江 赵丹 姚之林
发布时间：2013年9月9日
===========================================================================
使用说明：
    一、软件下载
	    在任意目录（建议为当前用户的Home目录）下使用git check出本软件，命令：git clone https://github.com/hpj831112/ckt_version_release.git。如果命令执行不成功，可以多试几次，直到成功下载本软件，然后进入到项目目录：ckt_version_release进行代码更新
	
	二、目录结构说明
	    1、config.conf为本软件的配置项保存文件，用户可以按需进行配置
		2、data目录下存放的是用于生成华为专用升级文件的模板文件，请不要轻易改动
		3、README.md文件，即是本文件
		4、version_release.sh主程序文件
		5、vr_register.sh注册文件
    
	三、按需修改配置项
        配置文件config.conf中有相关配置项的配置说明，请按需进行配置	
    
	四、注册主程序到系统命令
	    在项目目录下运行注册程序：./vr_register.sh
		如用户不需要注册此程序到系统命令，稍后的使用中也可以在需要编译打包或仅打包的项目目录下，直接调用version_release.sh脚本。如果用户一经注册，则可以想调用系统命令一样调用本命令，命令为：ckt_release，建议优先运行注册程序 
    
	五、命令参数说明
	    1、不带任何options
	       软件会显示系统Menu，用户可以根据Menu的指引完成版本发布
	    2、带有超级打包参数[-x]
		   此时本软件会帮助用户完成除版本编译以外的其余全部工作
		3、全部参数说明如下
		   -p: 项目名,如：ckt_we_jb3
		   -t: 目标版本，如：user/eng
		   -v: 外部版本，如：B211
		   -i：内部版本，如：B212
		   -z：功能如[-x]，不过此时需要完整参数
		   -o: 差分包需要对比的版本，如：u10_b211_user.zip。此项一般为当前版本的前一个版本
		   -l：需要对比差分的版本。为[default/d/dflt]时系统会默认与当前版本的前一个版本做差分，不为default时，必须输入上一个版本的版本号，如：B211，否则结果可能与你想象的不同
		   -x: 超级打包参数
		   -?：显示帮助信息
=================================================================================
信息反馈
    如果使用中出现任何异常或有新的变更，请及时联系我们
