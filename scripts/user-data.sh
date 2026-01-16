#!/bin/bash
# Purpose: Bootstrap EC2 instance, install Web Server, and fetch DB secrets
# Author: [Your Name]

# 1. Update and Install Dependencies
dnf update -y
dnf install -y httpd python3-pip aws-cli jq

# 2. Start Web Server
systemctl start httpd
systemctl enable httpd

# 3. Retrieve Secrets from AWS Secrets Manager
# Note: Ensure the IAM Role attached to this instance has 'secretsmanager:GetSecretValue' permissions
SECRET_NAME="prod/app/db-creds"
REGION="us-east-1"

# Fetch the raw JSON secret
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --region $REGION --query SecretString --output text)

# Parse username and password (requires 'jq' if doing complex parsing, or Python)
# For this demo, we verify connectivity by simply logging that we retrieved it successfully
if [ -n "$SECRET_JSON" ]; then
    STATUS="Database Connection Securely Retrieved via Secrets Manager"
else
    STATUS="Error: Could not retrieve database credentials"
fi

# 4. Deploy Application Code (Simple HTML for Demo)
# We use the Instance ID to demonstrate which server is responding (Load Balancing proof)
INSTANCE_ID=$(ec2-metadata -i | cut -d " " -f 2)
AZ=$(ec2-metadata -z | cut -d " " -f 2)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Production Web App</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .card { box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2); transition: 0.3s; width: 50%; margin: auto; padding: 20px; border-radius: 10px; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="card">
        <h1>AWS 3-Tier Web Application</h1>
        <p>This request was handled by:</p>
        <h3>Instance ID: $INSTANCE_ID</h3>
        <h3>Zone: $AZ</h3>
        <hr>
        <p>Database Status: <span class="status">$STATUS</span></p>
    </div>
</body>
</html>
EOF
