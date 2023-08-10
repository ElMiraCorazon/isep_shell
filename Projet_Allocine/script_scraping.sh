#!/bin/bash

echo "" > final.txt

#get the data of allocine : titles and descriptions separetely
curl -s http://www.allocine.fr/film/aucinema/ | sed -n '/<a class=\"no_underline\".*/,/<\/a>/p'| sed 's/<[^>]*>//g' | sed '/^\s*$/d' > titres.txt
curl -s http://www.allocine.fr/film/aucinema/ | sed -n '/<p class=\"margin_5t\".*/,/<\/p>/p' | sed 's/<[^>]*>//g' | sed '/^\s*$/d' > descriptions.txt

#insert into the array each line not empty from the titles' file
{
IFS=$'\n' myTitres=( $(cat "titres.txt") )
}

#insert into the array_desc each line not empty from the descriptions' file
{
IFS=$'\n' myDescriptions=( $(cat "descriptions.txt") )
}

#Insert into the final file titles and descriptions with the good order
tLen=${#myTitres[@]}
echo $tLen
for (( i=0; i<${tLen}; i++ ));
do
 echo ${myTitres[$i]} >> final.txt
 echo ${myDescriptions[$i]} >> final.txt
 echo "\n" >> final.txt
done


cat mails.txt | while read line 
do 
if [ "$line" != "" ]; then
mail -s "News Allocine" $line > final.txt 
fi
done