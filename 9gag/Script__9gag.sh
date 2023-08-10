#!/bin/bash


#si on rentre l'adresse mail a l'endroit du mail et qu'on lance le script on recevra les 10 premier gif de 9gag 



# On efface le dossier et les fichiers contenus
#Suprime le dossier
rm -rf 9gag_sh

# On créé un dossier dans le répertoire personnel et on se place dedans
mkdir 9gag_sh
cd 9gag_sh

# recupere les 10 premier lien des gif de 9gag et les met dans gif.txt
curl -s http://9gag.com/gif | sed -n '/data-image=.*/,/>/p' | cut -c68-127 |sed -e '2d;4d;6d;8d;10d;12d;14d;16d;18d;20d' > gif.txt

#compte le nombre de liens
nblien=$(cat gif.txt 2> /dev/null |wc -l)
echo "Il y a $nblien liens"

# télécharge les 10 premier gifs
let "url = 1"
let "max=11"
let "nblien=nblien+1"

while [ $url -ne $max ] && [ $url -ne $nblien ]
do
echo "$url"
temp=$(sed -n ''"${url////\/}"'p' gif.txt)
echo "$temp"
curl $temp > $url.gif
let "url=url+1"
done
 
#fonction qui permet l'envoi des mails
function envoiMail() { 
echo "Ci-joint 10 gifs 9gag !!" | mutt -s "Les gifs de 9gag" -a *.gif -- $emaill
echo " Envoie mail a $emaill"
}

#boite de dialogue qui demande si l'utilisateur veut recevoir des mails avec les gif de 9gag
function Gif() {
echo "Bienvenue sur les .gif du site 9gag"
echo "Voulez-vous recevoir les 10 derniers .gif du site 9gag tout les matins à 9heures ?"

continuer=true

while $continuer

do
read -p "Choisissez la réponse Y(yes) ou N(no)" reponse 
echo

if [ $reponse == "Y" ] || [ $reponse == "N" ]
then
continuer=false

else
echo "Ok"
fi

done

if [ $reponse == "Y" ]
then
read -p "Entrez votre email : " emaill
envoiMail

echo "Vous recevrez très bientot votre quotidienne des gif 9gag"
echo "Aurevoir"

elif [ $reponse == "N" ]
then 
echo "Aurevoir, et à bientot"

fi

}

Gif


exit
