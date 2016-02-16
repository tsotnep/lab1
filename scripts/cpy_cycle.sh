# cpy_cycle(){
# 	echo -e -n $2
# 	while read -r line ; do
# 		screen -S "$1" -X stuff "echo $line >> $2"`echo -ne '\015'`
# 		sleep 0.1
# 	done < "$2"
# }

# cpy_file(){
	uuencode $2 $2.txt > $2.txt
	screen -S "$1" -X stuff "echo -n -e '$(cat $2.txt)' > /mnt/$2.txt"`echo -ne '\015'`
	screen -S "$1" -X stuff "uudecode -o /mnt/$2 /mnt/$2.txt"`echo -ne '\015'`
	screen -S "$1" -X stuff "rm /mnt/$2.txt"`echo -ne '\015'`
# }