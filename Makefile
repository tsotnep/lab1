obj-m += led2.o
CC=$(CROSS_COMPILE)gcc
all: 
	make -C ../linux-digilent/ M=$(PWD) modules
	$(CC) test.c -o test
clean: 
	make -C ../linux-digilent/ M=$(PWD) clean
	rm test