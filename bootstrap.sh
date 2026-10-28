#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="${CHART_VERSION:-latest}"          # same for both charts
APP_ID="${APP_ID:?set APP_ID}"
INSTALLATION_ID="${INSTALLATION_ID:?set INSTALLATION_ID}"
PEM_PATH="${PEM_PATH:?set PEM_PATH}"

OCI=oci://ghcr.io/actions/actions-runner-controller-charts

helm upgrade --install arc "$OCI/gha-runner-scale-set-controller" \
  --version "$CHART_VERSION" -n arc-systems --create-namespace --wait

kubectl apply -f namespace.yaml

kubectl create secret generic github-app -n arc-runners \
  --from-literal=github_app_id="$APP_ID" \
  --from-literal=github_app_installation_id="$INSTALLATION_ID" \
  --from-file=github_app_private_key="$PEM_PATH" \
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install arc-runner-set "$OCI/gha-runner-scale-set" \
  --version "$CHART_VERSION" -n arc-runners \
  -f values.yaml