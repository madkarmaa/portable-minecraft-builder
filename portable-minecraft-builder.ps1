param (
    [string]$DataFolderName = ".minecraft",
    [Parameter(Mandatory=$true)]
    [bool]$InstallFabric,
    [Parameter(Mandatory=$true)]
    [bool]$InstallMods
)

New-Item -ItemType Directory -Path ".\$DataFolderName"

# $tempfile = "temp"
$urls = @(
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/templates/minecraft.bat",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/templates/Minecraft.vbs",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/launcher-downloader.ps1",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/java-downloader.ps1",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/fabric-downloader.ps1",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/mods-downloader.ps1"
)

foreach ($url in $urls) {
    & ".\file-downloader.ps1" -Url $url
}

& ".\launcher-downloader.ps1"
# & ".\java-downloader.ps1"

if ($InstallFabric) {
    & ".\fabric-downloader.ps1"

    if ($InstallMods) {
        $projectNames = @("fabric-api", "iris", "lithium", "sodium", "starlight")

        foreach ($projectName in $projectNames) {
            & ".\mods-downloader.ps1" -projectName $projectName
        }
    }
}