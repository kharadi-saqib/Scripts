#!/bin/bash
WEBAPP_FOLDER_NAME=FGICWebApp
DATABASE_URL=postgres://coderize:coderize@localhost:5432/iads
AIRFLOW_DATABASE_URL="postgresql+psycopg2://coderize:coderize@localhost/iads"
GITLAB_USERNAME="gitlab+deploy-token-3719258"
GITLAB_PASSWORD="NqbfDYkKoqt_zPD518b6"

# Check if running with root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script requires sudo access."
    sudo bash "$0" "$@"  # Re-run this script with sudo
    exit $?
fi

LOG_FILE="${PWD}/installation_logs.log"
echo "Starting installation" > $LOG_FILE

export DEBIAN_FRONTEND=noninteractive

# Check python version
PYTHON_VERSION="$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
REQUIRED_PYTHON_VERSION="3.10"

if [[ "$PYTHON_VERSION" == "$REQUIRED_PYTHON_VERSION" ]]
then
   echo -e "\e[32m Python version $REQUIRED_PYTHON_VERSION found \e[0m"
else
   echo -e "\e[31m Python version $REQUIRED_PYTHON_VERSION not found \e[0m"
   exit
fi


# Set up some env variables
echo "Setting up some env variables"
AIRFLOW_HOME=./Airflow

# Install GDAL
echo -e "Enabling GDAL Repository..."
sudo add-apt-repository ppa:ubuntugis/ppa -y >> $LOG_FILE
sudo apt-get update >> $LOG_FILE
echo -e "\e[32mEnabling GDAL Repository...Done \e[0m"

# Beyond this point, if the installation failes, script will be aborted
# set -e 

echo -e "Installing Ubuntu dependecies..."
sudo apt-get -qq install gdal-bin python3-dev libpq-dev libgdal-dev git python3.10-venv -y >> $LOG_FILE
echo -e "Installing some more Ubuntu dependecies..."
sudo apt install python3-dev build-essential libssl-dev -y >> $LOG_FILE
ogrinfo --version
if [ $? -eq 0 ]; then
    echo -e "\e[32mInstalling Ubuntu dependecies...Done \e[0m"
else
    echo -e "\e[31mInstalling Ubuntu dependecies...Failed \e[0m"
    exit
fi

# Install postgis
echo -e "Installing PostGIS..."
sudo apt-get install postgresql postgis -y >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "\e[32mInstalling PostGIS...Done\e[0m"
else
    echo -e "\e[31mInstalling PostGIS...Failed. \e[0m"
    exit
fi

# Clone the repo
echo -e "Cloning Repo..."
rm -rf "$WEBAPP_FOLDER_NAME"
mkdir "$WEBAPP_FOLDER_NAME"
cd "$WEBAPP_FOLDER_NAME"
git clone https://${GITLAB_USERNAME}:${GITLAB_PASSWORD}@gitlab.com/coderizers/fgic.git . >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "\e[32mCloning Repo...Done\e[0m"
else
    echo -e "\e[31mCloning Repo...Failed\e[0m"
    exit
fi

TARGET_FILE="requirements.txt"
if [ -f "$TARGET_FILE" ]
then
    echo -e "\e[32m$TARGET_FILE exists. \e[0m"
else
    echo -e "\e[31m$TARGET_FILE does not exist. \e[0m"
    exit
fi

# Create Virtual Environment
echo -e "Creating Virtual environment..."
rm -rf venv
python3 -m venv venv
if [ $? -eq 0 ]; then
    echo -e "\e[32Creating Virtual environment...Done \e[0m"
else
    echo -e "\e[31mCreating Virtual environment...Failed \e[0m"
    exit
fi

# Install dependecies

source venv/bin/activate
echo -e "Upgrading PIP..."
python -m pip install pip -U >> $LOG_FILE
echo -e "\e[32mUpgrading PIP....Done \e[0m"

echo -e "Upgrading wheel..."
pip install wheel >> $LOG_FILE
echo -e "\e[32mUpgrading wheel....Done \e[0m"

echo -e "Installing Python Dependencies..."
pip install -r requirements.txt >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "\e[32mInstalling Python Dependencies...Done \e[0m"
else
    echo -e "\e[31mInstalling Python Dependencies...Failed \e[0m"
    exit
fi

# Installing Python GDAL library
echo -e "Installing Python GDAL library..."
GDAL_VERSION="$(ogrinfo --version | cut -d " " -f 2 | cut -d "," -f 1)"
echo "GDAL Version $GDAL_VERSION installed"
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install GDAL=="$GDAL_VERSION" >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "\e[32mInstalling Python GDAL library...Done \e[0m"
else
    echo -e "\e[31mInstalling Python GDAL library...Failed \e[0m"
    exit
fi

# Creating some necessary folder
mkdir /home/fgic/DummyData
mkdir /home/fgic/DummyData/HotFolder
mkdir /home/fgic/DummyData/IngestedResource
echo -e "\e[32mCreated Dummy Hot Folder \e[0m"

# Copying the production file
cp .env.production .env
echo -e "\e[32mCopied Environment file \e[0m"

sudo chmod -R 777 ../FGICWebApp/
echo -e "DATABASE_URL=$DATABASE_URL" >> .env

# Change DATABASE URL in Airflow
old_text="postgresql+psycopg2://coderize:coderize@localhost/iads"
sed -i "s#$old_text#$AIRFLOW_DATABASE_URL#g" "Airflow/airflow.cfg"

# Run Migrations
echo -e "Starting Django migrations..."
python manage.py migrate >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "\e[32mStarting Django migrations...Done \e[0m"
else
    echo -e "\e[31mStarting Django migrations...Failed \e[0m"
    exit
fi

echo -e "Starting Airflow migrations..."
export AIRFLOW_HOME=/home/fgic/FGICWebApp/Airflow
airflow db migrate >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo -e "\e[32mStarting Airflow migrations...Done \e[0m"
else
    echo -e "\e[31mStarting Airflow migrations...Failed \e[0m"
    exit
fi

airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin
if [ $? -eq 0 ]; then
    echo -e "\e[32mAirflow User created. \e[0m"
else
    echo -e "\e[31mAirflow User creation failed. \e[0m"
    exit
fi

sudo cp Scripts/airflow-webserver.service /etc/systemd/system/
sudo cp Scripts/airflow-scheduler.service /etc/systemd/system/
if [ $? -eq 0 ]; then
    echo -e "\e[32mService file copied \e[0m"
else
    echo -e "\e[31mService file failed to copy \e[0m"
    exit
fi

# Change Ownership of folder to fgic user
echo -e "Changing Ownership of folder..."
cd ..
sudo chown -R fgic FGICWebApp/
echo -e "\e[32mChanging Ownership of folder...Done\e[0m"

echo "Starting service"
sudo systemctl daemon-reload

sudo systemctl restart airflow-webserver.service
if [ $? -eq 0 ]; then
    echo -e "\e[32mService Airflow Webserver started \e[0m"
else
    echo -e "\e[31mService Airflow Webserver failed to start \e[0m"
    exit
fi

sudo systemctl restart airflow-scheduler.service
if [ $? -eq 0 ]; then
    echo -e "\e[32mService Airflow Schduler started \e[0m"
else
    echo -e "\e[31mService Airflow Schduler failed to start \e[0m"
    exit
fi


# Install Grafana
echo "Installing Grafana"
sudo apt install -y software-properties-common

echo "Adding Repository"
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

echo "Importing Key"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "Updating"
sudo apt update >> $LOG_FILE

echo "Installing Grafana"
sudo apt install -y grafana

echo "Enabling Service"
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
