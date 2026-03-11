#!/bin/bash
# check to see if root priviliges are on if not, exit out of the script with appending error message.
if [[ $EUID -ne 0 ]]; then
	echo "Root privileges are not on, exiting out of script"
	exit 1
fi

echo "Script is running with root privliges... continuing"

#Update refreshes package list & upgrade installs newer versions of installed packages. 
sudo apt update && sudo apt upgrade

#Read user input, if user text is exactly apache or nginx install the relevant web server and start and anable it
#Otherwise exit's out of the operation and display error message.
read -rp "Please choose the following type of web server to install (Apache/Nginx): " WEB_SERVER

if [[ "$WEB_SERVER" == "apache" ]]; then
	sudo apt install apache2
	sudo systemctl start apache2
	sudo systemctl enable apache2
elif [[ "$WEB_SERVER" == "nginx" ]]; then
	sudo apt install nginx
	sudo systemctl start nginx
	sudo systemctl enable nginx
else
	echo "Invalid input. Please type 'apache' or 'nginx'"
	exit 1
fi

#Read user input and save a chosen name for desired hostname
#Set hostname as new name
#Edit and update the etc/hosts file to include the new hostname mapped to the IP.
#Display the changed /hosts file via cat

while true; do

	read -p "Please enter a desired hostname for your server: " NEW_HOSTNAME

	#check for spaces
	if [[ "$NEW_HOSTNAME" =~ [[:space:]] ]]; then
		echo "chosen name contains spaces, please enter a new name without spaces"
		continue
	fi

	#check for special characters
	if [[ "$NEW_HOSTNAME" =~ [^a-zA-Z0-9_] ]]; then
		echo "Chosen name contains special characters, please enter a new name"
		continue
	fi

	#check for empty input
	if [[ -z "$NEW_HOSTNAME" ]]; then
		echo "Invalid input: input cannot be empty, please enter a new name"
		continue
	fi

	break
done
sudo hostnamectl set-hostname "$NEW_HOSTNAME"
sudo nano /etc/hostname
sudo nano /etc/hosts
echo "please reboot system for changes to take effect"

#create a HTML file (index) in the appropriate directory to be served by chosen webserver
sudo tee /var/www/html/index.html > /dev/null << EOF

<!DOCTYPE html>
<html>
<head>
	<title>New Page</title>
</head>
<body>
	<h1>Hello, World!</h1>
	<p>This page was created automatically after installation. In Donabate </p>
</body>
</html>

EOF

#Modifying the firewall to enable traffic to pass throughthe standard HTTP port (80)
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw status

echo "Traffic is enabled to pass through port 80"

echo "This script has finished running, to see if sample web page has been created, open up your browser and enter the following: 142.93.41.37/index.html"

