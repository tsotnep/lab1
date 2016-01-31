# cat everySecondScript.sh
#!/bin/bash
# every time, reads GPIO SWITCH inputs and writes into GPIO LED outputs
while true
do
        for VAR in 0 1 2 3 4 5 6 7
        do
                cat /sys/class/gpio/gpio$((69+$VAR))/value > /sys/class/gpio/gpio$((61+$VAR))/value
        done

        sleep 0.001
done
