#!/bin/bash

# 检测是否有硬盘需要挂载
disks=$(lsblk -nr | grep -v -e "boot" -e $(df -h | awk '{print $1}' | tail -n +2) | awk '{print $1}')
if [ -z "$disks" ]; then
  echo "没有可挂载的硬盘！"
  exit 1
else
  echo "可挂载硬盘列表:"
  echo "$disks"
fi

# 提示用户输入挂载目录
read -p "请输入挂载目录: " mountpoint
if [ -z "$mountpoint" ]; then
  echo "挂载目录不能为空！"
  exit 1
else
  mkdir -p "$mountpoint"
  echo "挂载目录为: $mountpoint"
fi

# 挂载硬盘
for disk in $disks; do
  echo "正在挂载硬盘 $disk 到 $mountpoint/$disk ..."
  mount "/dev/$disk" "$mountpoint/$disk"
  if [ $? -eq 0 ]; then
    echo "硬盘 $disk 挂载成功！"
  else
    echo "硬盘 $disk 挂载失败！"
    exit 1
  fi
done

# 检测是否成功挂载
read -p "是否需要检测硬盘是否成功挂载？(y/n): " check
if [ "$check" = "y" ]; then
  for disk in $disks; do
    if ! mountpoint -q "$mountpoint/$disk"; then
      echo "硬盘 $disk 挂载失败！"
      exit 1
    else
      echo "硬盘 $disk 成功挂载到 $mountpoint/$disk"
    fi
  done
elif [ "$check" = "n" ]; then
  echo "检测跳过，继续执行后面操作"
else
  echo "无效输入，检测跳过，继续执行后面操作"
fi

# 其他操作
echo "其他操作..."
