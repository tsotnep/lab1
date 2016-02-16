screen -S zed -X stuff 'source lab1_functions && test_thread'`echo -ne '\015'`


echo now it will enter
read -p "y/n" resp
echo -ne '\015\n' 
echo -ne '\015\n'
echo -ne '\015\n'
echo -ne '\015\n'
echo -ne '\015\n'
echo -ne '\015\n' sleep 2
echo entered
	if [[ $resp == "y" ]]; then
		echo resp was y
	else
		screen -S zed -X kill
		echo resp was n
	fi