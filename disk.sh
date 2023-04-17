#!/bin/bash

# 检测操作系统类型  
if grep -qi ubuntu /etc/issue; then
    OS_TYPE=Ubuntu
    DISK_PATH=/dev/  
elif grep -qi debian /etc/issue; then
    OS_TYPE=Debian
    DISK_PATH=/dev/      
elif grep -qi centos /etc/redhat-release; then
    OS_TYPE=CentOS
    DISK_PATH=/dev/   
fi

# 检测是否有可用硬盘
AVAILABLE_DISKS=$(blkid -o list | awk '{print $1}' | grep -v NAME)  
if [[ -z $AVAILABLE_DISKS ]]; then
    echo "没有找到可用的硬盘。退出脚本......"
    exit  
fi   

# 获取输入的挂载目录  
read -p "请输入挂载目录: " MOUNT_POINT  

# 遍历可用硬盘
for disk in $AVAILABLE_DISKS    
do
    echo "正在挂载 $disk 到 ${MOUNT_POINT}......"
    if [[ $OS_TYPE == Ubuntu ]] || [[ $OS_TYPE == Debian ]]; then   
        mkdir -p ${MOUNT_POINT}
    elif [[ $OS_TYPE == CentOS ]]; then   
        mkdir ${MOUNT_POINT}
    fi
    mount ${DISK_PATH}${disk} ${MOUNT_POINT}
    echo "${DISK_PATH}${disk} 已挂载到 ${MOUNT_POINT}。"  
done                                      

# 是否检测挂载成功
read -p "是否检测挂载是否成功?[y/n] " TEST_MOUNT
if [[ $TEST_MOUNT == "n" ]]; then
    echo "跳过挂载检测......" 
elif [[ $TEST_MOUNT == "y" ]]; then
    if mountpoint -q ${MOUNT_POINT}; then     
        echo "挂载成功。"
    else
        echo "挂载失败。"   
    fi
fi

# 添加到fstab,开机自动挂载
if [[ $OS_TYPE == Ubuntu ]] || [[ $OS_TYPE == Debian ]]; then 
    FSTAB_FILE=/etc/fstab
elif [[ $OS_TYPE == CentOS ]]; then
    FSTAB_FILE=/etc/fstab   
fi
echo "${DISK_PATH}${disk}  ${MOUNT_POINT}  auto  defaults  0  0" >> $FSTAB_FILE
echo "已添加到${FSTAB_FILE},开机将自动挂载。"
