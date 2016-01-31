##### Goal definitions #####
# Goal definitions are the main part of the kbuild Makefile. These lines define the files to be built.
# Example: obj-y += foo.o
# This tells kbuild that there is one object named foo.o to be built. The .o file will be built beforehand from foo.c
# the 'm' in obj-m means that foo.o shall be built as a module in kernel
# m - module
# y - yes ( built-in to kernel )
obj-m += hello.o
 
##### Targets #####
# Targets specify what will be executed during the make 
all:
	make -C ../linux-digilent/ M=$(PWD) modules
 
clean:
	make -C ../linux-digilent/ M=$(PWD) clean
