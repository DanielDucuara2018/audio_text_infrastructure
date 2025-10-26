# GCP Service Account Credentials

This directory contains your GCP service account JSON key file, which is used by Terraform to authenticate with Google Cloud Platform.

## 🔒 Security Notice

**This file is git-ignored and should NEVER be committed to version control!**

## 📋 Setup Instructions

### 1. Create a Service Account

```bash
# Set your project ID
PROJECT_ID="your-gcp-project-id"

# Create service account
gcloud iam service-accounts create audio-text-terraform \
    --description="Service account for Audio Text infrastructure deployment" \
    --display-name="Audio Text Terraform"
```

### 2. Grant Required Roles

```bash
# Grant necessary permissions
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/redis.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"
```

### 3. Create and Download Key

```bash
# Create JSON key
gcloud iam service-accounts keys create gcp-key.json \
    --iam-account=audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com

# Move to credentials directory
mv gcp-key.json /path/to/audio_text_infrastructure/credentials/
```

### 4. Verify Setup

```bash
# Check if file exists and has correct permissions
ls -la credentials/gcp-key.json

# Test authentication
gcloud auth activate-service-account \
    --key-file=credentials/gcp-key.json

# Verify access
gcloud projects describe ${PROJECT_ID}
```

## 📁 File Structure

After setup, this directory should contain:

```
credentials/
├── README.md         # This file
└── gcp-key.json      # Your service account key (git-ignored)
```

## ✅ Required Roles Summary

The service account needs these roles to provision the infrastructure:

| Role                                   | Purpose                            |
| -------------------------------------- | ---------------------------------- |
| `roles/run.admin`                      | Deploy Cloud Run services          |
| `roles/cloudsql.admin`                 | Manage Cloud SQL instances         |
| `roles/redis.admin`                    | Manage Redis instances             |
| `roles/storage.admin`                  | Manage Cloud Storage buckets       |
| `roles/compute.networkAdmin`           | Manage VPC and networking          |
| `roles/serviceusage.serviceUsageAdmin` | Enable GCP APIs                    |
| `roles/iam.serviceAccountUser`         | Use service accounts for Cloud Run |

## 🔄 Key Rotation

For security, rotate your service account keys regularly:

```bash
# Create new key
gcloud iam service-accounts keys create new-key.json \
    --iam-account=audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com

# Replace old key
mv new-key.json gcp-key.json

# List and delete old keys
gcloud iam service-accounts keys list \
    --iam-account=audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com

gcloud iam service-accounts keys delete KEY_ID \
    --iam-account=audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com
```

## ⚠️ Troubleshooting

**Error: "credentials/gcp-key.json: no such file or directory"**

- Ensure the file is in the correct location
- Check file permissions: `chmod 600 credentials/gcp-key.json`

**Error: "Permission denied"**

- Verify service account has all required roles
- Wait a few minutes for IAM propagation

**Error: "Service account does not exist"**

- Create the service account first
- Verify project ID is correct

## 🗑️ Cleanup

To remove the service account when no longer needed:

```bash
# Delete service account
gcloud iam service-accounts delete \
    audio-text-terraform@${PROJECT_ID}.iam.gserviceaccount.com

# Remove local key file
rm credentials/gcp-key.json
```
