#!/bin/bash

# Function to detect system architecture
detect_system() {
  ARCH=$(uname -m)
  if [[ -f /etc/os-release ]]; then
    ID=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
    case "$ID" in
      ubuntu|debian)
        OS="deb"
        ;;
      amzn|centos|rhel|fedora|sles|opensuse)
        OS="rpm"
        ;;
      *)
        echo "Unsupported OS: $ID"
        exit 1
        ;;
    esac
  else
    echo "Unsupported OS"
    exit 1
  fi

  if [ "$ARCH" == "x86_64" ]; then
    ARCH="x86_64"
  elif [ "$ARCH" == "aarch64" ]; then
    ARCH="aarch64"
  else
    echo "Unsupported architecture"
    exit 1
  fi

  echo "Detected system: $OS, architecture: $ARCH"
}

# Function to install AWS CLI
install_aws_cli() {
  if command -v aws &> /dev/null; then
    echo "AWS CLI is already installed"
    return
  fi

  echo "Installing AWS CLI..."
  if [ "$OS" == "deb" ]; then
    sudo apt-get update
    sudo apt-get install -y curl unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
  elif [ "$OS" == "rpm" ]; then
    sudo yum install -y curl unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to install AWS CLI"
    exit 1
  fi

  echo "AWS CLI installed successfully"
}

# Function to download the package from S3
download_package() {
  PACKAGE_NAME="SentinelAgent_linux_${ARCH}_v24_1_2_6.${OS}"
  S3_BUCKET="sentinelone-installer-agents"
  DOWNLOAD_PATH="/tmp/${PACKAGE_NAME}"

  echo "Downloading package from S3..."
  aws s3 cp "s3://${S3_BUCKET}/linux/${PACKAGE_NAME}" "$DOWNLOAD_PATH"
  if [ $? -ne 0 ]; then
    echo "Failed to download package"
    exit 1
  fi

  echo "Package downloaded to $DOWNLOAD_PATH"
}

# Function to install the package
install_package() {
  PACKAGE_PATH=$1
  if [ "$OS" == "deb" ]; then
    echo "Installing DEB package..."
    sudo dpkg -i "$PACKAGE_PATH"
  elif [ "$OS" == "rpm" ]; then
    echo "Installing RPM package..."
    sudo rpm -i --nodigest "$PACKAGE_PATH"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to install package"
    exit 1
  fi

  echo "Package installed successfully"
}

# Function to fetch the site token from AWS Secrets Manager
fetch_site_token() {
  SECRET_NAME="SentinelOne/SiteToken"
  REGION="us-east-1"

  echo "Fetching site token from AWS Secrets Manager..."
  SITE_TOKEN=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$REGION" --query SecretString --output text | jq -r '.Site_Token')
  if [ $? -ne 0 ]; then
    echo "Failed to fetch site token"
    exit 1
  fi

  echo "Site token fetched successfully"
}

# Function to activate the agent
activate_agent() {
  echo "Activating agent with site token..."
  echo "$SITE_TOKEN"
  sudo /opt/sentinelone/bin/sentinelctl management token set $SITE_TOKEN
  if [ $? -ne 0 ]; then
    echo "Failed to set management token"
    exit 1
  fi

  sudo /opt/sentinelone/bin/sentinelctl control start
  if [ $? -ne 0 ]; then
    echo "Failed to start agent"
    exit 1
  fi

  echo "Agent activated and started successfully"
}

# Main script execution
detect_system
install_aws_cli
download_package
install_package "$DOWNLOAD_PATH"
fetch_site_token
activate_agent

echo "Script execution completed successfully"
