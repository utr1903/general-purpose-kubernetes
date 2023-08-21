#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --type)
      type="${2}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set variables

if [[ $type == "aks" ]]; then
  clusterName="my-dope-aks"
else
  echo "Cluster type is not supported."
  exit 1
fi

# New Relic OTLP endpoint
newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"

# otelcollectors
declare -A otelcollectors
otelcollectors["name"]="nrotelk8s"
otelcollectors["namespace"]="monitoring"

###################
### Deploy Helm ###
###################

helm upgrade ${otelcollectors[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${otelcollectors[namespace]} \
  --set clusterName=$clusterName \
  --set global.newrelic.enabled=true \
  --set global.newrelic.endpoint=$newrelicOtlpEndpoint \
  --set global.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY_OPSTEAM \
  --version "0.1.0" \
  "newrelic-experimental/nrotelk8s"
