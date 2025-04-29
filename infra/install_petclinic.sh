#!/bin/bash

# Script to remotely install Java, deploy Spring Petclinic, and install JMeter on an AWS EC2 VM via SSH

# Usage:
#   ./install_petclinic.sh <EXTERNAL_IP> <SSH_KEY_PATH> <USERNAME>
#
# Example:
#   ./install_petclinic.sh 3.123.45.67 ~/.ssh/my-aws-key.pem ubuntu

set -e

EXTERNAL_IP="$1"
SSH_KEY_PATH="$2"
USERNAME="$3"

if [[ -z "$EXTERNAL_IP" || -z "$SSH_KEY_PATH" || -z "$USERNAME" ]]; then
  echo "Usage: $0 <EXTERNAL_IP> <SSH_KEY_PATH> <USERNAME>"
  exit 1
fi

echo "Connecting to $USERNAME@$EXTERNAL_IP to install Java, Petclinic, and JMeter..."

ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "$USERNAME@$EXTERNAL_IP" bash <<'EOF'
set -e
echo "Updating apt..."
sudo apt update

echo "Installing default-jre..."
sudo apt install -y default-jre

echo "Verifying Java installation..."
java -version

echo "Installing default-jdk..."
sudo apt install -y default-jdk

echo "Verifying JDK installation..."
javac -version

echo "Cloning Spring Petclinic repository..."
git clone https://github.com/spring-projects/spring-petclinic.git

cd spring-petclinic

echo "Building Spring Petclinic with Maven Wrapper..."
./mvnw package

echo "Build complete."

echo "Installing Apache JMeter..."
cd ~
wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz
sudo mv apache-jmeter-5.6.3 /opt/jmeter
sudo ln -sf /opt/jmeter/bin/jmeter /usr/local/bin/jmeter

echo "Verifying JMeter installation..."
jmeter --version

echo "JMeter installed successfully."

echo "To run the Petclinic application, execute in one terminal:"
echo "  cd ~/spring-petclinic"
echo "  java -jar target/*.jar"
echo "Then, in another terminal, run the JMeter test plan:"
echo "  cd ~/spring-petclinic/src/test/jmeter"
echo "  jmeter -n -t petclinic_test_plan.jmx -l results1.jtl"
echo "To generate a summary report:"
echo "  jmeter -g results1.jtl -o ./summary_report1"
echo "Access the app at: http://$EXTERNAL_IP:8080"
EOF
