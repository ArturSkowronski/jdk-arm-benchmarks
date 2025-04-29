#!/bin/bash

# Script to automate creation of an Azure Arm-based VM (Ampere Altra, e.g., Standard_D4ps_v5) using Azure CLI.
# Usage:
#   ./create_arm_vm.sh <RESOURCE_GROUP> <VM_NAME> <LOCATION> <ADMIN_USERNAME> <SSH_KEY_PATH> [VNET_NAME] [SUBNET_NAME] [IMAGE] [SIZE]
#
# Example:
#   ./create_arm_vm.sh myResourceGroup test-arm-vm eastus myuser ~/.ssh/id_rsa.pub

set -e

RESOURCE_GROUP="$1"
VM_NAME="$2"
LOCATION="$3"
ADMIN_USERNAME="$4"
SSH_KEY_PATH="$5"
VNET_NAME="$6"
SUBNET_NAME="$7"
IMAGE="${8:-"Canonical:0001-com-ubuntu-server-jammy:22_04-lts-arm64:latest"}"
SIZE="${9:-"Standard_D4ps_v5"}"

if [[ -z "$RESOURCE_GROUP" || -z "$VM_NAME" || -z "$LOCATION" || -z "$ADMIN_USERNAME" || -z "$SSH_KEY_PATH" ]]; then
  echo "Usage: $0 <RESOURCE_GROUP> <VM_NAME> <LOCATION> <ADMIN_USERNAME> <SSH_KEY_PATH> [VNET_NAME] [SUBNET_NAME] [IMAGE] [SIZE]"
  exit 1
fi

CREATE_CMD="az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --location $LOCATION \
  --image $IMAGE \
  --size $SIZE \
  --admin-username $ADMIN_USERNAME \
  --ssh-key-values $SSH_KEY_PATH"

if [[ -n "$VNET_NAME" ]]; then
  CREATE_CMD="$CREATE_CMD --vnet-name $VNET_NAME"
fi

if [[ -n "$SUBNET_NAME" ]]; then
  CREATE_CMD="$CREATE_CMD --subnet $SUBNET_NAME"
fi

echo "Creating Azure Arm-based VM: $VM_NAME in $LOCATION"
VM_JSON=$(eval $CREATE_CMD)

PUBLIC_IP=$(echo "$VM_JSON" | grep -o '"publicIpAddress": *"[^"]*"' | head -n1 | cut -d'"' -f4)

echo "VM $VM_NAME created. Public IP: $PUBLIC_IP"
