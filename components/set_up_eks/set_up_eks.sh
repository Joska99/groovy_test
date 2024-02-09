#!/bin/bash

# Steps from this guide
#! https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html

#*1

#  Create EKS stack
aws cloudformation create-stack \
    --region us-east-1 \
    --stack-name my-eks \
    --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml

# Create Role for EKS and Attach it
aws iam create-role \
    --role-name myAmazonEKSClusterRole \
    --assume-role-policy-document file://"eks_policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name myAmazonEKSClusterRole
