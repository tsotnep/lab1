echo -e "\t" "if minicom is already open in another terminal, there will be error"
gnome-terminal -e "bash -c \"
echo -e '"\t" insert sd card into zedboard and type password for picocom' && 
sudo picocom -b 115200 /dev/ttyACM0 &&
read -p 'press enter' \\& &&
wait %1
echo 'heyyy'
exec bash\""



# mount /dev/mmcblk0p1 /mnt && 
# cd /mnt && 
# insmod $FILENAME.ko && 