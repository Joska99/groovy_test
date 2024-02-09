#*2

# Get EKS kubeconf to connect to remote EKS
aws eks update-kubeconfig --region us-east-1 --name my-k8s
# It will ad to ~/.kube/config

# If you have authN erro
# 1. Upgrade Kubectl to latest
# 2. Upgrade AWS CLI to latest
# 3. Change in kubeconfig alpha > beta
# sed -i -e "s,client.authentication.k8s.io/v1alpha1,client.authentication.k8s.io/v1beta1,g" ~/.kube/config