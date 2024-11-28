sudo apt update
sudo apt-get install $(cat apt)

echo ''
echo 'INSTALLING SNAP CASKS'
while IFS= read -r snap_name; do
    echo ''
    echo "> Installing $snap_name..."
    sudo snap install "$snap_name"
done < snap

echo ''
echo 'INSTALLING GitHub Desktop'
wget -qO - https://apt.packages.shiftkey.dev/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/shiftkey-packages.gpg > /dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/shiftkey-packages.gpg] https://apt.packages.shiftkey.dev/ubuntu/ any main" > /etc/apt/sources.list.d/shiftkey-packages.list'
sudo apt update
sudo apt install github-desktop

echo ''
echo 'INSRTALLING DISCORD'
sudo snap install discord --classic

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

install google chrome
echo ''
echo 'INSTALLING GOOGLE CHROME'
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome*.deb
sudo rm -r -f google-chrome*.deb
