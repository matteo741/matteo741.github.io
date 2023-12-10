#!/bin/bash

# La commande 'set -eu' affiche un message d'erreur lors du démarrage.

# Déclaration de la stack :
declare -a stack

# Liste des Commandes et des Opérations :
help() {
    echo -e "Commandes :"
    echo -e "\e[33m  help:\e[0m Affiche la liste des commandes et des opérations."
    echo -e "\e[33m  dump:\e[0m Affiche le contenu de la stack."
    echo -e "\e[33m  drop:\e[0m Supprime le contenu de la stack."
    echo -e "\e[33m  exit, quit:\e[0m Quitter la calculatrice."
    echo -e "\e[33m  swap:\e[0m Echange les deux derniers éléments de la stack."
    echo -e "\e[33m  dup:\e[0m Duplique la stack."
    echo -e "Opérations :"
    echo -e "\e[33m  + or add:\e[0m Addition"
    echo -e "\e[33m  - or sub:\e[0m Soustraction"
    echo -e "\e[33m  * or mul:\e[0m Multiplication"
    echo -e "\e[33m  / or div:\e[0m Division"
    echo -e "\e[33m  sum:\e[0m Somme de tous les éléments de la stack"
}

# Fonctions des commandes et des opérations :

# Fonction permettant d'afficher le contenu de la stack
dump() {
    echo "Stack: ${stack[@]}"
}

# Fonction permettant de supprimer le contenu de la stack :
drop() {
    if [ ${#stack[@]} -gt 0 ]; then
        stack=()
    else
        echo -e "\e[1;31mLa stack est vide.\e[0m"
    fi
}

# Fonction permettant de quitter la calculatrice :
exit_calculatrice() {
    echo -e "\e[32mAu revoir !\e[0m"
    exit 0
}

# Fonction permettant d'échanger les deux derniers éléments de la stack :
swap() {
    if [ ${#stack[@]} -ge 2 ]; then

# On va stocker temporairement le dernier élément de la stack pour intervertir les deux éléments entre eux.
        tmp=${stack[${#stack[@]}-1]}
        stack[${#stack[@]}-1]=${stack[${#stack[@]}-2]}
        stack[${#stack[@]}-2]=$tmp
    else
        echo -e "\e[1;31mIl n'y a pas assez d'éléments pour effectuer la commande 'swap'.\e[0m"
    fi
}

# Fonction permettant de faire une addition :
add() {
    if [ ${#stack[@]} -ge 2 ]; then

# On va additioner les deux éléments et la stocker dans la variable $resultat. 
	resultat=$(echo "scale=3; ${stack[-1]} + ${stack[-2]}" | bc)
	stack=("${stack[@]:0:$((${#stack[@]}-2))}" "$resultat")
    else
        echo -e "\e[1;31mIl n'y a pas assez d'éléments pour faire une addition.\e[0m"
    fi
}

# Fonction permettant de dupliquer la stack :
dup() {
    if [ ${#stack[@]} -gt 0 ]; then

# On va créer une copie de la stack dans la variable $dup_stack et l'ajouter à la stack existante.
        dup_stack=("${stack[@]}")
        stack+=("${dup_stack[@]}")
    else
        echo -e "\e[1;31mIl y a aucun élément dans la stack pour faire une duplication de celle-ci.\e[0m"
    fi
}

# Fonction permettant de faire une soustraction :
sub() {
    if [ ${#stack[@]} -ge 2 ]; then

# On va soustraire les deux éléments et la stocker dans la variable $resultat. 
	resultat=$(echo "scale=3; ${stack[-1]} - ${stack[-2]}" | bc)
	stack=("${stack[@]:0:$((${#stack[@]}-2))}" "$resultat")
    else
        echo -e "\e[1;31mIl n'y a pas assez d'éléments pour faire une soustraction.\e[0m"
    fi
}

# Fonction permettant de faire une multiplication : 
mul() {
    if [ ${#stack[@]} -ge 2 ]; then

# On va multiplier les deux éléments et la stocker dans la variable $resultat. 
        resultat=$(echo "scale=3; ${stack[-1]} * ${stack[-2]}" | bc)
	stack=("${stack[@]:0:$((${#stack[@]}-2))}" "$resultat")
    else
        echo -e "\e[1;31mIl n'y a pas assez d'éléments pour faire une multiplication.\e[0m"
    fi
}

# Fonction permettant de faire une division :
div() {
    if [ ${#stack[@]} -ge 2 ]; then

# On va faire deux variables : une pour le diviseur et une pour le dividende.
        diviseur=${stack[${#stack[@]}-1]}
        dividende=${stack[${#stack[@]}-2]}
        
        if (( $(echo "$diviseur != 0" | bc -l) )); then

# On va diviser les deux éléments et la stocker dans la variable $resultat.
            resultat=$(echo "scale=3; $dividende / $diviseur" | bc)
            stack=("${stack[@]:0:$((${#stack[@]}-2))}" "$resultat")
        else
            echo -e "\e[1;31mVous ne pouvez pas diviser par 0.\e[0m"
        fi
    else
        echo -e "\e[1;31mIl n'y a pas assez d'éléments pour faire une division.\e[0m"
    fi
}


traitement() {
    read -a tokens -p ">>> "

# Ce qu'on appelle token est la valeur qu'on entre dans l'interface de la calculatrice : nombres, commandes ou opérations.
    for token in "${tokens[@]}"; do
        case $token in
            [0-9]* | [0-9]*.[0-9]*)
    		stack+=("$token")
    		;;
            "+" | "add") 
                add
                ;;
            "-" | "sub") 
                sub
                ;;
            "*" | "mul") 
                mul
                ;;
            "/" | "div") 
                div
                ;;
            "sum") 
                sum=0

# On va additioner tous les éléments de la stack dans la variable $sum qui est iniatialisée à 0.
                for element in "${stack[@]}"; do
                    sum=$(echo "$sum + $element" | bc)
                done
                stack=("$sum")
                ;;
            "help") 
                help
                ;;
            "dump") 
                dump
                ;;
            "drop") 
                drop
                ;;
            "exit" | "quit") 
                exit_calculatrice
                ;;
            "swap") 
                swap
                ;;
            "dup") 
                dup
                ;;
            *)
                echo -e "\e[1;31mLa commande '$token' est invalide. Vous pouvez afficher la liste des commandes disponibles avec la commande 'help'.\e[0m"
                ;;
        esac
    done
}

# Fonction permettant d'intégrer une interface lors du démarrage du script : 
menu_interface() {
    PS3="Selectionnez une option : "
    options=("Démarrage de la calculatrice" "Liste des commandes" "Quitter la calculatrice")
    select opt in "${options[@]}"; do
        case $opt in
            "Démarrage de la calculatrice")
                echo "Lancement de la calculatrice..."
		echo -e "\e[32mBienvenue sur la calculatrice RPN. Utilisez la commande 'help' pour afficher la liste des commandes et des opérations.\e[0m"
                break
                ;;
            "Liste des commandes")
                help
                ;;
            "Quitter la calculatrice")
                exit_calculatrice
                ;;
            *) 
		clear
		titre
		option_invalide
		menu_interface
                ;;
        esac
    done
}

# Afficher la bannière avec figlet en vert :
echo -e "\e[33m$(figlet "RPN Calculatrice")\e[0m"
titre() {
	echo -e "\e[33m$(figlet "RPN Calculatrice")\e[0m"
}

# Afficher le message d'erreur dans le cas d'une option invalide :
option_invalide() {
	echo "L'option est invalide. Choisissez l'une des options ci-dessous."
}

# Affichage lors du lancement du script :
echo "Calculatrice RPN fait par Mattéo SIMON."
menu_interface

# Si la boucle est vrai, la fonction traitement est appelé continuellement permettant l'intéraction avec la calculatrice.
while true; do
    traitement
done
