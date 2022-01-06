#!/bin/bash -x
# @ production environment, remove -x option
# Docker Bash Script Deployment
# (c) Jan 2022 allowebs.com generated by masteringunixshell.net

# if you want to see your debug messages, uncomment this variable
#DEBUG_IS_ON=yes

# you can use this function for debug messages
# usage: command: "debug File Is Open" --(gives oputput)--> "At 11:44:00 File Is Open"
function debug()
{
  if [ "${DEBUG_IS_ON}" = "yes" ]
  then
    NOW=$(date +"%T")
    echo "At $NOW Debug: ${*}" >&2
  fi
}


function print_help()
{
  echo -e "Syntax: $0 [-1] [-2] [-3] [-4] [-5] [-6] [-7] >&2"
  echo -e "\t[-1]: Install Docker"
  echo -e "\t[-2]: Install FTP"
  echo -e "\t[-3]: Install Portainer"
  echo -e "\t[-4]: Install Autoheal"
  echo -e "\t[-5]: Install SSL for Apache"
  echo -e "\t[-6]: Install Poste.io"
  echo -e "\t[-7]: Install Nginx"
  exit 1
}

# Install Docker
function process_Docker()
{
  # to do: write code here
  # you can use debug function
   debug Procesing 'Docker'
   sudo apt-get update -y
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
apt-get update -y
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
}

# Install FTP
function process_FTP()
{
  # to do: write code here
  # you can use debug function
   debug Procesing 'FTP'
   docker run -d -p 20-21:20-21 -p 65500-65515:65500-65515 -v /tmp:/var/ftp:ro metabrainz/docker-anon-ftp
}

# Install Portainer
function process_Portainer()
{
  # to do: write code here
  # you can use debug function
   debug Procesing 'Portainer'
   docker volume create portainer_data
docker run -d -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    cr.portainer.io/portainer/portainer-ce:latest
}

# Install Autoheal
function process_Autoheal()
{
  # to do: write code here
  # you can use debug function
   debug Procesing 'Autoheal'
   docker run -d \
    --name autoheal \
    --restart=always \
    -e AUTOHEAL_CONTAINER_LABEL=all \
    -v /var/run/docker.sock:/var/run/docker.sock \
    willfarrell/autoheal:latest
}

# Install SSL for Apache
function process_Deploy SSL in Apache()
{
  # to do: write code here
  # you can use debug function
   debug Procesing 'Deploy SSL in Apache'
   certbot --apache -d allowebs.com -d www.allowebs.com
}

# Install Poste.io
function process_Poste.io()
{
  # to do: write code here
  # you can use debug function
   debug Procesing 'Poste.io'
   docker run \
    --net=host \
    -e TZ=Europe/Prague \
    -v /mail/data:/data \
    --name "mailserver" \
    -h "mail.allowebs.com" \
    -t analogic/poste.io
}

# Install Nginx
function process_Nginx()
{
  # to do: write code here
  # you can use debug function
   debug Procesing 'Nginx'
   docker run --detach \
    --name www \
    --env "VIRTUAL_HOST=allowebs.com" \
    --env "LETSENCRYPT_HOST=allowebs.com" \
    nginx
}

while getopts ":1234567" o
do
  case "$o" in
  1) process_Docker ;;
  2) process_FTP ;;
  3) process_Portainer ;;
  4) process_Autoheal ;;
  5) process_Deploy SSL in Apache ;;
  6) process_Poste.io ;;
  7) process_Nginx ;;
  *)
  esac
done;