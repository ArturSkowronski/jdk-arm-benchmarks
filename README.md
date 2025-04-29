# ARM Java Benchmarks

This benchmark suite was created for the Devoxx UK presentation **"Running Java on ARM - is it worth it?"** comparing performance and cost efficiency of Java applications across ARM-based cloud instances.

## Project Overview
Automated infrastructure and benchmarking tools for comparing:
- Google Cloud Axion/Tau instances
- AWS Graviton instances (1-4)
- Azure Ampere Altra instances

Includes full-stack automation for:
- Cloud instance provisioning
- Java application deployment
- JMeter performance testing
- JVM optimization analysis

## Quick Start

### Prerequisites
- Cloud accounts (GCP, AWS, Azure)
- Cloud CLIs installed (`gcloud`, `aws`, `az`)
- SSH keys configured for each cloud

```bash
# Clone repo
git clone https://github.com/yourusername/jdk-arm-benchmarks.git
cd jdk-arm-benchmarks
```

### Basic Usage
**GCP Example:**
```bash
# Create Axion instance
infra/gcp/create_axion_instance.sh YOUR_PROJECT_ID us-central1-a

# Install Petclinic + JMeter
infra/gcp/install_petclinic.sh [EXTERNAL_IP] ~/.ssh/google_key ubuntu
```

**AWS Example:**
```bash
# Create Graviton3 instance 
infra/aws/create_graviton3_instance.sh us-east-1 my-key sg-xxxx subnet-xxxx

# Install tools
infra/aws/install_petclinic.sh [EXTERNAL_IP] ~/.ssh/aws_key.pem ubuntu
```

**Azure Example:**
```bash
# Create ARM VM
infra/azure/create_arm_vm.sh myResourceGroup test-vm eastus adminuser ~/.ssh/azure_key.pub

# Deploy stack
infra/azure/install_petclinic.sh [EXTERNAL_IP] ~/.ssh/azure_key.pub azureuser
```

## Presentation Assets
This benchmark suite was developed for **Devoxx UK** to demonstrate:
- ARM vs x86 price/performance ratios
- JVM optimization techniques
- Cloud-specific ARM implementations
- Real-world Spring Boot performance

![ARM Architecture](https://i.imgur.com/7Qoulnk.jpeg)  
*Comparative architecture diagram from presentation*

## License
Apache 2.0 License
