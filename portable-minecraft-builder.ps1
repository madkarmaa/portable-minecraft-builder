param (
    [string]$DataFolderName = ".minecraft",
    [Parameter(Mandatory=$true)]
    [bool]$InstallFabric,
    [Parameter(Mandatory=$true)]
    [bool]$InstallMods
)

New-Item -ItemType Directory -Path ".\$DataFolderName"

$tempfile = "temp"
$urls = @(
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/templates/minecraft.bat",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/templates/Minecraft.vbs"
)

foreach ($url in $urls) {
    & ".\utils\file-downloader.ps1" -Url $url
}

& ".\utils\launcher-downloader.ps1"
# & ".\utils\java-downloader.ps1"

if ($InstallFabric) {
    & ".\utils\fabric-downloader.ps1"

    if ($InstallMods) {
        $projectNames = @("fabric-api", "iris", "lithium", "sodium", "starlight")

        foreach ($projectName in $projectNames) {
            & ".\utils\mods-downloader.ps1" -projectName $projectName
        }
    }
}