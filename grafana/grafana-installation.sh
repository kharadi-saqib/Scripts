# Install Grafana
echo "Installing Grafana"
sudo apt install software-properties-common -y

echo "Adding Repository"
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

echo "Importing Key"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

echo "Updating"
sudo apt update

echo "Installing Grafana"
sudo apt install grafana -y

echo "Enabling Service"
sudo systemctl start grafana-server
sudo systemctl enable grafana-server