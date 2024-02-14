#!/bin/bash

# Add repo and search for a latest or needed version
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm search repo ingress-nginx --version "*"

# Provide variables
CHART_VERSION="4.9.1"
APP_VERSION="1.9.6"

# Create working directory
mkdir ingress_set_up

# Generate chart template "name.version.yaml"
helm template ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --version ${CHART_VERSION} \
    --namespace ingress-nginx \
    > ./ingress_set_up/nginx_ingress.${APP_VERSION}.yaml

# Create ns for ingreess controller and apply
kubectl create namespace ingress-nginx
kubectl apply -f ./ingress_set_up/nginx_ingress.${APP_VERSION}.yaml

# Check nohePort opened for this controller
kubectl get all -n ingress-nginx
# And Forwar LoadBalancer to those ports
