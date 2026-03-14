#!/usr/bin/env bash
set -e

# -----------------------------------------------------------------------------
# Configure your personal GCP VM (edit these or set env vars)
# -----------------------------------------------------------------------------
# Option A: Use gcloud compute ssh (recommended for GCP – uses the account from Step 1)
FINTRACK_GCP_PROJECT="${FINTRACK_GCP_PROJECT:-enlead-ai}"
FINTRACK_GCP_ZONE="${FINTRACK_GCP_ZONE:-us-central1-f}"
FINTRACK_GCP_INSTANCE="${FINTRACK_GCP_INSTANCE:-fintrack}"

# Option B: Or use direct SSH (set this to use it instead of gcloud; uncomment and set project to empty to skip gcloud check)
FINTRACK_VM="${FINTRACK_VM:-}"   # e.g. "utk_umang@34.58.111.44"

FINTRACK_REPO_DIR="${FINTRACK_REPO_DIR:-/srv/fintrack}"
FINTRACK_BRANCH="${FINTRACK_BRANCH:-main}"

# -----------------------------------------------------------------------------
# Step 1: Log in to personal GCP
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "  Step 1: Log in to your personal GCP account"
echo "=============================================="
echo ""
echo "A browser window will open. Choose your PERSONAL Google account."
echo "Press Enter to continue..."
read -r

if ! command -v gcloud &>/dev/null; then
  echo "Error: gcloud CLI not found. Install it: https://cloud.google.com/sdk/docs/install"
  exit 1
fi

gcloud auth login

echo ""
echo "Logged in. Current account:"
gcloud config get-value account 2>/dev/null || true
echo ""

# -----------------------------------------------------------------------------
# Step 2: Deploy on VM
# -----------------------------------------------------------------------------
echo "=============================================="
echo "  Step 2: Deploying on VM"
echo "=============================================="
echo ""

# Commands to run on VM (as root): cd to repo, fix git safe.directory, pull, submodules, docker
DEPLOY_CMD="set -e && cd ${FINTRACK_REPO_DIR} && git config --global --add safe.directory ${FINTRACK_REPO_DIR} && git pull origin ${FINTRACK_BRANCH} && git submodule sync && git submodule update --init --recursive && docker-compose down && docker-compose up -d --build"

if [[ -n "$FINTRACK_VM" ]]; then
  echo "Using SSH: $FINTRACK_VM"
  ssh "$FINTRACK_VM" "sudo bash -c '${DEPLOY_CMD}'"
else
  echo "Using gcloud compute ssh: $FINTRACK_GCP_INSTANCE ($FINTRACK_GCP_ZONE)"
  if [[ "$FINTRACK_GCP_PROJECT" == "your-personal-project-id" ]] || \
     [[ "$FINTRACK_GCP_ZONE" == "e.g. us-central1-a" ]] || \
     [[ "$FINTRACK_GCP_INSTANCE" == "your-vm-instance-name" ]]; then
    echo ""
    echo "Error: Configure VM connection first."
    echo "  Either set FINTRACK_VM (e.g. user@ip) for direct SSH, or set:"
    echo "  FINTRACK_GCP_PROJECT, FINTRACK_GCP_ZONE, FINTRACK_GCP_INSTANCE"
    echo ""
    echo "  Example: export FINTRACK_GCP_PROJECT=my-project FINTRACK_GCP_ZONE=us-central1-a FINTRACK_GCP_INSTANCE=fintrack-vm"
    exit 1
  fi
  gcloud compute ssh "$FINTRACK_GCP_INSTANCE" \
    --zone="$FINTRACK_GCP_ZONE" \
    --project="$FINTRACK_GCP_PROJECT" \
    -- "sudo bash -c '${DEPLOY_CMD}'"
fi

echo ""
echo "Deployment finished."
echo ""
