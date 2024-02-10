#!/bin/bash

# TODO: Make in "helm template" instalation

git clone https://github.com/kubernetes-sigs/aws-efs-csi-driver.git

cd aws-efs-csi-driver/charts

helm install aws-efs-csi-driver ./aws-efs-csi-driver \
    --namespace kube-system \
    --set efsProvisioner.efsFileSystemId=<EFS_ID>
