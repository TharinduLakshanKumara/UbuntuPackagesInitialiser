#!/bin/bash
# Purpose: Install useful softwares in Ubuntu after a fresh install of OS
# Author: Tharindu Lakshan Kumara
# ------------------------------------------

# Colors ------------------------------------------------------------
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack="\033[1;30m"       # Black
BRed="\033[1;31m"         # Red
BGreen="\033[1;32m"       # Green
BYellow="\033[1;33m"      # Yellow
BBlue="\033[1;34m"        # Blue
BPurple="\033[1;35m"      # Purple
BCyan="\033[1;36m"        # Cyan
BWhite="\033[1;37m"       # White

# Underline
UBlack="\033[4;30m"       # Black
URed="\033[4;31m"         # Red
UGreen="\033[4;32m"       # Green
UYellow="\033[4;33m"      # Yellow
UBlue="\033[4;34m"        # Blue
UPurple="\033[4;35m"      # Purple
UCyan="\033[4;36m"        # Cyan
UWhite="\033[4;37m"       # White

# Background
On_Black="\033[40m"       # Black
On_Red="\033[41m"         # Red
On_Green="\033[42m"       # Green
On_Yellow="\033[43m"      # Yellow
On_Blue="\033[44m"        # Blue
On_Purple="\033[45m"      # Purple
On_Cyan="\033[46m"        # Cyan
On_White="\033[47m"       # White

# Variables ----------------------------------------------------------
INPUT_PACKAGES_CSV=./data/packagelist.csv # input file with package name to install.
declare -a packages_list # array to store packages.
declare -a package_details # array to store package details.
declare -a packages_to_install # array to store packages to install.
# declare -a PACKAGE_LIST_INSTALLED  # array to store installed packages.
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)


# Functions ----------------------------------------------------------
clear_console() {
    clear
}

# Check if the machine can ping google.com
check_internet_connection() {
    if ping -c 1 google.com > /dev/null; then
        echo -e "${Green}OK${Color_Off}"
    else
        echo -e "${BRed}Failed!!!${Color_Off}"
        exit 101 # Network is unreachable
    fi
}


# Main --------------------------------------------------------------
clear_console
# echo -e "${Yellow}Updating packages...${Color_Off}"
# sudo apt update
# echo -e "${Yellow}Upgrading...${Color_Off}"
# sudo apt upgrade

# Welcome message
echo -e "${Blue}--------------------------------------------------------------------------------${Color_Off}"
echo -e "${BBlue}Welcome ${BCyan}$USER ${BBlue}to the installation script for Ubuntu packages!${Color_Off}"
echo -e "${BBlue}This script will install useful softwares in Ubuntu after a fresh install of OS.${Color_Off}"
echo -e "${Blue}--------------------------------------------------------------------------------${Color_Off}"
echo -e "${BBlue}OS: ${Cyan}${OS_NAME}${Color_Off}"
echo -e "${BBlue}Version: ${Cyan}${OS_VERSION}${Color_Off}"
echo


# [ ! -f $INPUT_PACKAGES_CSV ] && { echo "$INPUT_PACKAGES_CSV file not found"; exit 99; }

echo -ne "Checking internet connection... "
check_internet_connection


# Read package list from csv file
echo -ne "${BCyan}Importing package details... ${Color_Off}"

# while read -r line; do COMMAND; done < input.file
# The -r option passed to read command prevents backslash escapes from being interpreted.
# Add IFS= option before read command to prevent leading/trailing whitespace from being trimmed.
while IFS=',' read -r package_name recommendation # IFS is the input field separator
do
    package_details=("$package_name" "$recommendation")
    packages_list+=("${package_details}") # only the package_name is passed as multidimensional arrays are not supported by bash
done < <(tail -n +2 $INPUT_PACKAGES_CSV) # Ignoring the header is csv file

echo -e "${Green}Done${Color_Off}"


# Creating a package list to be installed after checking already installed packages
echo
echo -e "${BCyan}Creating a list of packages to be installed...${Color_Off}"
# Sorting packages to be installed 
for i in "${!packages_list[@]}"
do
    if dpkg -l "${packages_list[$i]}"  &> /dev/null; then
        echo -e "${Green}${packages_list[$i]}${Color_Off} is already installed."
    else
        echo -e "${Yellow}${packages_list[$i]}${Color_Off} is not installed."
        packages_to_install+=("${packages_list[$i]}")
    fi
done


# Notifying the user about the packages to be installed
echo "-----------------------------------------"
echo -e "${BCyan}The following packages will be installed:${Color_Off}"
for i in "${!packages_to_install[@]}"
do
    echo "${packages_to_install[$i]}"
done

# Asking user to confirm the packages to be installed 
if [ "${#packages_to_install[@]}" -gt "0" ]; then # If there are packages to be installed
    echo "The above packages will be installed:"
    read -p "Do you want to install all (a) or install one by one (o) or quit (q)? [a/o/q]: " choice

    case $choice in
        
        [a]* ) # Install all packages
            echo -e "${Cyan}Installing all packages...${Color_Off}"
            sudo apt install ${packages_to_install[@]}
            ;;
        
        [o]* ) # Install one by one
            echo -e "${Cyan}Installing one by one...${Color_Off}"
            for i in "${!packages_to_install[@]}"
            do
                while true; do
                    read -p "Do you want to install ${packages_to_install[$i]}? [y/n/q]: " yn
                    case $yn in
                        [Yy]* )
                            echo -e "${Cyan}Installing ${packages_to_install[$i]}...${Color_Off}"
                            sudo apt install ${packages_to_install[$i]}
                            break
                            ;;
                        [Nn]* )
                            break
                            ;;
                        [Qq]* ) # Quit
                            echo -e "${Cyan}Exiting...${Color_Off}"
                            exit 0
                            ;;
                        * )
                            echo "Please answer yes or no."
                            ;;
                    esac
                done
            done
            ;;
        
        [q]* ) # Quit
            echo -e "${Cyan}Quitting...${Color_Off}"
            exit 0
            ;;

        
        * ) # Invalid input
            echo -e "${Cyan}Invalid choice...${Color_Off}"
            exit 1
            ;;
    esac

    else # If there are no packages to be installed
        echo -e "${Cyan}No packages to be installed!${Color_Off}"
        echo -e "${Yellow}Exiting${Color_Off}"
        exit 0
fi
echo -e "${Yellow}Exiting${Color_Off}"