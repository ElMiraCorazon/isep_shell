#!/bin/bash

#Function
sizeChoice(){
	 read -p "Choose  (pl or mi) ->" first
        read -p "Choose size (example : 500 ) ->" second
        read -p "Choose weight (example : k for Ko) ->" third

                #Checking that all the requested arguments to delete are given by the user 
                #$1: pl(plus) ou mi(minus); $2: size; $3: (ko, mo)
                if [ $first ] && [ $second ] && [  $third ]; then
                        case $first in
                                pl)  sign=+;;
                                mi)  sign=-;;
                        esac
		echo "Execute "  $(date -d 'now')>>~/log
              find . -size $sign$second$third -exec rm -rfv {} + 1>>~/log     
echo Execute                
else
                        echo No Parameter
                fi  
};

timeChoice(){

 read -p "Delete files older than  (enter a number of days) ->" day

if [ $day ]; then

echo "Execute "  $(date -d 'now')>>~/log

find . -ctime $day -exec rm -rfv {} + 1>>~/log

else
	echo No Parameter
fi

};

#there is a problem with this function 
configCron(){

 read -p "Do you want to change de crontab?(o) or (n) ->" response
	case $response in
		o) crontab -l > crontab.tmp
			read -p "Configure the crontab : ->" crontab
#Configure the cron with the new value and make a  log file too			
echo "$crontab cd $PWD/ ; sh $PWD/scriptTrashNew.sh" >> crontab.tmp  > crontab.log 2>&1
			
			#Configure crontab	
			crontab crontab.tmp
			echo "Crontab configure";;
	esac
}

#main

#program the crontab but there is a problem i dont know what it is
#Must be here
#configCron

#We go to the directory where the trash is
cd ~/.local/share/

trash=0
trashFull=1
#Checking if Trash directory exists
if [ -d "Trash/" ]; then
  
	##If trash directory exists, we go to "files" directory,  where the files we want to delete will be.
  echo Directory Trash exists

  cd Trash/files
  
	#The minimal size of the sub-file "files" is 4ko
  sizeMin=4,0
  
	#The next command allow us to get the sub-file 'files' size.
  sizeFiles=$(du -h | grep . | sort -n | tail -n 1 | cut -d K -f 1)
  
	#Checking if there is no little file in "files", to be sure the trash is empty
  if [ $sizeFiles = $sizeMin ]; then
		findFile=`find . -type f`
    if [ "$findFile" = "" ]; then 
      echo Trash is empty
    else 
      trash=1
      echo Trash contains some files
    fi
	#files size different from 4ko, trash contains some files
	else
    trash=1
		echo Trash contains some files
  fi
else
echo Trash doesn t exist. Task is going to stop
fi


if [ $trash = $trashFull ]; then

read -p "Do you want to delete by size(s) or time (t)? ->" choice

case $choice in 
#delete by size
 s)   sizeChoice;;
#delete by  day
 t)  timeChoice;;
esac
fi




exit
