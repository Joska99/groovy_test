#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm search repo ingress-nginx --version "*"

CHART_VERSION="4.9.1"
APP_VERSION="1.9.6"

mkdir ingress_set_up

helm template ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --version ${CHART_VERSION} \
    --namespace ingress-nginx \
    > ./ingress_set_up/nginx_ingress.${APP_VERSION}.yaml

kubectl create namespace ingress-nginx
kubectl apply -f ./ingress_set_up/nginx_ingress.${APP_VERSION}.yaml

kubectl get all -n ingress-nginx


#!  try 
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm install incubator/aws-alb-ingress-controller --set autoDiscoverAwsRegion=true --set autoDiscoverAwsVpcID=true --set clusterName=MyClusterName