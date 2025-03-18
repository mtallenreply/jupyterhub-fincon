param([string]$versionHub = "latest",
        [string]$versionNotebook = "latest")
<#
.SYNOPSIS
    Builds, tags, logs in, and pushes Docker images.

.DESCRIPTION
    Uses Podman to build JupyterHub and Notebook images, tags them with a specified version and "latest",
    loads GH_TOKEN from ../secrets/.env, logs in to ghcr.io, and pushes the images.

.PARAMETER versionHub
    Hub image tag (default: "latest").

.PARAMETER versionNotebook
    Notebook image tag (default: "latest").

.EXAMPLE
    BuildAndDeploy -versionHub "1.0.6" -versionNotebook "1.0.6"
#>
function BuildAndDeploy
# function for Building tagging,loging pushing
# you need to have a env variable in your system or in root/secrets/.env with GH_TOKEN=your-gh-token
{
    param(
        [string]$versionHub = "latest",
        [string]$versionNotebook = "latest",
        # Relative Pfade ins 'basic-example'-Unterverzeichnis
        [string]$dockerfilePathHub = "..\basic-example\Dockerfile.jupyterhub",
        [string]$dockerfilePathNotebook = "..\basic-example\Dockerfile.notebook",
        [string]$contextDir = "..\basic-example"
    )

   # Build  of Docker-Images
    podman build -t hub:$versionHub -f $dockerfilePathHub --platform linux/amd64 $contextDir
    podman build -t notebook:$versionNotebook -f $dockerfilePathNotebook --platform linux/amd64 $contextDir

    # Taggen: Version + Latest
    podman tag localhost/hub:$versionHub ghcr.io/mtallenreply/jupyterhub-reply:$versionHub
    podman tag localhost/hub:$versionHub ghcr.io/mtallenreply/jupyterhub-reply:latest

    podman tag localhost/notebook:$versionNotebook ghcr.io/mtallenreply/notebook-reply:$versionNotebook
    podman tag localhost/notebook:$versionNotebook ghcr.io/mtallenreply/notebook-reply:latest
    # load .env file into env variable
    get-content ../secrets/.env | foreach {
        $name, $value = $_.split('=')
        set-content env:\$name $value
    }
    # Login
    podman login ghcr.io -u mtallenreply --password $env:GH_TOKEN
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Fehler: Login in ghcr.io fails Set environment variable GH_TOKEN "
        return
    }
    # Pushen: Version + Latest
    podman push ghcr.io/mtallenreply/jupyterhub-reply:$versionHub
    podman push ghcr.io/mtallenreply/jupyterhub-reply:latest

    podman push ghcr.io/mtallenreply/notebook-reply:$versionNotebook
    podman push ghcr.io/mtallenreply/notebook-reply:latest
    Write-Output "Next step: change in repository at https://github.com/fc-mwissmann/travel-ai-deployment/blob/main/services-compose.yml
    to image reference: $versionNotebook (or :latest) Server gets only updated when you change something"
}

$version = "1.0.6"
# Skript ausführen
BuildAndDeploy -versionHub $version -versionNotebook $version