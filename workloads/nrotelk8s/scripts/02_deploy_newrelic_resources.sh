#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --type)
      type="${2}"
      shift
      ;;
    --destroy)
      flagDestroy="true"
      shift
      ;;
    --dry-run)
      flagDryRun="true"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set variables

# cluster name
if [[ $type == "aks" ]]; then
  clusterName="my-dope-aks"
else
  echo "Cluster type is not supported."
  exit 1
fi

if [[ $flagDestroy != "true" ]]; then

  # Initialize Terraform
  terraform -chdir=../terraform init

  # Plan Terraform
  terraform -chdir=../terraform plan \
    -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID_OPSTEAM \
    -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
    -var NEW_RELIC_REGION=$NEWRELIC_REGION \
    -var cluster_name=$clusterName \
    -out "./tfplan"

  # Apply Terraform
  if [[ $flagDryRun != "true" ]]; then
    terraform -chdir=../terraform apply tfplan
  fi
else

  # Destroy Terraform
  terraform -chdir=../terraform destroy \
    -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID_OPSTEAM \
    -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
    -var NEW_RELIC_REGION=$NEWRELIC_REGION \
    -var cluster_name=$clusterName
fi
