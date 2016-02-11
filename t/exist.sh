# if [ ! -d /media/tsotne/ZED_BOOT ]; then
#     echo "File not found!"
# fi

while [ ! -d /media/tsotne/ZED_BOOT ]
do
    read -p  "SD card not mounted, insert SD card into PC and press Enter!"
done