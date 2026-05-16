#!/bin/bash

# Terraform Developer Setup Script for home-ops
echo "Setting up Terraform developer environment for home-ops..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed. Please install Terraform first."
    echo "Visit https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"
    exit 1
fi

echo "Terraform is installed: $(terraform --version)"

# Change to terraform directory
cd "$(dirname "$0")" || exit 1

# Check for required files and create templates if missing
if [[ ! -f "backend.tfvars" ]]; then
    echo "Creating backend.tfvars template..."
    cat > backend.tfvars << 'EOF'
bucket = "your-terraform-state-bucket"
key    = "path/to/your/terraform.tfstate"
region = "your-aws-region"
access_key = "your-aws-access-key"
secret_key = "your-aws-secret-key"
EOF
    echo "Please edit backend.tfvars with your actual values"
else
    echo "backend.tfvars already exists"
fi

if [[ ! -f "terraform.tfvars" ]]; then
    echo "Creating terraform.tfvars template..."
    cat > terraform.tfvars << 'EOF'
# AWS Configuration
aws_access_key_id     = "your-aws-access-key"
aws_secret_access_key = "your-aws-secret-key"
aws_region            = "your-aws-region"
aws_region_lambda     = "your-aws-lambda-region"

# Lambda Function
aws_lambda_function_name     = "your-lambda-function-name"
aws_access_key_id_lambda     = "your-lambda-aws-access-key"
aws_secret_access_key_lambda = "your-lambda-aws-secret-key"

# Telegram Bot
bot_token = "your-telegram-bot-token"
chat_id   = "your-telegram-chat-id"

# NFS Configuration
nfs_server = "your-nfs-server-ip"
nfs_share  = "/your/nfs/share/path"

# Base URLs
base_url_portfolio = "your-portfolio-domain"
base_url_private   = ".local"
base_url_public    = "your-public-domain"

# Cloudflare (uncomment and set if needed)
# cloudflare_api_token = "your-cloudflare-api-token"
EOF
    echo "Please edit terraform.tfvars with your actual values"
else
    echo "terraform.tfvars already exists"
fi

# Initialize Terraform
echo "Initializing Terraform backend..."
terraform init -backend-config="./backend.tfvars"

echo ""
echo "Setup complete! Next steps:"
echo "1. Edit backend.tfvars with your actual AWS credentials and bucket info"
echo "2. Edit terraform.tfvars with your actual configuration values"
echo "3. Run 'terraform apply' to deploy the infrastructure"
echo ""
echo "Important: Never commit your actual credentials to version control!"
echo "The .gitignore should prevent tfvars files from being committed."