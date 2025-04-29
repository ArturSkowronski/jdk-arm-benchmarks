#!/bin/bash

# Script to automate creation of an AWS Graviton3 (c7g) instance using AWS CLI.
# Usage:
#   ./create_graviton3_instance.sh <REGION> <KEY_NAME> <SECURITY_GROUP_ID> <SUBNET_ID> [AMI_ID]
#
# Example:
#   ./create_graviton3_instance.sh us-east-1 my-key sg-0123456789abcdef0 subnet-0123456789abcdef0

set -e

REGION="$1"
KEY_NAME="$2"
SECURITY_GROUP_ID="$3"
SUBNET_ID="$4"
AMI_ID="$5"
INSTANCE_TYPE="c7g.medium"
INSTANCE_NAME="test-graviton3-instance"

# Default Amazon Linux 2023 ARM64 AMI for us-east-1 (update as needed for other regions)
DEFAULT_AMI="ami-0c101f26f147fa7fd"

if [[ -z "$REGION" || -z "$KEY_NAME" || -z "$SECURITY_GROUP_ID" || -z "$SUBNET_ID" ]]; then
  echo "Usage: $0 <REGION> <KEY_NAME> <SECURITY_GROUP_ID> <SUBNET_ID> [AMI_ID]"
  exit 1
fi

if [[ -z "$AMI_ID" ]]; then
  AMI_ID="$DEFAULT_AMI"
fi

echo "Launching Graviton3 (c7g.medium) instance in $REGION..."

INSTANCE_ID=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --subnet-id "$SUBNET_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Waiting for instance $INSTANCE_ID to be running..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Instance $INSTANCE_ID launched. Public IP: $PUBLIC_IP"
