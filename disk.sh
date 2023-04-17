bash
#!/bin/bash

echo "##############################################################"  
echo "#                                                           #"  
echo "#      Linux自动挂载硬盘脚本 - 脚本美化与说明版         #"   
echo "#                                                           #"
echo "##############################################################"
echo "#                                                           #"     
echo "#     该脚本支持CentOS、Ubuntu和Debian系统               #"  
echo "#     能自动检测硬盘并将硬盘挂载到用户指定目录         #"   
echo "#     挂载后添加至fstab实现开机自动挂载                #"
echo "#                                                           #"   
echo "#     使用方法:                                          #"    
echo "#     1. 赋予脚本执行权限: chmod +x Linux_auto_disk.sh   #" 
echo "#     2. 运行脚本: ./Linux_auto_disk.sh                  #"    
echo "#     3. 选择要挂载的硬盘                                #"
echo "#     4. 输入要挂载的目录                                #"  
echo "#     5. 选择是否检测挂载结果                            #"   
echo "#                                                           #"    
echo "##############################################################"   

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

# 使用lsblk命令显示硬盘信息
lsblk  

# 检测是否有可用硬盘
read -p "请输入要挂载的硬盘: " DISK_NAME   

# 显示所选硬盘详细信息  
disk_info=$(lsblk /dev/${DISK_NAME})   
echo $disk_info

# 获取输入的挂载目录
read -p "请输入挂载目录: " MOUNT_POINT        

# 遍历可用硬盘  
echo "正在挂载 $DISK_NAME 到 ${MOUNT_POINT}......"
if [[ $OS_TYPE == Ubuntu ]] || [[ $OS_TYPE == Debian ]]; then             
    mkdir -p ${MOUNT_POINT}
elif [[ $OS_TYPE == CentOS ]]; then             
    mkdir ${MOUNT_POINT}  
fi
mount /dev/${DISK_NAME} ${MOUNT_POINT}
echo "/dev/${DISK_NAME} 已挂载到 ${MOUNT_POINT}。"        

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
echo "/dev/${DISK_NAME}  ${MOUNT_POINT}  auto  defaults  0  0" >> $FSTAB_FILE      
echo "已添加到${FSTAB_FILE},开机将自动挂载。"

