#!/bin/bash

#We go to the directory where the trash is
cd ~/.local/share/

trash=0
trashFull=1
#Checking if Trash direcory exists
if [ -d "Trash/" ]; then
  
	#If trash directory exists, we go to "files" directory, where the files we want to delete will be.
  echo Directory Trash exists
  cd Trash/files
  
	#The minimal size of the sub-file "files" is 4ko
  sizeMin=4,0
  #The next command allow us to get the sub-file "files" size.
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
	#"files" size different from 4ko , trash contains some files
	else
    trash=1
		echo Trash contains some files
  fi
fi

if [ $trash = $trashFull ]; then
	  #checking that all the requested arguments to delete are given by the user
		#$1: pl(plus) or mi(minus); $2: size; $3: (ko, mo)
  if [ $1 ] && [ $2 ] && [ $3 ]; then
 	 	case $1 in
 	 		pl) find . -size +$2$3 -exec rm -rf {} + 1>> ~/log;;
 	 		mi) find . -size -$2$3 -exec rm -rf {} + 1>> ~/log;;
    esac
    echo Finish
  else
 	 	echo No Parameter
 	fi
fi

exit
