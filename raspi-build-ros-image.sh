#!/bin/sh -ex

FILE=ubuntu-16.04.2-preinstalled-server-armhf+raspi2

# download and decompress the official ubuntu image
if [ ! -e ${FILE}.img ]; then
    # get ubuntu official image for Raspberry Pi 2
    wget -c http://cdimage.ubuntu.com/ubuntu/releases/16.04/release/${FILE}.img.xz
    # decompress
    unxz -f ${FILE}.img.xz
fi

# enlarge the image file for additional install
#dd if=/dev/zero bs=1000000 count=2000 >> ${FILE}.img

# enlarge the partition
#echo "d
#2
#n
#p
#2
#270336
#
#w
#"|fdisk ${FILE}.img

# mount root image file on r
mkdir -p r
mount -o loop,offset=`expr 270336 \* 512` ${FILE}.img r

# expand filesystem size
resize2fs /dev/loop0

# Mount required filesystems
mount -t proc none r/proc
mount -t sysfs none r/sys
mount -t tmpfs none r/run

# mount firmware image on r/boot/firmware
#mount -o loop,offset=`expr 8192 \* 512` ${FILE}.img r/boot/firmware

# cp qemu-arm-static to image
cp -p /usr/bin/qemu-arm-static r/usr/bin

# remove symbolic link of resolv.conf
chroot r rm -f /etc/resolv.conf

# set nameserver
echo nameserver 8.8.8.8 > r/etc/resolv.conf

# set hostname
# echo "127.0.1.1 ubuntu" >> r/etc/hosts

cp -p install_roomblock.sh r/tmp/
chroot r sh /tmp/install_roomblock.sh

# restore the symlink to /etc/resolv.conf
chroot r ln -sf /run/resolvconf/resolv.conf /etc/resolv.conf

# unmount the image
sync
umount -l r/proc
umount -l r/sys
umount -l r/run
umount r

# rename the image file
# mv ${FILE}.img raspi2-ros-kinetic.img
