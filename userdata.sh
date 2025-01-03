#!/bin/sh
apt update
apt install -y apache2

# Fetch instance Id using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install AWS CLI
apt install -y awscli

# Download the images from s3 bucket
# aws s3 cp s3/bucketnmae/.....

# create a simple html page

<!DOCTYPE html>
<html>
<body>

<h1>My Terraform with AWS Project</h1>

<h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>

<p>Welcome to Nilam Patel Terraform with AWS project</p>

</body>
</html>

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2