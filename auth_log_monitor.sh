#!/bin/bash


## The purpose of this project is to monitor the auth.log file, filter out the failed logins into a file and and in essence 
## create a history file for failed logins with their information

### starting simple

# 1 - create a loop that read the auth.log file each time its being updated
# 2 - record all the Failed attempts: - create a folder for each unique IP being recorded, in the folder name mention the IP address, user that was being accessed, and service
#								      - in the folder create a log file containing all the attempts from said IP  



current_line=1

# creating a folder if it doesnt exist
[ -d auth_log_stalker ] || mkdir auth_log_stalker 2> /dev/null


function main_frame()
{

# direct all the lines from variable current_line to the current last line in auth.log into temp_event_lst.txt
		sed -n "${current_line},\$p" /var/log/auth.log | nl > .temp_event_list.txt

		# read the last line number from the temp file and add to it 1, so next time sed reads auth.log it starts from the line after
		current_line=$(( $(cat ./.temp_event_list.txt | tail -n 1 | cut -f 1) + 1 )) 

		# if the ip address read from the temp_event_list.txt does not appear under auth_log_stalker then make a folder with the ip as its name
		for ip in  $(cat ./.temp_event_list.txt | grep -i "failed password for" | egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}")
			do
				if [[ ! $( ls auth_log_stalker | grep "$ip") ]]
					then
						mkdir auth_log_stalker/$ip
				fi
			done

		#appending the information about the ip into a file
		for ip_info in $(ls -1 auth_log_stalker)
			do
				# TO BE EXPLAINED :(
				if [[ ! $(ls -1 auth_log_stalker/$ip_info | grep -o '[A-Z]'*) ]]
					then
						cat ./.temp_event_list.txt | grep $ip_info | grep -i "failed password for" | awk '{$1=""; print $0}' >> auth_log_stalker/$ip_info/$ip_info-information
						# seems like theres a duplication problem so this is a self explanatory temporary solution	
				 		cat auth_log_stalker/$ip_info/$ip_info-information | sort | uniq > auth_log_stalker/$ip_info/$ip_info-information.tmp
				 		mv auth_log_stalker/$ip_info/$ip_info-information.tmp auth_log_stalker/$ip_info/$ip_info-information

				 		country_name=$(curl -s ipinfo.io $ip_info | grep -i 'country' | awk '{print $2}' | grep -o '[a-zA-Z]*')
				 		#echo "this is the country 1 $country_name"
						new_file_name="$ip_info-information-$country_name"
						#echo "this is my new file name 1 $new_file_name"
						mv auth_log_stalker/$ip_info/$ip_info-information auth_log_stalker/$ip_info/$new_file_name #we already change the file name here so the lines in "else" can function properly
						#because the lines in else do the same work as here but with the changed file name

				 		# now that we have established a new file name that includes the country we skip on the above and work with the new filename
				 		# in order to avoid errors
					#else
					#	country_name=$(curl -s ipinfo.io $ip_info | grep -i 'country' | awk '{print $2}' | grep -o '[a-zA-Z]*')
				 	#	#echo "this is the country $country_name"
					#	new_file_name="$ip_info-information-$country_name"
						#echo "this is my new file name $new_file_name"
					#	cat ./.temp_event_list.txt | grep $ip_info | grep -i "failed password for" | awk '{$1=""; print $0}' >> auth_log_stalker/$ip_info/$new_file_name
						# seems like theres a duplication problem so this is a self explanatory temporary solution	
				 	#	cat auth_log_stalker/$ip_info/$new_file_name | sort | uniq > auth_log_stalker/$ip_info/$new_file_name.tmp
				 	#	mv auth_log_stalker/$ip_info/$new_file_name.tmp auth_log_stalker/$ip_info/$new_file_name
				fi


				

			done






		if [[ $current_line > $(cat /var/log/auth.log | wc -l) ]]
			then
				current_line=1
		fi

}





function everything_start()
{
# looping
while true
	do

		last_line_auth=$(cat /var/log/auth.log | wc -l)


		# here we only run the function if the number of lines in the file that was recorded a few seconds ago is not equal to the number of lines now, 
		# which means that the file was updated and we have a reason to run the function	
		if [[ $last_line_auth != $(cat /var/log/auth.log | wc -l) ]]
			then
				main_frame
		fi

		sleep 1


	done
}


# condition: can only run the script as root or someone in the sudo group
echo
me=$(whoami)

if [[ $me = root ]];then
	break
elif [[ -z $( id | grep "sudo") ]]; then
	echo "you are not operating as *root* or a member of the *sudo* group exiting now..."
	exit
fi




echo
read -p "Choose your option: 

1- Start

2- Stop

" answer

if [[ $answer == 1 || $answer == start || $answer == Start ]];
	then
		everything_start &
	elif [[ $answer == 2 || $answer == stop || $answer == Stop ]]; 
		then
			for task_id in $(pgrep -f "newproject.sh");
				do
					# Check if the process ID is not the current shell process (to avoid killing current script)
       				if [ $task_id != $$ ]; then
        		    kill $task_id
        		    	if [[ ! -z $(pgrep -f "newproject.sh") ]]; then	
        		    		echo
        		    		echo "Task killed"
        		    	fi
        			fi
			done
fi