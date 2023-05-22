param (
    [Parameter(Mandatory=$true)]
    [string]$DataFolderName,
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
$javaPath = ".\Java\bin\javaw.exe"

foreach ($url in $urls) {
    & ".\file-downloader.ps1" -Url $url
}

& ".\launcher-downloader.ps1"
& ".\java-downloader.ps1"

if ($InstallFabric) {
    & ".\fabric-downloader.ps1"
    $fileExists = Test-Path -Path ".\$DataFolderName\launcher_profiles.json"

    if (-not ($fileExists)) {
        Start-Process -FilePath $javaPath -ArgumentList "-jar", ".\SKlauncher.jar", "--workDir", $DataFolderName -Wait
    }

    & $javaPath -jar ".\fabric.jar" client -dir $DataFolderName

    if ($InstallMods) {
        $projectNames = @("fabric-api", "iris", "lithium", "sodium", "starlight")

        foreach ($projectName in $projectNames) {
            & ".\mods-downloader.ps1" -projectName $projectName -DataFolderName $DataFolderName
        }
    }
}