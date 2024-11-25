#!/bin/bash

# Enable IAM roles for service accounts
echo "Enabling IAM roles for service accounts..."
kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=arn:aws:iam::162186035982:role/eksctl-DevSecOps-Cluster-nodegroup-NodeInstanceRole-7Zmw6DdFYKT8

# Restrict public access to the EKS API
echo "Restricting public access to the EKS API..."
aws eks update-cluster-config --name DevSecOps-Cluster --resources-vpc-config endpointPublicAccess=false,endpointPrivateAccess=true

# Applying PodSecurityPolicy (optional - deprecated in Kubernetes 1.21+)
# Uncomment below if PSP is required
# echo "Applying PodSecurityPolicy..."
# kubectl apply -f https://path-to-valid-pod-security-policy.yaml

# Enable Secrets Encryption (only works during cluster creation)
echo "Note: Secrets encryption cannot be enabled for an existing cluster. Skip this step."

# Confirm completion
echo "EKS hardening script completed."

