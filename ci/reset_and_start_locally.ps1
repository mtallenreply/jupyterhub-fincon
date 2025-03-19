# Ermittelt den Ordner des aktuellen Skripts
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Definiert den Pfad zu den einzelnen Skripten
$script1 = "$scriptFolder\ATTENTION_DELETE_ALL_PODMAN.ps1"
$script2 = "$scriptFolder\podman.ps1"

# Führt Script1 aus
Write-Host "Führe Script1 aus..."
& $script1

# Führt Script2 aus
Write-Host "Führe Script2 aus..."
& $script2

# Wechselt in das Zielverzeichnis (ein Ordner oberhalb und dann in basic-example)
$targetFolder = Join-Path -Path $scriptFolder -ChildPath "..\basic-example"

# Optional: Überprüfen, ob der Ordner existiert
if (Test-Path $targetFolder) {
    Write-Host "Wechsle in den Ordner: $targetFolder"
    Push-Location $targetFolder
    Write-Host "Führe 'podman compose up -d' aus..."
    podman compose up -d
    Pop-Location
} else {
    Write-Host "Zielordner '$targetFolder' wurde nicht gefunden."
}