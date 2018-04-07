#!/bin/bash
# Yubikey
sudo add-apt-repository ppa:yubico/stable
# Papirus Icon Theme
sudo add-apt-repository ppa:papirus/papirus
# Hipchat 4
sudo sh -c 'echo "deb https://atlassian.artifactoryonline.com/atlassian/hipchat-apt-client $(lsb_release -c -s) main" > /etc/apt/sources.list.d/atlassian-hipchat4.list'
wget -O - https://atlassian.artifactoryonline.com/atlassian/api/gpg/key/public | sudo apt-key add -
# Arc theme
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list"
wget http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | sudo apt-key add -

sudo apt-get update -y
sudo apt-get upgrade -y

# Gnome
sudo apt-get install gnome-shell ubuntu-gnome-desktop -y
# Themes
sudo apt-get install papirus-icon-theme arc-theme unity-tweak-tool -y
# Displays
sudo apt-get install nvidia-384 -y
# Extra Tools
sudo apt-get install yubikey-neo-manager hipchat4 conky openjdk-8-jdk phpunit htop -y

# Remove Amazon
sudo rm /usr/share/applications/ubuntu-amazon-default.desktop
sudo rm /usr/share/unity-webapps/userscripts/unity-webapps-amazon/Amazon.user.js
sudo rm /usr/share/unity-webapps/userscripts/unity-webapps-amazon/manifest.json

# Fix polkit issue
sed -i 's/unix-group:admin/unix-group:admin;unix-group:EngineeringSudo/' /etc/polkit-1/localauthority.conf.d/51-ubuntu-admin.conf

# Generate default key for Vagrant
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa

# Git Radar
git clone https://github.com/michaeldfallen/git-radar .git-radar
echo 'export PATH=$PATH:$HOME/.git-radar' >> .bashrc
echo 'export PS1="[\u@\h \W]\$(git-radar --bash --fetch) $ "' >> .bashrc

# Chrome Beta
curl -L 'https://dl.google.com/linux/direct/google-chrome-beta_current_amd64.deb' > chrome-beta.deb
sudo dpkg -i chrome-beta.deb

# Atom.io
curl -L 'https://atom.io/download/deb' > atom.deb
sudo dpkg -i atom.deb

apm install minimap minimap-git-diff

# Jetbrains
phpstorm='PhpStorm-2018.1'
sudo wget "https://download.jetbrains.com/webide/$phpstorm.tar.gz" -O /opt/phpstorm.tar.gz
sudo tar -zxf /opt/phpstorm.tar.gz -C /opt/
sudo rm /opt/phpstorm.tar.gz

# Softether
sudo wget 'http://www.softether-download.com/files/softether/v4.25-9656-rtm-2018.01.15-tree/Linux/SoftEther_VPN_Client/64bit_-_Intel_x64_or_AMD64/softether-vpnclient-v4.25-9656-rtm-2018.01.15-linux-x64-64bit.tar.gz' -O /opt/softether.tar.gz
sudo tar -zxf /opt/softether.tar.gz -C /opt/
sudo rm /opt/softether.tar.gz
cd /opt/vpnclient
sudo make
sudo chmod 600 /opt/vpnclient/*
sudo chmod 700 /opt/vpnclient/vpnclient
sudo chmod 700 /opt/vpnclient/vpncmd
cd -

echo '#!/bin/bash
# To get started, follow the steps outlined here:
# https://linuxconfig.org/setting-up-softether-vpn-server-on-ubuntu-16-04-xenial-xerus-linux#h7-5-client-configuration
if [ $1 = "start" ]; then
    sudo /opt/vpnclient/vpnclient start
    sleep 3
    /opt/vpnclient/vpncmd /client localhost /cmd AccountConnect vpn
    sleep 2
    sudo dhclient vpn_ethvpn0
elif [ $1 = "stop" ]; then
    /opt/vpnclient/vpncmd /client localhost /cmd AccountDisconnect vpn
    sudo /opt/vpnclient/vpnclient stop
elif [ $1 = "status" ]; then
    /opt/vpnclient/vpncmd /client localhost /cmd AccountStatusGet vpn
fi' \
| sudo tee /usr/local/bin/vpn

sudo chmod 755 /usr/local/bin/vpn

# Setup sample config file
cat << 'EOF' >> .ssh/config
Host sample
    PubkeyAuthentication yes
    User ejarrett
    hostname sample.com
    IdentityFile ~/.ssh/sample
    IdentitiesOnly yes

Host *
    PubkeyAuthentication no
    IdentitiesOnly yes
EOF

# Setup Gitconfig
cat << 'EOF' >> .gitconfig
[user]
        email = ejarrett@something.com
        name = Evan Jarrett
[mailmap]
    file = ~/.mailmap
[help]
        autocorrect = 1
[push]
        default = simple
[init]
        templatedir = ~/.git_template
EOF

# Nanorc
echo "set tabsize 4" >> ~/.nanorc
echo "set tabstospaces" >> ~/.nanorc

# Fixes issues with chrome complaining that it crashed on reboot
echo '#!/bin/bash
sed -i 's/"exit_type":"Crashed"/"exit_type":"None"/g' ~/.config/google-chrome-beta/Default/Preferences' \
| sudo tee /usr/local/bin/chrome_crashed
sudo chmod 755 /usr/local/bin/chrome_crashed
