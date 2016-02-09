###### create Makefile
echo obj-m += $1.o > Makefile
echo CC='$(CROSS_COMPILE)'gcc >> Makefile
echo -e all: '\n\t'make -C ../linux-digilent/ M='$(PWD)' modules >> Makefile
echo -e '\t''$(CC)' test.c -o test >> Makefile
echo -e clean: '\n\t'make -C ../linux-digilent/ M='$(PWD)' clean >> Makefile

##### buld shits
make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

##### copy to sd card
cp $1.ko /media/tsotne/ZED_BOOT

#### open new terminal and start minicom
gnome-terminal -e "bash -c \"
echo 'type pass for picocom' && 
sudo picocom -b 115200 /dev/ttyACM0 &&

; exec bash\""
#### if 'uname -r' does not contains 'digilent' then enter 'reset' 
#### and wait around 15 seconds until zedboard gets restarted

#### mount disk

#### install module
