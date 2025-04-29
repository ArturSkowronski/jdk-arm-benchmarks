#!/bin/bash

# Script to automate creation of a Google Tau T2A (Arm-based) VM instance using gcloud CLI.
# Usage:
#   ./create_tau2_instance.sh <PROJECT_ID> <ZONE> [NETWORK] [SUBNET]
#
# Example:
#   ./create_tau2_instance.sh my-gcp-project us-central1-a
#   ./create_tau2_instance.sh my-gcp-project us-central1-a my-network my-subnet

set -e

PROJECT_ID="$1"
ZONE="$2"
NETWORK="$3"
SUBNET="$4"
INSTANCE_NAME="test-tau2-instance"
IMAGE_FAMILY="ubuntu-2404-lts-arm64"
IMAGE_PROJECT="ubuntu-os-cloud"
MACHINE_TYPE="t2a-standard-2"
TAGS="http-server"

if [[ -z "$PROJECT_ID" || -z "$ZONE" ]]; then
  echo "Usage: $0 <PROJECT_ID> <ZONE> [NETWORK] [SUBNET]"
  exit 1
fi

echo "Setting gcloud project to $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

CREATE_CMD="gcloud compute instances create $INSTANCE_NAME \
  --image-family=$IMAGE_FAMILY \
  --image-project=$IMAGE_PROJECT \
  --machine-type=$MACHINE_TYPE \
  --scopes userinfo-email,cloud-platform \
  --zone $ZONE \
  --tags $TAGS"

if [[ -n "$NETWORK" ]]; then
  CREATE_CMD="$CREATE_CMD --network=$NETWORK"
  if [[ -n "$SUBNET" ]]; then
    CREATE_CMD="$CREATE_CMD --subnet=$SUBNET"
  fi
fi

echo "Creating Tau T2A VM instance: $INSTANCE_NAME"
eval $CREATE_CMD

# Configure firewall rule for port 8080
FIREWALL_CMD="gcloud compute firewall-rules create default-allow-http-8080 \
  --allow tcp:8080 \
  --source-ranges 0.0.0.0/0 \
  --target-tags $TAGS \
  --description \"Allow port 8080 access to http-server\""

if [[ -n "$NETWORK" ]]; then
  FIREWALL_CMD="$FIREWALL_CMD --network=$NETWORK"
fi

echo "Configuring firewall rule for port 8080"
eval $FIREWALL_CMD || echo "Firewall rule may already exist, continuing..."

# List instances and extract external IP
echo "Listing instances to obtain external IP:"
gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format="table[box](name,zone,machineType,internal_ip,external_ip,status)"
