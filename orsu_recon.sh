#!/bin/bash

#Tool Created By @iam.orsu
#Enumerated Subdomains with Subfinder, Assetfinder..
#Checks the domain is alive or not
#Takes Screenshot of the site
#Performs portscanning on the alive domains
domain=$1
RED="\033[1;31m"
RESET="\033[0m]"

subdomain_path=$domain/subdomains
screenshot_path=$domain/screenshots
scan_path=$domain/scans

if [ ! -d "$domain" ];then
	mkdir $domain
fi

if [ ! -d "$subdomain_path" ];then
	mkdir $subdomain_path
fi

if [ ! -d "$screenshot_path" ];then
	mkdir $screenshot_path
fi

if [ ! -d "$scan_path" ];then
	mkdir $scan_path
fi

echo -e "${RED} [+] Launching Subfinder .....${RESET}"
subfinder -d $domain > $subdomain_path/found.txt

echo -e "${RED} [+] Launching assetfinder .....${RESET}"
assetfinder $domain > grep $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Launching amass .....${RESET}"
subfinder -d $domain > $subdomain_path/found.txt

#echo -e "${RED} [+] Launching Subfinder .....${RESET}"
#subfinder -d $domain > $subdomain_path/found.txt



echo -e "${RED} [+] Finding alive subdomain .....${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe -prefer-https | grep https | sed 's/https\?:\/\///' | tee -a $subdomain_path/alive.txt



echo -e "${RED} [+] Taking Screenshots of aloive subdomains.....${RESET}"
gowitness file -f $subdomains/alive.txt -P $screenshot_path/ --no-http

echo -e "${RED} [+] Running Nmap on Alive Subdoamins.....${RESET}"
nmap -iL $subdomains/alive.txt -T4 -A -p- -oN $scan_path/nmap.txt
