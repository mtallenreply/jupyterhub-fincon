> This is a forked repository. 
> I have marked all additional comments with a citation format, 
> but changes to commands are not marked as they have been updated according 
> to the Podman setup.


# jupyterhub-fincon

**jupyterhub-fincon** provides a reference
deployment of [JupyterHub](https://github.com/jupyterhub/jupyterhub), a
multi-user [Jupyter Notebook](https://jupyter.org) environment, on a
**single host** using [Podman](https://podman.io/).

Possible **use cases** include:

- Creating a JupyterHub demo environment that you can spin up relatively
  quickly.
- Providing a multi-user Jupyter Notebook environment for small classes,
  teams or departments.
> We implemented here a multi-user workflow with a shared folder in every User Notebook Explorer
> inside this folder all data is shared between all users and real time collaboration is enabled.

## Disclaimer

This deployment is **NOT** intended for a production environment.
It is a reference implementation that does not meet traditional
requirements in terms of availability, scalability, or security.

If you are looking for a more robust solution to host JupyterHub, or
you require scaling beyond a single host, please check out the
excellent [zero-to-jupyterhub-k8s](https://github.com/jupyterhub/zero-to-jupyterhub-k8s)
project.
> Our implementation is behind a traefik server wich enables https for the routes of jupyter.
> The scalability is related to the given hardware of the server. We defined the max CPUs and RAM in the 
> partner repository [travel-ai-deployment/jupyterhub-deployment](https://github.com/fc-mwissmann/travel-ai-deployment/blob/main/services-compose.yml)

## Technical Overview

Key components of this reference deployment are:

- **Host**: Runs the [JupyterHub components](https://jupyterhub.readthedocs.io/en/stable/reference/technical-overview.html)
  in a Docker container on the host.

- **Authenticator**: Uses [Native Authenticator](https://github.com/jupyterhub/nativeauthenticator) to authenticate users.
  Any user will be allowed to sign up.

- **Spawner**: Uses [DockerSpawner](https://github.com/jupyterhub/dockerspawner)
  to spawn single-user Jupyter Notebook servers in separate Docker
  containers on the same host.

- **Persistence of Hub data**: Persists JupyterHub data in a Docker
  volume on the host.

- **Persistence of user notebook directories**: Persists user notebook
  directories in Docker volumes on the host.

## Prerequisites

### Docker

This deployment uses Podman, via [Podman Compose](https://docs.podman.io/en/latest/markdown/podman-compose.1.html), for all the things.

1. Use [Podmans installation instructions](https://podman.io/docs/installation)
   to set up Podman for your environment.

## Authenticator setup

This deployment uses [JupyterHub Native Authenticator](https://native-authenticator.readthedocs.io/en/latest/) to authenticate users.

1. A single `admin` user will be enabled by default. Any user will be allowed to sign up.

## Build the JupyterHub Docker image

1. Use [podman compose](https://docs.podman.io/en/latest/markdown/podman-compose.1.html) to build
   the JupyterHub Docker image:

   ```bash
   cd basic-example/
   podman build -f Dockerfile.jupyterhub
   podman build -f Dockerfile.notebook
   ```
>Here we are using a script [podman.ps1](ci/podman.ps1), [podman.sh](ci/podman.bash)  for win  which will do a few things
> 1. generate images notebook-reply, jupyterhub-reply
> 2. login into github with token as password in env Variable
> 3. tags it to image_name:Version  and also to image_name:latest and upload it to github account 
>
>
> If you want to **DELETE ALL** your stuff on Podman to get a clean environment
> [ATTENTION_DELETE_ALL_PODMAN.bash](ci/ATTENTION_DELETE_ALL_PODMAN.bash)
> [ATTENTION_DELETE_ALL_PODMAN.ps1](ci/ATTENTION_DELETE_ALL_PODMAN.ps1)

## Customisation: Jupyter Notebook Image

You can configure JupyterHub to spawn Notebook servers from any Docker image, as
long as the image's `ENTRYPOINT` and/or `CMD` starts a single-user instance of
Jupyter Notebook server that is compatible with JupyterHub.

To specify which Notebook image to spawn for users, you set the value of the
`DOCKER_NOTEBOOK_IMAGE` environment variable to the desired container image.

Whether you build a custom Notebook image or pull an image from a public or
private Docker registry, the image must reside on the host.
>Here we are using a self made Docker/Podman Image which is reachable in Github 
>registry (profile -> packages)


If the Notebook image does not exist on the host, Docker will attempt to pull the
image the first time a user attempts to start his or her server. In such cases,
JupyterHub may timeout if the image being pulled is large, so it is better to
pull the image to the host before running JupyterHub.

> Thats here not true anymore we are pointing to a new private registry

This deployment defaults to the
[quay.io/jupyter/base-notebook](https://quay.io/repository/jupyter/base-notebook)
Notebook image, which is built from the `base-notebook`
[Docker stacks](https://github.com/jupyter/docker-stacks).

You can pull the image using the following command:

```bash
podman pull quay.io/jupyter/base-notebook:latest
```

## Run JupyterHub

Run the JupyterHub container on the host.

To run the JupyterHub container in detached mode:
> it runs the file docker-compose.yml
```bash
podman compose up -d
```

Once the container is running, you should be able to access the JupyterHub console at `http://localhost:8000`.

To bring down the JupyterHub container:

```bash
podman compose down
```

---

## FAQ

### How can I view the logs for JupyterHub or users' Notebook servers?

Use `docker logs <container>`. For example, to view the logs of the `jupyterhub` container

```bash
podman logs jupyterhub
```

### How do I specify the Notebook server image to spawn for users?

In this deployment, JupyterHub uses DockerSpawner to spawn single-user
Notebook servers. You set the desired Notebook server image in a
`DOCKER_NOTEBOOK_IMAGE` environment variable.

JupyterHub reads the Notebook image name from `jupyterhub_config.py`, which
reads the Notebook image name from the `DOCKER_NOTEBOOK_IMAGE` environment
variable:

```python
# DockerSpawner setting in jupyterhub_config.py
c.DockerSpawner.image = os.environ['DOCKER_NOTEBOOK_IMAGE']
```

### If I change the name of the Notebook server image to spawn, do I need to restart JupyterHub?

Yes. JupyterHub reads its configuration, which includes the container image
name for DockerSpawner. JupyterHub uses this configuration to determine the
Notebook server image to spawn during startup.

If you change DockerSpawner's name of the Docker image to spawn, you will
need to restart the JupyterHub container for changes to occur.

In this reference deployment, cookies are persisted to a Docker volume on the
Hub's host. Restarting JupyterHub might cause a temporary blip in user
service as the JupyterHub container restarts. Users will not have to login
again to their individual notebook servers. However, users may need to
refresh their browser to re-establish connections to the running Notebook
kernels.

### How can I back up a user's notebook directory?

There are multiple ways to [Back up and restore data](https://docs.docker.com/desktop/backup-and-restore/) in Docker containers.

Suppose you have the following running containers:

```bash
    podman ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}"
```

In this deployment, the user's notebook directories (`/home/jovyan/work`) are backed by Docker volumes.

```bash
    podman inspect -f '{{ .Mounts }}' jupyterhub
    #[{jtyberg /var/lib/docker/volumes/jtyberg/_data /home/jovyan/work local rw true rprivate}]
```

We can back up the user's notebook directory by running a separate container that mounts the user's volume and creates a tarball of the directory.

```bash
# for bash on windows 
MSYS_NO_PATHCONV=1 podman run --rm -u root \
  -v "$(cygpath -u "$(pwd)/backup"):/backups" \
  -v jupyterhub-shared-data:/shared \
  quay.io/jupyter/minimal-notebook \
  bash -c 'tar cvf /backups/jtyberg-shared-backup.tar /shared'
```

The above command creates a tarball in the `/tmp` directory on the host.
