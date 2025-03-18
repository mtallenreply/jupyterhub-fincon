# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Configuration file for JupyterHub
import os

c = get_config()  # noqa: F821


c.Spawner.http_timeout = 300
c.Spawner.start_timeout = 300
# Ich benutze hier ein persönliches IMage da man so das installieren von packages später reduziert und so ressourcen schont
c.DockerSpawner.network_name = 'jupyterhub' # auch im compose
# shared ist eine ebene unter der working directory


# We rely on environment variables to configure JupyterHub so that we
# avoid having to rebuild the JupyterHub container every time we change a
# configuration parameter.

# Spawn single-user servers as Docker containers
c.JupyterHub.spawner_class = "dockerspawner.DockerSpawner"

# Spawn containers from this image
# print("used image in config:", os.environ["DOCKER_NOTEBOOK_IMAGE"])
c.DockerSpawner.image = os.environ["DOCKER_NOTEBOOK_IMAGE"]
# c.DockerSpawner.image = "ghcr.io/mtallenreply/notebook-reply:latest" # auch im compose

# Connect containers to this Docker network
network_name = os.environ["DOCKER_NETWORK_NAME"]
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name

# Explicitly set notebook directory because we'll be mounting a volume to it.
# Most `jupyter/docker-stacks` *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
# We follow the same convention.
notebook_dir = os.environ.get("DOCKER_NOTEBOOK_DIR", "/home/jovyan/work")
c.DockerSpawner.notebook_dir = notebook_dir

# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
c.DockerSpawner.volumes = {"jupyterhub-user-{username}": notebook_dir,
                           "jupyterhub-shared-data": notebook_dir+"/shared"}
# c.DockerSpawner.volumes = { 'jupyterhub-user-{username}': notebook_dir,'jupyterhub-shared-data': '/home/jovyan/work/shared',"jupyterhub_data":"/srv/jupyterhub/data"}

# Remove containers once they are stopped
# c.DockerSpawner.remove = True

# For debugging arguments passed to spawned containers
c.DockerSpawner.debug = True

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = "jupyterhub"
# c.JupyterHub.hub_ip = '0.0.0.0'

c.JupyterHub.hub_port = 8080
# c.JupyterHub.bind_url = "http://0.0.0.0:8000"

# Persist hub data on volume mounted inside container
c.JupyterHub.cookie_secret_file = "/data/jupyterhub_cookie_secret"
c.JupyterHub.db_url = "sqlite:////data/jupyterhub.sqlite"

# Allow all signed-up users to login
c.Authenticator.allow_all = True

# Authenticate users with Native Authenticator
c.JupyterHub.authenticator_class = "nativeauthenticator.NativeAuthenticator"

# Allow anyone to sign-up without approval
c.NativeAuthenticator.open_signup = True

# Allowed admins
admin = os.environ.get("JUPYTERHUB_ADMIN")
if admin:
    c.Authenticator.admin_users = [admin]






