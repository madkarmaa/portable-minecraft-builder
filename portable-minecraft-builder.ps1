param (
    [Parameter(Mandatory=$true)]
    [string]$DataFolderName,
    [Parameter(Mandatory=$true)]
    [string]$InstallFabric,
    [Parameter(Mandatory=$true)]
    [string]$InstallMods
)

# Convert the string values to boolean
$InstallFabric = [bool]::Parse($InstallFabric)
$InstallMods = [bool]::Parse($InstallMods)

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
$javaPath = ".\Java\bin\javaw.exe"

foreach ($url in $urls) {
    Start-Process powershell.exe -ArgumentList "-Command", '".\file-downloader.ps1"', "-Url", $url -NoNewWindow -Wait
}

Start-Process powershell.exe -ArgumentList "-Command", '".\launcher-downloader.ps1"' -NoNewWindow -Wait
Start-Process powershell.exe -ArgumentList "-Command", '".\java-downloader.ps1"' -NoNewWindow -Wait

if ($InstallFabric) {
    Start-Process powershell.exe -ArgumentList "-Command", '".\fabric-downloader.ps1"' -NoNewWindow -Wait
    $fileExists = Test-Path -Path ".\$DataFolderName\launcher_profiles.json"

    if (-not ($fileExists)) {
        Start-Process -FilePath $javaPath -ArgumentList "-jar", '".\SKlauncher.jar"', "--workDir", $DataFolderName -NoNewWindow -Wait
    }

    Start-Process -FilePath $javaPath -ArgumentList "-jar", '".\fabric.jar"', "client", "-dir", $DataFolderName -NoNewWindow -Wait

    if ($InstallMods) {
        $projectNames = @("fabric-api", "iris", "lithium", "sodium", "starlight")

        foreach ($projectName in $projectNames) {
            Start-Process powershell.exe -ArgumentList "-Command", '".\mods-downloader.ps1"', "-projectName", $projectName, "-DataFolderName", $DataFolderName -NoNewWindow
        }
    }
}