#!/bin/bash
# Auteurs : Hugo BOUTINON & Alexandre PAPP

# On affiche la bannière
cat <<"BANNER"                                                                                                              
         _\|/_
         (o o)
 +----oOO-{_}-OOo------------------------------+
  _                   _                 __      
 | | ___  __ _  _  _ (_) _ __  ___     / _| _ _ 
 | |/ -_)/ _` || || || || '_ \/ -_) _ |  _|| '_|
 |_|\___|\__, | \_,_||_|| .__/\___|(_)|_|  |_|  
            |_|         |_|                     
 |                                             |
 |                           By: Hugo & Alex   |
 +---------------------------------------------+

BANNER


function aide {
	echo -e -n "Ce script permet de récupérer les dernières actualités footballistiques sur le site de lequipe.fr \nLa recherche par mots clés permet de cibler une actualité"
	echo -e "Elle se limite à une recherche dans les URLs des différents articles, et non dans le contenu lui même, plusieurs mots peuvent être saisis en les séparant par un espace \n"
        echo -e "Utilisation : ./script.sh [-OPTS] [MOTS CLEFS...] \n"
}

function affiche {

# On efface le dossier et les fichiers contenus
rm -rf ~/equipe_sh/
# On créé un dossier dans le répertoire personnel et on se place dedans
mkdir ~/equipe_sh/ && cd ~/equipe_sh/

echo -n "Téléchargement de la page http://www.lequipe.fr/news.html... "

# On télécharge le code source qu'on enregistre dans un fichier page, sans afficher les opérations.
curl -s http://www.lequipe.fr/news.html > page

# Substitution permettant de compter le nombre de lignes du fichier page
nbligne=$(cat page 2> /dev/null |wc -l)

# On vérifie que le fichier contient quelque chose (que la page a été correctement téléchargée)
if [[ $nbligne != 0 ]]
	then sleep 1 ; echo "Terminé"
else
	sleep 1 ; echo "Echec"
fi

# On ne prend que les liens liés aux actualités, on ne garde que ce qu'il y'a à l'intérieur de "href", on élimine les doublons, et on garde les actus foot.
# On redirige la sortie standard pour enregistrer les résultats dans "liste_cleans"
grep -o ".*\/Actualites\/.*" page |grep -o -E 'href="([^"#]+)"' |cut -d'"' -f2 |grep ".*\/Football\/.*" |uniq > liste_cleans



if [[ $# == 0 ]] ; then
# On compte le nombre de liens présent dans "liste_cleans"
# Cela donne l'intervalle dans lequel générer le nombre aléatoire
	max=$(wc -l < liste_cleans)
	number=$[($RANDOM % ($max + 1))]
# Head -X affiche les X premières lignes du fichier, tail -1 affiche la dernière
# Solution réservée aux fichiers de petites tailles
	lien="http://www.lequipe.fr"$(head -$number liste_cleans | tail -1)
else
# On fait une recherche sur le premier argument
	grep -i ".*$1.*" liste_cleans > resultats
# Shift efface le premier argument (donc l'ancien $2 devient $1, l'ancien $3 devient $2...)
	shift
	for i
		do
# On fait une recherche pour chaque argument restant
		res=$(grep -i ".*$i.*" resultats)
		if [[ $res != "" ]] ; then echo $res > resultats ; fi
		done
# Si il existe plusieurs résultats, on prend le 1er
	nbligne=$(cat resultats |wc -l)
	if [[ $nbligne != 0 ]] ; then lien="http://www.lequipe.fr"$(head -1 resultats)
# Dans le cas où les résultats seraient nuls, on stop l'exécution du script avec "exit"
	else echo -e "Pas de résultat pour ces mots clefs \n" ; exit
	fi
fi

echo -n "Téléchargement de la page $lien... "

curl -s $lien > article

# Comme vu plus haut, on vérifie que la page a bien été téléchargée en comptant le nombre de lignes présentes.
nbligne=$(cat article 2> /dev/null |wc -l) 

if [[ $nbligne != 0 ]]
	then sleep 1 ; echo "Terminé"
else
	sleep 1 ; echo "Echec"
fi

# On conserve le contenu à l'intérieur de la balise <div paragr...></div>, on supprime les balises HTML, on supprime les tabulations, on résoud les problèmes d'encodage
# On redirige vers la poubelle la sortie 2 (qui affiche les erreurs)
grep "paragr paragraf.*" < article 2> /dev/null |sed 's|</b>||g' 2> /dev/null |sed 's|<[^>]*>||g' 2> /dev/null |sed -r "s/\t//ig" 2> /dev/null |sed "s/&rsquo;/\'/g" > contenu 2> /dev/null
echo 

# On affiche le contenu du fichier "contenu"
cat -n contenu 2> /dev/null
graphique=$(cat contenu 2> /dev/null)
# Si le paquet Zenity est installé sur la machine, alors on affiche le contenu dans une fenêtre graphique
if [[ $(which zenity) != "" ]] ; then zenity --notification --title="Contenu de l'article" --text="$graphique" 
else echo -e "\nZenity est requis pour l'affichage graphique, pour l'installer, saisir : # sudo apt-get install zenity \n"
fi
}

# On regarde si un argument a été passé en paramètre du script
if [[ $# != 0 ]] ; then
	for i
# On concatène les arguments
		do
			test=$test$i
		done
# On affiche l'aide si -h ou --help a été saisie en 1er argument, $# donne ici le nombre d'arguments passés en paramètre
	if [[ $# == 1 ]] ; then 
		if [[ $1 == '-h' || $1 == '--help' ]] ; then
		        aide
# On vérifie que les autres arguments sont composés de lettres minuscules, $@ contient ici l'ensemble des arguments passés en paramètre
		elif [[ $1 == +([[:lower:]]) ]] ; then
			affiche $@
		else echo -e "Option ou argument non reconnu\n"
		fi
	elif [[ $# > 1 ]] ; then
		if [[ $1 == '-h' || $1 == '--help' ]] ; then
			echo -e "Option ou argument non reconnu\n"
		elif [[ $test == +([[:lower:]]) ]] ; then
			affiche $@
		else echo -e "Option ou argument non reconnu\n"
		fi
	fi
else affiche
fi



