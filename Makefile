##### Goal definitions #####
# Goal definitions are the main part of the kbuild Makefile. These lines define the files to be built.
# Example: obj-y += foo.o
# This tells kbuild that there is one object named foo.o to be built. The .o file will be built beforehand from foo.c
# the 'm' in obj-m means that foo.o shall be built as a module in kernel
# m - module
# y - yes ( built-in to kernel )
obj-m += led2.o
 
# CC is a variable to specify the compiler to be used. By default it would be cc, but as we are cross-compiling
# we should specify another compiler for that. Therefore we can redefine it to take $CROSS_COMPILE variable into account which
# we will be specifying when running make. Example: make CROSS_COMPILE=arm-xilinx-linux-gnueabi-
# At this point it is only necessary for compiling the userspace program
CC=$(CROSS_COMPILE)gcc


##### Targets #####
# Targets specify what will be executed during the make 
all:
	make -C ../linux-digilent/ M=$(PWD) modules
	$(CC) test.c -o test # compile userspace program
 
clean:
	make -C ../linux-digilent/ M=$(PWD) clean
