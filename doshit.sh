#how to use, example:
	# bash doshit.sh led3.c 
	# bash doshit.sh led3

#what it does
	# export xilinx tool path
	# writes makefile with given argument name
	# executes makefile
	# copies files into sd card
	# opens new terminal and connects to zedboard

#variables
SDCARD=/media/tsotne/ZED_BOOT #location of sd card partition where we copy files
XILINXTOOLCHAIN=/opt/Xilinx/SDK/2015.2/gnu/arm/lin/bin/ #xilinx cross compile toolchain
CFILENAME=$1 #first argument


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
echo obj-m += $FILENAME.o > Makefile
echo CC='$(CROSS_COMPILE)'gcc >> Makefile
echo -e all: '\n\t'make -C ../linux-digilent/ M='$(PWD)' modules >> Makefile
echo -e '\t''$(CC)' test.c -o test >> Makefile
echo -e clean: '\n\t'make -C ../linux-digilent/ M='$(PWD)' clean >> Makefile


##### buld shits
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

#### check if sd card is mounted
while [ ! -d $SDCARD ]
do
    read -p  "SD card not mounted, insert SD card into PC and press Enter!"
done

##### copy to sd card
echo -e "\t $FILENAME.ko was copied into $SDCARD"
cp -v $FILENAME.ko $SDCARD
echo -e "\t list of files on $SDCARD"
ls -l $SDCARD


#### open new terminal and start minicom
	#i wanted to write some scripts in <zynq> as well, i tried:
	#sleep, wait, read -p "press enter", echo -ne '\n' -- none of them worked
	#problem is, after picocom, it really neeeds you to press enter 
echo -e "\t if minicom is already open in another terminal, there will be error"
gnome-terminal -e "bash -c \"
echo -e '\t insert sd card into zedboard and type password for picocom' && 
sudo picocom -b 115200 /dev/ttyACM0; 
exec bash\""

#### if 'uname -r' does not contain 'digilent' then enter 'reset' and wait around 15 seconds until zedboard gets restarted

#### mount disk

#### install module
