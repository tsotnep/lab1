#hexdump -e '16/1 "%02x " "\n"' $1 > $1.hex #to hexadecimal
xxd -r -ps $1 $1.ko #to binary
#hexdump -e '16/1 "%02x " "\n"' binaried_again > hexed_again
