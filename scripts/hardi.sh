#!/bin/bash
#functions

echo_o(){
	if [[ -z "$2" ]]; then
		LOG="log"
	else
		LOG="$2"
	fi
	echo -e $1 | tee -a $LOG
}

cpy_cycle(){
	echo -e -n $2
	while read -r line ; do
		screen -S "$1" -X stuff "echo $line >> $2"`echo -ne '\015'`
		sleep 0.1
	done < "$2"
}

# for i in $(cat led3.ko.txt) ; do printf "\x$i" ; done > mylrz
#not working
cpy_file(){
	uuencode $2 $2.txt > $2.txt
	screen -S "$1" -X stuff "echo -n -e '$(cat $2.txt)' > /mnt/$2.txt"`echo -ne '\015'`
	screen -S "$1" -X stuff "uudecode -o /mnt/$2 /mnt/$2.txt"`echo -ne '\015'`
	screen -S "$1" -X stuff "rm /mnt/$2.txt"`echo -ne '\015'`
}


is_connected(){
	echo -e "Check if SD card is connected"
	SD_LABEL=$(find /dev/disk/by-label/ -name ZED_BOOT)
	SD_LOC=$(df -T "$SD_LABEL" | awk '{ print $7 }' | tail -n 1)
	echo -e $SD_LABEL
	while : ; do
		if [[ ! -L "$SD_LABEL" || "$SD_LOC" != *"ZED"* ]]; then
			echo -e "Mount the ZED Board SD card and press enter"
			echo -e "If you want to cancel press ctrl+c"
			read -r
			SD_LABEL=$(find /dev/disk/by-label/ -name ZED_BOOT)
			SD_LOC=$(df -T "$SD_LABEL" | awk '{ print $7 }' | tail -n 1)
		else
			break
		fi
	done
}

task_mesg()
{
	if [[ -z "$2" ]]; then
		DURATION="5"
	else
		DURATION="$2"
	fi
	echo -e $1 | xmessage -center -timeout "$DURATION" -file -
}

check_digilent_link(){
	if [ "ln -A $1" ]; then
		if [[ "$(id -u -n)" == "hartz" ]]; then
			ln -s /media/Data/digilent "$1"
		else
			ln -s /cad/digilent "$1"
		fi
	fi
}

rm_digilent_link(){
	rm "$1"
}

#konsole -e screen -S foo && cd $(pwd)

check_dir(){
	if [[ ! -d "$1" ]]; then
		mkdir -p $1
	fi
}


screen_cmd(){
	screen -S "$1" -X stuff "$2"`echo -ne '\015'`
}

test_seq(){
	screen_cmd zed 'picocom -b 115200 /dev/ttyACM1'
}

run_stuff(){
	konsole -e screen -S zed

	sleep 0.5
	screen -S zed -X stuff 'source lab1_functions && test_thread'`echo -ne '\015'`
	sleep 6

	# while : ; do
	# 	var="$(tail -2 screenlog.0)"
	# 	echo "$var"
	# 	screen_cmd zed 'echo -e $var'
	# 	if [[ $var == *"Terminal ready"* || $var == *"rcS Complete"* ]]; then
	# 		ZED_TEST
	# 	else
	# 		screen_cmd zed 'echo -e FUCK' &
	# 	fi
	# 	sleep 2
	# done
	#screen -S zed -X kill
	while : ; do
		if [[ ! -z $(screen -list | grep ZED2) ]]; then
			sleep 1
		else
			screen -S zed -X kill
			break
		fi
	done
}

ZED_TEST1(){
	screen_cmd $1 ' '
	screen_cmd $1 'echo -e "PERSE"'
	screen_cmd $1 'ls'
	screen_cmd $1 'echo -e "Checking kernel version"'
	screen_cmd $1 'uname -a'
	screen_cmd $1 "$(TASK1)"
}

ZED_TEST2(){
	screen_cmd $1 ' '
	screen_cmd $1 'uname -r'
	screen_cmd $1 'ls'
	screen_cmd $1 'insmod hello.ko'
	screen_cmd $1 'rmmod hello'
	screen_cmd $1 'dmesg'
	screen_cmd $1 'dmesg | grep hello'
	screen_cmd $1 'cat /var/log/messages'

	screen_cmd $1 'insmod hello.ko name="kernel"'
	screen_cmd $1 'rmmod hello'
	screen_cmd $1 'dmesg | grep hello'

}

test_thread(){
	read -r -t 5 -p "Do you want to test if the implementation works? [ (Y)es or (n)o ]" TEST_Q
	echo $TEST_Q
	if [[ $TEST_Q =~ [Yy](es)* || -z $TEST_Q ]]; then
		konsole -e screen -L -S "$1"
		while : ; do
			ZEDBOARD_Status="$(ls -ltf /dev/ttyACM*)"
			echo $ZEDBOARD_Status
			if [[ -z $ZEDBOARD_Status ]]; then
				read -r -p "Connect Zedboard UART to PC, swich the board ON and press enter"
			else
				sleep 0.5
				screen_cmd "$1" "picocom -b 115200 $ZEDBOARD_Status"
				read -r -p "Wait Zedboard to boot up"
				# read -r -p "Connect Zedboard UART to PC, swich the board ON and press enter"
				$(echo $1 | awk '{print toupper($0)}') "$1"
				read -r -p "To close window press enter"
				screen -S "$1" -X kill
				break
			fi
		done
	else
		exit 1
	fi
}

ini_test(){
	ZED_SES="zed_$1"
	echo -e "$ZED_SES" #DEBUG
	read
	konsole -e screen -S "$1"
	sleep 0.5
	screen -S "$1" -X stuff '$2/source/lab1_functions && test_thread $ZED_SES'`echo -ne '\015'`
	sleep 6

	while : ; do
		if [[ ! -z $(screen -list | grep $ZED_SES) ]]; then
			sleep 1
		else
			screen -S zed -X kill
			break
		fi
	done
}

TASK1() {
cat <<"EOT"

 #######    #     #####  #    #      #
    #      # #   #     # #   #      ##
    #     #   #  #       #  #      # #
    #    #     #  #####  ###         #
    #    #######       # #  #        #
    #    #     # #     # #   #       #
    #    #     #  #####  #    #    #####

EOT
}

TASK2() {
cat <<"EOT"

d888888b  .d8b.  .d8888. db   dD      .d888b.
`~~88~~' d8' `8b 88'  YP 88 ,8P'      VP  `8D
   88    88ooo88 `8bo.   88,8P           odD'
   88    88~~~88   `Y8b. 88`8b         .88'
   88    88   88 db   8D 88 `88.      j88.
   YP    YP   YP `8888Y' YP   YD      888888D


EOT
}

TASK3() {
cat <<"EOT"

████████╗ █████╗ ███████╗██╗  ██╗    ██████╗
╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝    ╚════██╗
   ██║   ███████║███████╗█████╔╝      █████╔╝
   ██║   ██╔══██║╚════██║██╔═██╗      ╚═══██╗
   ██║   ██║  ██║███████║██║  ██╗    ██████╔╝
   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═════╝


EOT
}

# SHELLY=$(ps $$ | awk '{ print $5 }' | tail -n 1)
# if [[ $PATH != *"/cad/x_15/SDK/2015.1/gnu/arm/lin/bin"* ]]; then
# 	if [[ "$SHELLY" == *"bash"* ]]; then
# 		export PATH=$PATH:/cad/x_15/SDK/2015.1/gnu/arm/lin/bin
# 	elif [[ "$SHELLY" == *"tcsh"* ]]; then
# 		setenv PATH ${PATH}:/cad/x_15/SDK/2015.1/gnu/arm/lin/bin
# 	fi
# fi
