# hexdump -e '16/1 "%02x " "\n"' $1 > $1.hex #to hexadecimal
#
#
#
# while read line
# do
#   echo -n -e $(tr -d '[:space:]' | sed 's/../\\x&/g') > $1.back.ko
# done < $1.hex
#
#
# hexdump -e '16/1 "%02x " "\n"' $1.back.ko > $1.back.hex #to hexadecimal
#
#
# md5sum $1 $1.back.ko
#
# read -p "y for diff -y on HEXes" resp
# if [[ $resp == "y" ]]; then
# 	diff -y $1.hex $1.back.hex
# fi

# cat $1.hex | echo -n -e $(tr -d '[:space:]' | sed 's/../\\x&/g') > $1.back.ko
# echo -n 5a | sed 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI' | xargs printf


xxd -g1 $1 > $1.hex

sed -i 's/^\(.\)\{9\}//g' $1.hex
sed -i 's/\(.\)\{16\}$//g' $1.hex

echo -e -n $1.hex
while read -r line ; do
  screen -S "$PICOCOMTERMINAL" -X stuff "echo $line >> $1.hex"`echo -ne '\015'`
  sleep 0.1
done < "$1.hex"

screen -S "$PICOCOMTERMINAL" -X stuff "for i in $(cat $1.hex) ; do printf "\x$i" ; done > $1.copied.ko"`echo -ne '\015'`
screen -S "$PICOCOMTERMINAL" -X stuff "rm $1.hex"`echo -ne '\015'`
