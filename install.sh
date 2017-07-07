#!/bin/bash
sudo su

sudo dnf update -y

sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf copr enable jjelen/yubikey-neo-manager -y
sudo dnf install yubikey-neo-manager -y

sudo dnf copr enable region51/chrome-gnome-shell -y
sudo dnf install chrome-gnome-shell

sudo dnf copr enable dirkdavidis/papirus-icon-theme -y
sudo install papirus-icon-theme

# Install these applications
sudo dnf install arc-theme conky-manager dconf-editor ffmpeg gcc gimp git htop \
libcxx nitrogen nginx python3-devel redhat-rpm-config xclip vlc -y

# Yubikey stuff
sudo dnf install pam_yubico libu2f-host yubikey-personalization-gui ykclient -y
ykpersonalize -m82 -y

# Remove these applications
sudo dnf remove libreoffice-* -y

# Git Radar
git clone https://github.com/michaeldfallen/git-radar .git-radar
echo 'export PATH=$PATH:$HOME/.git-radar' >> .bashrc
echo 'export PS1="[\u@\h \W]\$(git-radar --bash --fetch) $ "' >> .bashrc

# Chrome-Beta
wget 'https://dl.google.com/linux/direct/google-chrome-beta_current_x86_64.rpm'
rpm -ivh google-chrome-beta_current_x86_64.rpm
rm google-chrome-beta_current_x86_64.rpm

# Atom.io
curl -L 'https://atom.io/download/rpm' > atom.rpm
rpm -ivh atom.rpm
rm atom.rpm

apm install minimap minimap-git-diff

# Jetbrains
pycharm='pycharm-community-2017.1.4'
sudo wget "https://download.jetbrains.com/python/$pycharm.tar.gz" -O /opt/pycharm.tar.gz
sudo tar -zxf pycharm.tar.gz
sudo mv $pycharm PyCharm
rm pycharm.tar.gz

phpstorm='PhpStorm-2017.1.4'
sudo wget "https://download.jetbrains.com/webide/$phpstorm.tar.gz" -O /opt/phpstorm.tar.gz
sudo tar -zxf phpstorm.tar.gz
rm phpstorm.tar.gz


# Setup sample config file
cat << 'EOF' >> .ssh/config
Host sample
    PubkeyAuthentication yes
    User 00firestar00
    hostname sample.com
    IdentityFile ~/.ssh/sample
    IdentitiesOnly yes

Host *
    PubkeyAuthentication no
    IdentitiesOnly yes
EOF

# Tnyclick image uploading. API keys not included.
echo '#!/bin/bash
function uploadImage {
  curl -H "API-ID: " -H "API-Key: " -s -F "image=@$1" https://tny.click/upload.php
}

sleep 0.2
img="/tmp/shot.png"
gnome-screenshot -af $img
clip=$(uploadImage $img)
echo $clip | xclip -selection c
rm $img
notify-send "TnyClick $clip" -t 2000' \
| sudo tee /usr/local/bin/temp

sudo chmod 755 /usr/local/bin/temp

# Fixes issues with chrome complaining that it crashed on reboot
echo '#!/bin/bash
sed -i 's/"exit_type":"Crashed"/"exit_type":"None"/g' /home/evan/.config/google-chrome-beta/Default/Preferences' \
| sudo tee /usr/local/bin/chrome_crashed

# Because discord is dumb and has a semi-broken ubuntu desktop file instead
echo "Name=Discord Canary
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/opt/DiscordCanary/DiscordCanary
Icon=/opt/DiscordCanary/discord.png
Type=Application
StartupNotify=true
Categories=Network;InstantMessaging;" \
| sudo tee /usr/share/applications/discord-canary.desktop

# Add file to update discord, then update/install it
echo '#!/bin/bash
#unlink anything that might be there
tmpzip="/tmp/discord.tar.gz"
tmpfile="/tmp/DiscordCanary"
installfile="/opt/DiscordCanary"

echo "Removing temp files"
rm -rf $tmpfile
rm -f $tmpzip

echo "Downloading latest Discord install"
wget -qO $tmpzip "https://discordapp.com/api/download/canary?platform=linux&format=tar.gz"
#extract it
tar -zxC /tmp/ -f $tmpzip

echo "Rsync to $installfile"
rsync -a $tmpfile /opt/

echo "Removing old mydiscord files"
rm -rf "$installfile/resources/app"
rm -f "$installfile/resources/original_app.asar"

echo "Launching Discord"
"$installfile/DiscordCanary" &
mydiscord --css /home/data/mydiscord/discord-custom.css' \
| sudo tee /usr/local/bin/updatecord

sudo chmod 755 /usr/local/bin/updatecord
sh updatecord
