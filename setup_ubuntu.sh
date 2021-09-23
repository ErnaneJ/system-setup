#!/usr/bin/env bash
# ----------------------------- VARIAVEIS ----------------------------- #
TEMP_PROGRAMS_DIRECTORY="$HOME/temp_programs" # Pasta temporaria para salver os arquivos .deb

URL_DEB_FILES=(
  https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
  https://discord.com/api/download?platform=linux\&format=deb
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  http://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/9505/wps-office_11.1.0.9505.XA_amd64.deb
  https://updates.insomnia.rest/downloads/ubuntu/latest
)

PPA_ADDRESSES=(
  ppa:obsproject/obs-studio
  multiverse
)

PROGRAMS_VIA_APT=(
  obs-studio
  ffmpeg
  python
  curl
  nodejs
  npm
  mysql-server
  gnome-tweak-tool
  git
  gimp
  indicator-sysmonitor
  kdenlive
  vlc
  steam
)

PROGRAMS_VIA_SNAP=(
  "code --classic"
  "sublime-text-3 --classic --candidate"
  "spotify"
  "postman"
  "telegram-desktop"
)

# ----------------------------- Estagio de pre instalacao ----------------------------- #

echo -e "\n\n==== Removendo travas eventuais do apt ===="
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

echo -e "\n\n==== Adicionando/Confirmando arquitetura de 32 bits ====" 
sudo dpkg --add-architecture i386

echo -e "\n\n==== Atualizando o repositório ===="
sudo apt update -y

echo -e "\n\n==== Adicionando repositórios PPA ===="
sudo apt install software-properties-common -y
for ppa_address in ${PPA_ADDRESSES[@]}; do
    sudo add-apt-repository "$ppa_address" -y
done

# ----------------------------- Instalando ----------------------------- #
echo -e "\n\n==== Atualizando o APT depois da adição de novos repositórios ===="
sudo apt update -y

echo -e "\n\n==== Instalando programas no APT ===="
for apt_program in ${PROGRAMS_VIA_APT[@]}; do
  echo -e "\n\n[INSTALANDO VIA APT] - $apt_program"
  sudo apt install "$apt_program" -y
done

echo -e "\n\n==== Download de programas .deb ===="
mkdir "$TEMP_PROGRAMS_DIRECTORY"
for url in ${URL_DEB_FILES[@]}; do
  wget -c "$url" -P "$TEMP_PROGRAMS_DIRECTORY"
done

echo -e "\n\n==== Instalando pacotes .deb baixados ===="
sudo dpkg -i $TEMP_PROGRAMS_DIRECTORY/*.deb
sudo apt --fix-broken install -y
sudo dpkg -i $TEMP_PROGRAMS_DIRECTORY/*.deb # caso ocorra erro por dependencia de pacotes.

echo -e "\n\n==== Instalando pacotes Snap ===="
sudo apt install snapd -y
for snap_program in "${PROGRAMS_VIA_SNAP[@]}"; do
  echo -e "\n\n[INSTALANDO VIA SNAP] - $snap_program"
  sudo snap install $snap_program
done


# ----------------------------- Casos especificos ------------------------------- #
echo -e "\n\n==== Personaliza GIMP ===="
wget -c "https://github.com/Diolinux/PhotoGIMP/archive/master.zip" -P "$TEMP_PROGRAMS_DIRECTORY"
unzip $TEMP_PROGRAMS_DIRECTORY/master.zip
mv $HOME/.config/GIMP/2.10 $HOME/.config/GIMP/2.10bkp
cp -r master/PhotoGIMP-master/.var/app/org.gimp.GIMP/config/GIMP/2.10 $HOME/.config/GIMP
rm -rf master

echo -e "\n\n==== Instala o Postgresql ===="
sudo sh -c 'echo -e "deb http://apt.postgresql.org/pub/repos/apt $ (lsb_release -cs) -pgdg main"> /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql

echo -e "\n\n==== Instala o RVM com Ruby e Rails padrao===="
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
\curl -sSL https://get.rvm.io | bash -s stable --rails

echo -e "\n\n==== Instala o NVM ===="
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

# ---------------------------------------------------------------------- #

# ----------------------------- Limpando ------------------------------- #
echo -e "\n\n==== Finalização, atualização e limpeza ===="
sudo apt update && sudo apt dist-upgrade -y
sudo apt autoclean
sudo apt autoremove -y
sudo rm -rf $TEMP_PROGRAMS_DIRECTORY

# ----------------------------- Concluindo --------------------------------- #
echo -e "\n\n==== PRONTO PARA VOAR. ===="

read -p "REINICIAR AGORA? [s/n]: " opcao
if [ "$opcao" == "s" ] || [ "$opcao" == "S" ]; then
  sudo reboot
fi

exit 0