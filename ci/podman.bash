#!/usr/bin/env bash
# build_and_deploy.sh
#
# SYNOPSIS:
#   Builds, tags, logs in, and pushes Docker images using Podman.
#
# DESCRIPTION:
#   This script builds JupyterHub and Notebook images using Podman,
#   tags them with a specified version and "latest",
#   loads GH_TOKEN from ../secrets/.env,
#   logs in to ghcr.io, and pushes the images.
#
# PARAMETERS:
#   versionHub:      Hub image tag (default: "latest")
#   versionNotebook: Notebook image tag (default: "latest")
#
# EXAMPLE:
#   ./build_and_deploy.sh 1.0.6 1.0.6

build_and_deploy() {
    local versionHub="${1:-latest}"
    local versionNotebook="${2:-latest}"
    local dockerfilePathHub="../basic-example/Dockerfile.jupyterhub"
    local dockerfilePathNotebook="../basic-example/Dockerfile.notebook"
    local contextDir="../basic-example"

    # Build Docker images
    podman build -t "hub:${versionHub}" -f "${dockerfilePathHub}" --platform linux/amd64 "${contextDir}"
    podman build -t "notebook:${versionNotebook}" -f "${dockerfilePathNotebook}" --platform linux/amd64 "${contextDir}"

    # Tag images: version + latest
    podman tag "localhost/hub:${versionHub}" "ghcr.io/mtallenreply/jupyterhub-reply:${versionHub}"
    podman tag "localhost/hub:${versionHub}" "ghcr.io/mtallenreply/jupyterhub-reply:latest"
    podman tag "localhost/notebook:${versionNotebook}" "ghcr.io/mtallenreply/notebook-reply:${versionNotebook}"
    podman tag "localhost/notebook:${versionNotebook}" "ghcr.io/mtallenreply/notebook-reply:latest"

       # Load .env file and export variables
    if [ -f "../secrets/.env" ]; then
      source "../secrets/.env"
    else
      echo "Warning: ../secrets/.env not found."
    fi

    # Check if GH_TOKEN is set
    if [ -z "$GH_TOKEN" ]; then
      echo "Error: GH_TOKEN is not set. Please provide GH_TOKEN in ../secrets/.env or in your environment."
      return 1
    fi

    # Login to ghcr.io using GH_TOKEN
    if ! podman login ghcr.io -u mtallenreply --password "$GH_TOKEN"; then
      echo "Error: Login to ghcr.io failed. Please check your GH_TOKEN."
      return 1
    fi

    # Push images: version + latest
    podman push "ghcr.io/mtallenreply/jupyterhub-reply:${versionHub}"
    podman push "ghcr.io/mtallenreply/jupyterhub-reply:latest"
    podman push "ghcr.io/mtallenreply/notebook-reply:${versionNotebook}"
    podman push "ghcr.io/mtallenreply/notebook-reply:latest"

    echo "Next step: update the repository at:"
    echo "https://github.com/fc-mwissmann/travel-ai-deployment/blob/main/services-compose.yml"
    echo "to reference image ${versionNotebook} (or :latest). The server updates only when changes occur. "
    echo "When you want test locally> podman compose up -d"
}

# Set version and execute the function
version="1.0.6"
build_and_deploy "$version" "$version"
