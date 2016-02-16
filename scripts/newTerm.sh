konsole -e screen -S Tpico
sleep 0.5
screen -S Tpico -X stuff 'echo hello'`echo -ne '\015'`
screen -S Tpico -X stuff 'echo if picocom is already open in another terminal, there will be error'`echo -ne '\015'`
screen -S Tpico -X stuff 'echo insert sd card into zedboard and type password for picocom'`echo -ne '\015'`
screen -S Tpico -X stuff 'sudo picocom -b 115200 /dev/ttyACM0'`echo -ne '\015'`
screen -S Tpico -X stuff '2'`echo -ne '\015'`
sleep 1
### here i should add copying script

# screen -S Tpico -X stuff 'mount /dev/mmcblk0p1 /mnt'`echo -ne '\015'`
# screen -S Tpico -X stuff 'cd /mnt'`echo -ne '\015'`
screen -S Tpico -X stuff 'ls -l'`echo -ne '\015'`
screen -S Tpico -X stuff 'insmod $FILENAME.ko'`echo -ne '\015'`

# screen -S Tpico -X kill
