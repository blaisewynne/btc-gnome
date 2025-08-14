#!/bin/bash
CYAN='\033[0;36m'
RED='\033[0;31m'
NORMAL='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
GRAY='\033[1;30'
NC='\033[0m'
LYELLOW='\033[1;33m'
LBLUE='\033[1;34m'
LPURPLE='\033[0;35m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
SETTINGS_FILE='settings.sh'
OS_NAME=$(uname -s)

version=0.2

main () {

    source btclogo.sh
    printf "${YELLOW}${logo}\n"
    printf "${YELLOW}Bitcoin ${LGREEN}Gnome${NC}\n"
    printf "${LPURPLE}Checking if settings.sh exists..."
    if [ -f $SETTINGS_FILE ]; then
        printf "${GREEN} Settings file found.\n"
    else
        printf "${RED} Settings files not found.\n"
        create_settings
    fi
    printf "${LBLUE}Start logging the price of BTC by typing 'start' below:${NC}\n"
    read option
    case $option in

        start | -start | -s | s)
            watcher_start
        ;;

        help | -help | -h | h)
            help_info
        ;;

        version | -version | -v | v)
            version_info
        ;;

    *)
        printf "Command not found. Use command -help for assistance.${NC}\n"
    esac
    
}

create_settings () {

    printf "${GREEN}Creating a settings.sh file....\n"
    touch settings.sh
    printf "This file can be modified to configure time between updates and currency.\n"
    printf "${GREEN}Creating a data.txt file....\n"
    touch data.txt
    printf "This file is used to store BTC value when you are monitoring the value.\n"
    printf "${RED}Note: Currency must be typed correctly and in acronymed format e.g (${GREEN}USD, ${BLUE}GBP, ${YELLOW}EUR${RED})${NC}\n"
    printf "${BLUE}Writing on settings.sh...\n"
    echo "#!/bin/bash" >> "$SETTINGS_FILE"
    printf "${NC}Please type below the amount of seconds you would like between updates.\n"
    read seconds
    if [[ "$seconds" =~ ^[0-9]+$ ]]; then
        echo "UPDATE_TIME=$seconds" >> "$SETTINGS_FILE"
    else
        printf $"{RED}ERROR: Must be a positive integer.\n"
        exit 1
    fi
    printf "${NC}Please type below the currency you would like to conver to. (USD, GBP, EUR, AUD)\n"
    read currency_choice
    if [[ "$currency_choice" =~ ^[[:alpha:]]+$ ]]; then
        echo "CURRENCY=$currency_choice" >> "$SETTINGS_FILE"
    else
        printf $"{RED}ERROR: Must be a string.\n"
        exit 1
    fi

}

version_info () {

    echo "${LYELLOW}Current version: ${LGREEN}${version}\n"

}

help_info () {

	printf "${LPURPLE}
	Options:

	-v, version
	   Check current version of BTC-Tracker
	-h, help
	   Show current help message
   	-s, start
	   Start logging Crypto-currency values"
}

watcher_config () {


    case $OS_NAME in

    Darwin)
        btc_value="$(ggrep -oP '(?<=<div class="YMlKec fxKbKc">)[^<]+(?=<\/div>)' webpage.html)"
        printf "${LBLUE}You are on ${LRED}MacOS\n"
    ;;
    
    Linux)
        btc_value=$(grep -oP '(?<=<div class="YMlKec fxKbKc">)[^<]+(?=<\/div>)' webpage.html)
        printf "${LBLUE}You are on ${LRED}Linux\n"
    ;;

    CYGWIN*|MSYS*|MINGW*)
       btc_value="$(grep -oP '(?<=<div class="YMlKec fxKbKc">)[^<]+(?=<\/div>)' webpage.html)"
       printf "${LBLUE}You are on ${LRED}Windows :(\n"
    ;;
    
    *) 
        btc_value="$(grep -oP '(?<=<div class="YMlKec fxKbKc">)[^<]+(?=<\/div>)' webpage.html)"
        printf "${LBLUE}No idea what ${LRED}you are on?\n"
    esac


}

watcher_start () {
    if [ ! -f $SETTINGS_FILE ]; then
        printf "${RED} Settings file not found. Exiting...\n"
        exit 1
    fi
    watcher_config
    source settings.sh
    printf "${GREEN}Current update speed is ${YELLOW}${UPDATE_TIME} second(s).\n"
    printf "${GREEN}Current currency is ${YELLOW}${CURRENCY}.\n"
    while sleep $UPDATE_TIME ; 
    do
        curl -s "https://www.google.com/finance/quote/BTC-${CURRENCY}" -o webpage.html
        eval={$btc_value}
        btc_date=$(date +"%d-%m-%y %I:%M:%S")
        echo -ne "${CYAN}Current BTC value is: ${btc_value} ${CURRENCY}${NC} | Current Time is: ${GREEN}${btc_date}${NC}\r"
        echo "$btc_value, $btc_date" >> "data.txt"
    done
}   

main