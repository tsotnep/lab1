

# if [[ "$1" == *"."* ]]
# then
# 	STR = "$1" | cut -d '.' -f 1 #cut the whole string with '.' and select part 1
# else
# 	STR = "$1"
# fi
# echo $STR

echo "$1" 
STR=$1
echo $STR