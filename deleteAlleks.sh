#!/bin/bash

# Set the AWS region
REGION="us-east-1"

# Get a list of all EKS clusters in the specified region
CLUSTERS=$(aws eks list-clusters --region $REGION --query 'clusters' --output text)

# Check if any clusters were found
if [ -z "$CLUSTERS" ]; then
  echo "No EKS clusters found in region $REGION."
  exit 0
fi

# Loop through each cluster
for CLUSTER in $CLUSTERS; do
  echo "Processing cluster: $CLUSTER"

  # Get a list of all node groups for the current cluster
  NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER --region $REGION --query 'nodegroups' --output text)

  # Loop through each node group
  for NODE_GROUP in $NODE_GROUPS; do
    echo "Deleting node group: $NODE_GROUP from cluster: $CLUSTER"

    # Delete the node group
    aws eks delete-nodegroup --cluster-name $CLUSTER --nodegroup-name $NODE_GROUP --region $REGION

    # Wait for the node group to be deleted
    echo "Waiting for node group $NODE_GROUP to be deleted..."
    aws eks wait nodegroup-deleted --cluster-name $CLUSTER --nodegroup-name $NODE_GROUP --region $REGION
  done

  # Delete the cluster
  echo "Deleting cluster: $CLUSTER"
  aws eks delete-cluster --name $CLUSTER --region $REGION

  # Wait for the cluster to be deleted
  echo "Waiting for cluster $CLUSTER to be deleted..."
  aws eks wait cluster-deleted --name $CLUSTER --region $REGION

  echo "Cluster $CLUSTER and its node groups have been deleted."
done

echo "All clusters and node groups in region $REGION have been deleted."
