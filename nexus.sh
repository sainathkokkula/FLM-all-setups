sudo yum update -y
sudo yum install wget -y
sudo yum install java-17-amazon-corretto-jmods -y

# Create app directory
sudo mkdir /app && cd /app

# Download Nexus 3.83.0-08
sudo wget https://download.sonatype.com/nexus/3/nexus-3.83.0-08-linux-x86_64.tar.gz

# Extract the tar file
sudo tar -xvf nexus-3.83.0-08-linux-x86_64.tar.gz

# Rename extracted folder to nexus
sudo mv nexus-3.83.0-08 nexus

# Create nexus user and set permissions
sudo adduser nexus
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype*

# Update nexus run_as_user
sudo sed -i '27 s/^#run_as_user.*/run_as_user="nexus"/' /app/nexus/bin/nexus

# Create systemd service file
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Enable and start Nexus service
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus
