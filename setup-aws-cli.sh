# IMPORTANT: Needs to be done in the root directory /
BACK=$(pwd)
cd /

# Install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
sudo aws configure # Get keys from our project shared folder in OneDrive (accounts.txt)

cd "$BACK"