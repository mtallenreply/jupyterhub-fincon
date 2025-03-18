#!/bin/bash
clear_podman_resources() {

  read -r -p "Are you sure to delete all Podman-Resources? Sind Sie sicher, dass Sie alle Podman-Ressourcen löschen möchten? (y/N): " confirmation
  if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo "Bereinigung abgebrochen."
    return 0
  fi

  echo "Stoppe alle Container..."
  for container in $(podman ps -aq); do
    podman stop "$container"
  done

  echo "Entferne alle Container..."
  for container in $(podman ps -aq); do
    podman rm "$container"
  done

  echo "Erzwinge das Entfernen aller Container..."
  for container in $(podman ps -aq); do
    podman rm -f "$container"
  done

  echo "Lösche alle Images..."
  for image in $(podman images -aq); do
    podman rmi -f "$image"
  done

  echo "Lösche alle Volumes..."
  for volume in $(podman volume ls -q); do
    podman volume rm -f "$volume"
  done

  echo "Lösche alle Netzwerke (außer Standardnetzwerke)..."
  for network in $(podman network ls --format "{{.Name}}"); do
    if [[ "$network" != "podman" && "$network" != "bridge" && "$network" != "host" && "$network" != "none" ]]; then
      podman network rm "$network"
    fi
  done

  echo "Bereinigung abgeschlossen."
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  clear_podman_resources
fi