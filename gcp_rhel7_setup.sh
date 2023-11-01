#!/bin/bash

FLAG="/var/log/firstboot.log"
if [[ ! -f $FLAG ]]; then
  sudo yum -y update
  sudo yum -y install yum-utils
  sudo yum-builddep python3

  sudo yum install -y scl-utils gcc zlib-devel bzip2-devel sqlite-devel openssl-devel libgdiplus make
  git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
  echo "## pyenv configs" >> $HOME/.bashrc && \
      var='export PYENV_ROOT="$HOME/.pyenv"' && \
      echo "$var" >> $HOME/.bashrc && \
      var='export PATH="$PYENV_ROOT/bin:$PATH"' && \
      echo "$var" >> $HOME/.bashrc && \
      echo "if command -v pyenv 1>/dev/null 2>&1; then" >> $HOME/.bashrc && \
      var='  eval "$(pyenv init -)"' && \
      echo  "$var" >> $HOME/.bashrc && \
      echo "fi" >> $HOME/.bashrc

  source $HOME/.bashrc

  env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.9.16
  pyenv global 3.9.16
  pyenv shell 3.9.16
  sudo ln -s $HOME/.pyenv/versions/3.9.16/lib/libpython3.9.so.1.0 /usr/local/lib/libpython3.9.so.1.0

  mkdir ~/app
  cd ~/app

  curl https://raw.githubusercontent.com/Omaraldarwish/autosu_media/main/requirements_v_1.txt -O

  pip install --upgrade pip
  pip install -r ~/app/requirements_v_1.txt
  pip install aspose.slides

  eval "$(grep VERSION_ID /etc/os-release)"
  eval "$(grep ^ID= /etc/os-release)"
  OLD_IFS=$IFS
  IFS='.'
  read -ra split_version <<< "$VERSION_ID"
  IFS=$OLD_IFS
  MAJOR_VERSION=$split_version
  sudo tee /etc/yum.repos.d/adoptium.repo << EOM
  [Adoptium]
  name=Adoptium
  baseurl=https://packages.adoptium.net/artifactory/rpm/$ID/$MAJOR_VERSION/\$basearch
  enabled=1
  gpgcheck=1
  gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
EOM

  sudo yum -y update

  sudo yum install -y temurin-20-jdk
  sudo touch "$FLAG"
  echo "Instance initialized successfully"

else
  echo "Instance already initialized"
fi
