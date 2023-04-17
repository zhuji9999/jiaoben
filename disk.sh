bash
#!/bin/bash

# 检测是否有可用硬盘  
AVAILABLE_DISKS=$(fdisk -l | awk '{print $2}' | grep -v 'Disk' | grep -v 'name' | grep -v '[0-9]*:')
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
    mkdir -p ${MOUNT_POINT}
    mount /dev/${disk} ${MOUNT_POINT}
    echo "/dev/${disk} 已挂载到 ${MOUNT_POINT}。"  
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
echo "/dev/${disk}  ${MOUNT_POINT}  auto  defaults  0  0" >> /etc/fstab
echo "已添加到fstab,开机将自动挂载。"
