#!/bin/bash
# 设置环境变量
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin  
export PATH  
echo "##############################################################" 
echo "#                                                           #"
echo "#              Linux自动挂载硬盘脚本 by主机玖玖                #"  
echo "#      脚本使用教程:https://www.zhuji999.com/17087.html     #"
echo "#                                                           #"  
echo "##############################################################"  
echo "#                                                           #"
echo "#     该脚本支持CentOS、Ubuntu和Debian系统                     #" 
echo "#     能自动检测硬盘并将硬盘挂载到用户指定目录                    #"
echo "#     挂载后添加至fstab实现开机自动挂载                         #"  
echo "#                                                           #"
echo "#     使用方法:                                              #"
echo "#     1. 赋予脚本执行权限: chmod +x disk.sh                   #"  
echo "#     2. 运行脚本: ./disk.sh                                 #"
echo "#     3. 选择要挂载的硬盘                                      #"
echo "#     4. 输入要挂载的目录                                     #"  
echo "#     5. 选择是否检测挂载结果                                 #"
echo "#                                                           #"
echo "##############################################################"

# 检测是否有硬盘可以挂载  
disk_info=`fdisk -l | grep '^磁盘'`
if [ -z "$disk_info" ]; then
    echo "没有可以挂载的硬盘!"
    exit 0
fi 

# 获取输入的挂载目录
read -p "请输入挂载目录: " mount_point  
if [ -z "$mount_point" ]; then
    echo "挂载目录不能为空!"
    exit 1
fi

# 挂载硬盘 
fdisk() {
    for disk in `fdisk -l | awk '/^磁盘/{print $2}'`; do
        partition=`fdisk -l /dev/$disk | grep '^/dev/' | awk '{print $1}'`
        # 检测分区是否已挂载,如果已挂载提示并跳过
        mounted=`df -h | grep $partition`
        if [ ! -z "$mounted" ]; then
            echo "$partition 已挂载!"    
            continue
        fi  
        # 创建挂载点目录
        mkdir $mount_point
        # 添加开机自动挂载信息
        echo "$partition $mount_point 自动 默认值 0 0" >> /etc/fstab
        # 挂载分区
        mount -a  
        # 检测是否挂载成功
        while true; do     
            read -p "检查挂载是否成功?(y/n) :" check
            if [ "$check" = "y" ]; then
                mounted_now=`df -h | grep $partition`
                if [ ! -z "$mounted_now" ]; then    
                    echo "$partition 挂载成功!"
                else
                    echo "挂载失败!"   
                    umount $mount_point
                    sed -i "/$partition/d" /etc/fstab
                fi
                break
            elif [ "$check" = "n" ]; then   
                break
            else
                echo "请输入 y 或 n!"
            fi
        done
    done
}

fdisk
