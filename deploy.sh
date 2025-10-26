#!/bin/bash
# Quick deployment helper script for Audio Text Infrastructure

set -e

echo "════════════════════════════════════════════════════════"
echo "  Audio Text Infrastructure Deployment Helper"
echo "════════════════════════════════════════════════════════"
echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found!"
    echo ""
    echo "Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "✅ Created terraform.tfvars"
    echo ""
    echo "Please edit terraform.tfvars with your configuration:"
    echo "  nano terraform.tfvars"
    echo ""
    exit 1
fi

# Check if credentials exist
if [ ! -f "credentials/gcp-key.json" ]; then
    echo "⚠️  GCP credentials not found!"
    echo ""
    echo "Please place your service account key at:"
    echo "  credentials/gcp-key.json"
    echo ""
    echo "See credentials/README.md for instructions"
    exit 1
fi

echo "✅ Configuration files found"
echo ""

# Parse command
case "${1:-deploy}" in
    init)
        echo "🔧 Initializing Terraform..."
        terraform init
        ;;
    
    plan)
        echo "📋 Planning infrastructure changes..."
        terraform fmt
        terraform validate
        terraform plan
        ;;
    
    deploy)
        echo "🚀 Deploying infrastructure..."
        terraform fmt
        terraform validate
        terraform plan
        echo ""
        read -p "Continue with deployment? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform apply
            echo ""
            echo "════════════════════════════════════════════════════════"
            echo "  ✨ Infrastructure Deployed!"
            echo "════════════════════════════════════════════════════════"
            echo ""
            echo "Next steps:"
            echo "1. Configure Cloudflare DNS:"
            echo "   terraform output cloudflare_dns_records"
            echo ""
            echo "2. Deploy frontend:"
            echo "   cd ../audio_text_frontend && ./scripts/deploy-cloud.sh"
            echo ""
            echo "3. Deploy backend:"
            echo "   cd ../audio_text_backend && ./scripts/deploy-cloud.sh -p PROJECT_ID"
            echo ""
        fi
        ;;
    
    outputs)
        echo "📤 Infrastructure outputs:"
        terraform output
        ;;
    
    cloudflare)
        echo "☁️  Cloudflare DNS Configuration:"
        terraform output cloudflare_dns_records
        ;;
    
    destroy)
        echo "⚠️  WARNING: This will destroy all infrastructure!"
        echo ""
        terraform plan -destroy
        echo ""
        read -p "Are you SURE you want to destroy everything? (yes/N) " -r
        echo
        if [[ $REPLY == "yes" ]]; then
            terraform destroy
        else
            echo "Cancelled"
        fi
        ;;
    
    *)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  init        Initialize Terraform"
        echo "  plan        Preview infrastructure changes"
        echo "  deploy      Deploy infrastructure (default)"
        echo "  outputs     Show infrastructure outputs"
        echo "  cloudflare  Show Cloudflare DNS configuration"
        echo "  destroy     Destroy all infrastructure"
        echo ""
        echo "Examples:"
        echo "  $0           # Deploy infrastructure"
        echo "  $0 plan      # Preview changes"
        echo "  $0 outputs   # Show outputs"
        ;;
esac
