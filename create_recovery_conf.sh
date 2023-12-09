#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root using sudo."
  exit 1
fi

# Set the file path
recovery_conf_path="/var/lib/postgresql/14/main/recovery.conf"

# Define primary connection information
primary_host="primary_server"
primary_port="5432"
replicator_user="replicator"
replicator_password="replicator"
trigger_file_path="/path/to/trigger/file"

# Specify the content with predefined values
recovery_conf_content=$(cat <<EOF
standby_mode = 'on'
primary_conninfo = 'host=$primary_host port=$primary_port user=$replicator_user password=$replicator_password'
trigger_file = '$trigger_file_path'
EOF
)

# Use sudo to create the recovery.conf file
echo "$recovery_conf_content" | sudo tee "$recovery_conf_path" > /dev/null

# Provide feedback
echo "Recovery.conf file created at: $recovery_conf_path"
