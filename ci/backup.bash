#!/usr/bin/env bash


MSYS_NO_PATHCONV=1 podman run --rm -u root \
  -v "$(cygpath -u "$(pwd)/backup"):/backups" \
  -v jupyterhub-shared-data:/shared \
  quay.io/jupyter/minimal-notebook \
  bash -c 'tar cvf /backups/jtyberg-shared-backup.tar /shared'