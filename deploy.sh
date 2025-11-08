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

# Function to enable required GCP APIs
enable_apis() {
    echo "🔌 Checking and enabling required GCP APIs..."
    echo ""
    
    # Required APIs for the infrastructure
    REQUIRED_APIS=(
        "run.googleapis.com"                    # Cloud Run (for API/Worker services)
        "sqladmin.googleapis.com"               # Cloud SQL (PostgreSQL database)
        "redis.googleapis.com"                  # Memorystore Redis
        "compute.googleapis.com"                # Compute Engine (required for VPC, networking)
        "vpcaccess.googleapis.com"              # VPC Access (for private networking)
        "servicenetworking.googleapis.com"      # Service Networking (for Cloud SQL private IP)
        "storage-api.googleapis.com"            # Cloud Storage (for audio files & frontend)
        "storage-component.googleapis.com"      # Storage Component
        "secretmanager.googleapis.com"          # Secret Manager (for AWS credentials)
        "cloudbuild.googleapis.com"             # Cloud Build (for building Docker images)
        "cloudresourcemanager.googleapis.com"   # Resource Manager (for project management)
    )
    
    # Enable all APIs at once (more efficient)
    echo "Enabling APIs..."
    gcloud services enable "${REQUIRED_APIS[@]}" --quiet
    
    echo ""
    echo "✅ All required APIs enabled"
    echo ""
}

# Parse command
case "${1:-deploy}" in
    init)
        echo "🔧 Initializing Terraform..."
        enable_apis
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
        enable_apis
        terraform fmt
        terraform validate
        terraform apply
        
        # Check if terraform apply was successful
        if [ $? -eq 0 ]; then
            echo ""
            echo "════════════════════════════════════════════════════════"
            echo "  ✨ Infrastructure Deployed!"
            echo "════════════════════════════════════════════════════════"
            echo ""
            echo "Next steps:"
            echo "1. View infrastructure outputs:"
            echo "   terraform output"
            echo ""
            echo "2. Deploy backend services:"
            echo "   cd ../audio_text_backend && ./scripts/deploy-cloud.sh -p PROJECT_ID"
            echo ""
            echo "3. Deploy frontend:"
            echo "   cd ../audio_text_frontend && npm run build"
            echo "   gsutil -m rsync -r -d build gs://PROJECT_ID-frontend"
            echo ""
        fi
        ;;
    
    outputs)
        echo "📤 Infrastructure outputs:"
        terraform output
        ;;
    
    enable-apis)
        enable_apis
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
        echo "  init        Initialize Terraform and enable APIs"
        echo "  plan        Preview infrastructure changes"
        echo "  deploy      Deploy infrastructure (default)"
        echo "  outputs     Show infrastructure outputs"
        echo "  enable-apis Enable required GCP APIs"
        echo "  destroy     Destroy all infrastructure"
        echo ""
        echo "Examples:"
        echo "  $0              # Deploy infrastructure"
        echo "  $0 init         # Initialize Terraform"
        echo "  $0 plan         # Preview changes"
        echo "  $0 enable-apis  # Just enable APIs"
        echo "  $0 outputs      # Show outputs"
        ;;
esac
