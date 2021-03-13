#!/bin/bash

while [[ "$#" -gt 0 ]]; do case $1 in
  -d|--dry-run) DRY_RUN="--dry-run";;
  -n|--name) NAME="$2"; shift;;
  *) echo "Error, unknown parameter passed: $1."; exit 1;;
esac; shift; done

# Check to see if the name has been given
if [[ -z ${NAME} ]] || [[ ${NAME} =~ ^-.* ]];
  then echo "Error, --name is not given. Aborting.."; exit 1;
fi

echo "Creating app with name $NAME"
echo "Dry run settings set to $DRY_RUN"

############################################

## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Ensure that our repo is up to date
helm repo update

############################################

# Ensure that we have an nginx ingress controller on the cluster
helm install stable/nginx-ingress --name nginx-ingress ${DRY_RUN}

echo "
######################################
Created the nginx-ingress
######################################
"

## IMPORTANT: you MUST install the cert-manager CRDs **before** installing the
## cert-manager Helm chart
kubectl apply  \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml

# Create a namespace to run cert-manager in
kubectl create namespace cert-manager ${DRY_RUN}

## IMPORTANT: if the cert-manager namespace **already exists**, you MUST ensure
## it has an additional label on it in order for the deployment to succeed
 kubectl label namespace cert-manager certmanager.k8s.io/disable-validation="true" ${DRY_RUN}

## Install the cert-manager helm chart
helm install --name cert-manager ${DRY_RUN} --namespace cert-manager jetstack/cert-manager \
	--set ingressShim.defaultIssuerName=letsencrypt-prod \
   	--set ingressShim.defaultIssuerKind=ClusterIssuer

echo "
######################################
Created the cert-manager
######################################
"

# Install the cluster issuer
kubectl apply -f cluster-issuer-prod.yaml ${DRY_RUN}


# Install the helm chart, expects to be in the current directory
helm install --name ${NAME} ${DRY_RUN} .

echo "
######################################
Created the app 
######################################
"

echo "

kubectl get svc
