function Clear-PodmanResources {
    <#
    .SYNOPSIS
        Stoppt und löscht alle Podman-Container, Images, Volumes und (nicht-standard) Netzwerke.
    
    .DESCRIPTION
        Diese Funktion führt folgende Aktionen aus:
         - Stoppen aller Container
         - Entfernen aller Container (zuerst normal, dann mit "rm -f")
         - Löschen aller Images
         - Löschen aller Volumes
         - Löschen aller Netzwerke, ausgenommen Standardnetzwerke ("podman", "bridge", "host", "none")
    
    .EXAMPLE
        Clear-PodmanResources
        Führt alle Cleanup-Aktionen aus.
    #>
    # Bestätigungsabfrage
    Write-Output "Lösche alle Netzwerke (außer Standardnetzwerke)..."

    $confirmation = Read-Host "Are you sure to delete all Podman-Resources? Sind Sie sicher, dass Sie ALLE Podman-Ressourcen löschen möchten? (Y/N)"
    if ($confirmation -notin @("Y","y","yes","Yes")) {
        Write-Output "Bereinigung abgebrochen."
        return
    }
    Write-Output "Stoppe alle Container..."
    podman ps -aq | ForEach-Object { podman stop $_ }

    Write-Output "Entferne alle Container..."
    podman ps -aq | ForEach-Object { podman rm $_ }

    Write-Output "Entferne alle Container (Force)..."
    podman ps -aq | ForEach-Object { podman rm -f $_ }

    Write-Output "Lösche alle Images..."
    podman images -aq | ForEach-Object { podman rmi -f $_ }

    Write-Output "Lösche alle Volumes..."
    podman volume ls -q | ForEach-Object { podman volume rm -f $_ }

    Write-Output "Lösche alle Netzwerke (außer Standardnetzwerke)..."
    podman network ls --format "{{.Name}}" | Where-Object { $_ -notin @("podman", "bridge", "host", "none") } | ForEach-Object { podman network rm $_ }

    Write-Output "Bereinigung abgeschlossen."
}
Clear-PodmanResources