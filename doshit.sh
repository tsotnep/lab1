#how to use, example:
	#  bash doshit.sh led3.c
	#  bash doshit.sh led3

#what it does
	# export xilinx tool path
	# writes makefile with given argument name
	# executes makefile
	# opens new terminal and connects to zedboard
	# copies the *ko file through UART
	# installs module

#how to prepare
	# insert SD card into zedboard with basic files, BOOT.bin, devicetree.dts, zImage, ramdisk8m.image.gz
	# restart zedboard

#what apps you need : sudo apt-get install *
	# konsole
	# screen
	# sharutils # if i finished code and am using : uudecode, uuencode

	## very probably u already have those
	# xxd
	# sed

#TODO most important, fix line 127, this:
	#screen -S $PICOCOMTERMINAL -X stuff "for i in $(cat $FILENAME.ko.hex) ; do printf "\x$i" ; done > $FILENAME.uart.ko"`echo -ne '\015'`

#TODO deal with "sudo minicom" vs "minicom"

#computer depending variables
XILINXTOOLCHAIN=/opt/Xilinx/SDK/2015.2/gnu/arm/lin/bin/ #xilinx cross compile toolchain

# no need to change
CFILENAME=$1 #first argument
PICOCOMTERMINAL=T0 #terminal name which will open picocom for zedboard
# SDCARD=/media/tsotne/ZED_BOOT #location of sd card partition where we copy files, not used

##### add xilinx garbage to path
export PATH=$PATH:$XILINXTOOLCHAIN

##### extract argument name to be used for Makefile
#check if we gave the parameter led3.c OR led3
SIZE=${#CFILENAME} #length of FILENAMEing
if [[ $CFILENAME == *"."* ]]
then
	FILENAME=${CFILENAME:0:SIZE-2} #cut the whole FILENAMEing with '.' and select part 1 -> "$1 | cut -d "." -f 1"
else
	FILENAME=$CFILENAME
fi

###### create makefile
make clean
echo obj-m += $FILENAME.o > Makefile
echo CC='$(CROSS_COMPILE)'gcc >> Makefile
echo -e all: '\n\t'make -C ../linux-digilent/ M='$(PWD)' modules >> Makefile
echo -e '\t''$(CC)' test.c -o test >> Makefile
echo -e clean: '\n\t'make -C ../linux-digilent/ M='$(PWD)' clean >> Makefile
echo -e '\t'rm test >> Makefile


##### buld shits
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

# #### check if sd card is mounted
# while [ ! -d $SDCARD ]
# do
#     echo  -e "\t SD card not mounted, insert SD card into PC and press Enter!"
# 	read -r -p "\t if you want to skip this part enter: y " response
# 	response=${response,,}    # tolower
# 	if [[ $response =~ ^(yes|y)$ ]]
# 	then
# 		break;
# 	fi
#
# done

##### copy to sd card
# echo -e "\t $FILENAME.ko was copied into $SDCARD"
# cp -v $FILENAME.ko $SDCARD
# echo -e "\t list of files on $SDCARD"
# ls -l $SDCARD


#### open new terminal and start minicom
	#i wanted to write some scripts in <zynq> as well, i tried:
	#sleep, wait, read -p "press enter", echo -ne '\n' -- none of them worked
	#problem is, after picocom, it really neeeds you to press enter
# echo -e "\t if picocom is already open in another terminal, there will be error"
# gnome-terminal -e "bash -c \"
# echo -e '\t insert sd card into zedboard and type password for picocom' &&
# sudo picocom -b 115200 /dev/ttyACM0;
# exec bash\""

# echo -ne "\t checksum of $FILENAME.ko file is : \n"
# echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# md5sum $FILENAME.ko
# echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

##### open terminal
konsole -e screen -S $PICOCOMTERMINAL
sleep 0.5
screen -S $PICOCOMTERMINAL -X stuff 'echo hello'`echo -ne '\015'`
screen -S $PICOCOMTERMINAL -X stuff 'echo if picocom is already open in another terminal, there will be error'`echo -ne '\015'`
screen -S $PICOCOMTERMINAL -X stuff 'picocom -b 115200 /dev/ttyACM0'`echo -ne '\015'`
sleep 1

#TODO if zedboard needs to be restarted, restart and wait


##### mount sd card in case it's not mounted
screen -S $PICOCOMTERMINAL -X stuff `echo -ne '\015'`
screen -S $PICOCOMTERMINAL -X stuff 'mount /dev/mmcblk0p1 /mnt'`echo -ne '\015'`
screen -S $PICOCOMTERMINAL -X stuff "cd /mnt"`echo -ne '\015'`
screen -S $PICOCOMTERMINAL -X stuff "touch $FILENAME.ko.hex"`echo -ne '\015'`
sleep 0.1

##### create text file out of $FILENAME.ko file
xxd -g1 $FILENAME.ko > $FILENAME.ko.hex
sed -i 's/^\(.\)\{9\}//g' $FILENAME.ko.hex
sed -i 's/\(.\)\{16\}$//g' $FILENAME.ko.hex
# sed $1.hex | tr -d " "

# send lines TODO it's working but copying is not pefect
echo -e -n $FILENAME.ko.hex
while read -r line ; do
  screen -S $PICOCOMTERMINAL -X stuff "echo $line >> $FILENAME.ko.hex"`echo -ne '\015'`
  sleep 0.1
done < "$FILENAME.ko.hex"
sleep 0.1

#reconstruction of file
screen -S $PICOCOMTERMINAL -X stuff "for i in $(cat $FILENAME.ko.hex) ; do printf "\x$i" ; done > $FILENAME.uart.ko"`echo -ne '\015'`

##### TODO finish this method of file copying
# uuencode $FILENAME.ko $FILENAME.coded #> $FILENAME.hex
# screen -S "$PICOCOMTERMINAL" -X stuff "echo -n -e `$(cat $FILENAME.coded)` > $FILENAME.coded"`echo -ne '\015'`
# screen -S "$PICOCOMTERMINAL" -X stuff "uudecode -o $FILENAME.ko $FILENAME.coded"`echo -ne '\015'`
# # screen -S "$PICOCOMTERMINAL" -X stuff "rm $FILENAME.txt"`echo -ne '\015'`
#
#
# sleep 0.5
# CHECKSUM=`md5sum $FILENAME.ko`
# screen -S $PICOCOMTERMINAL -X stuff "echo original checksum is:"`echo -ne '\015'`
# screen -S $PICOCOMTERMINAL -X stuff `echo -ne '\015'`
# screen -S $PICOCOMTERMINAL -X stuff "echo '$CHECKSUM'"`echo -ne '\015'`
# screen -S $PICOCOMTERMINAL -X stuff `echo -ne '\015'`
# sleep 0.1
# screen -S $PICOCOMTERMINAL -X stuff `echo -ne '\015'`
# screen -S $PICOCOMTERMINAL -X stuff "md5sum $FILENAME.ko"`echo -ne '\015'`
# # screen -S $PICOCOMTERMINAL -X stuff `echo -ne '\015'`
# sleep 0.01
# screen -S $PICOCOMTERMINAL -X stuff `ls -l`
# screen -S $PICOCOMTERMINAL -X stuff "rmmod $FILENAME"`echo -ne '\015'`
# screen -S $PICOCOMTERMINAL -X stuff "insmod $FILENAME.ko"`echo -ne '\015'`

echo
echo
echo
##### closing down the opened terminal
read -p "screen -S $PICOCOMTERMINAL -X kill || or || y " resp
if [[ $resp == "y" ]]; then
	screen -S $PICOCOMTERMINAL -X kill
fi
