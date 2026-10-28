# ARC Config

This is our internal ARC runner config, but it may prove useful to others. We add Docker and GH CLI so that our build pipelines can publish container images to GitHub.

### Prerequisites
```bash
# A Kubernetes cluster
kubectl version --client

# 3.x
helm version

# A GitHub App or the ability to create one, installed on the account or org where you plan on installing the runners to
```

## Setup

### Step 1
Create a GitHub App for your org/account(wherever you intend to install it) with the following settings:
|Setting|	Value|
| ------ | ------ |
|GitHub App name|	anything unique, e.g. arc-homelab|
|Homepage URL|	required but unused; any valid URL (your repo works)|
|Callback URL|	leave blank|
|Request user authorization (OAuth) during installation|	unchecked|
|Enable Device Flow|	unchecked|
|Setup URL|	blank|
|Webhook → Active|	unchecked (ARC polls GitHub; it doesn’t receive webhooks)|
|Where can this app be installed|	Only on this account|

### Step 2
Set these under `Permissions & Events`:

Repository permissions: 
- Administration: Read and write (required for repo-level runners)
- Metadata: Read-only (selected automatically)

Organization permissions:
- Self-hosted runners: Read and write (required for org-level runners)

If you are setting this per-repo, skip the org permission, and vice versa.

### Step 3
The three values you need:

- App ID: the numeric ID at the top of the app’s settings page. Use this, not the Client ID.
- Private key: click Generate a private key on the same page. A .pem file downloads.
- Installation ID: install the app first (Install App in the left sidebar, choose the account/org, and select the repos or all repos). After installing, the ID is the number at the end of the URL: github.com/settings/installations/<ID> for a personal account, or github.com/organizations/<org>/settings/installations/<ID> for an org.

### Step 4
Run the following command:
```bash
APP_ID=<your_app_id> INSTALLATION_ID=<your_installation_id> PEM_PATH=<path_to_your_private_key> ./bootstrap.sh
```
Optionally, but highly recommended: Set `CHART_VERSION` in the command above to pin to a version found [here.](https://github.com/actions/actions-runner-controller/pkgs/container/actions-runner-controller-charts%2Fgha-runner-scale-set)

## Maintenance of the image
Any time an update is made to the image, run these commands to push it:
```bash
cd runner-docker
docker buildx build --platform linux/amd64 -t ghcr.io/deister-engineering/arc-runner:<NEW_VERSION_HERE> --push .
docker buildx build --platform linux/arm64 -t ghcr.io/deister-engineering/arc-runner:<NEW_VERSION_HERE> --push .
docker buildx build --platform linux/amd64 -t ghcr.io/deister-engineering/arc-runner:latest --push .
docker buildx build --platform linux/arm64 -t ghcr.io/deister-engineering/arc-runner:latest --push .
```

To verify functionality of the new image, run this command to pull it:
```bash
docker run --rm --entrypoint bash ghcr.io/deister-engineering/arc-runner:<NEW_VERSION_HERE> -c 'gh --version && docker compose version && docker buildx version'
```