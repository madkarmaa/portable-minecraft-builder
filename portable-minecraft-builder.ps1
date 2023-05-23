param (
    [Parameter(Mandatory=$true)]
    [string]$DataFolderName,
    [Parameter(Mandatory=$true)]
    [string]$InstallFabric,
    [Parameter(Mandatory=$true)]
    [string]$InstallMods,
    [Parameter(Mandatory=$true)]
    [string]$DownloadJava
)

# Convert the string values to boolean
$InstallFabric = [bool]::Parse($InstallFabric)
$InstallMods = [bool]::Parse($InstallMods)
$DownloadJava = [bool]::Parse($DownloadJava)

New-Item -ItemType Directory -Path ".\$DataFolderName" > $null

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
Remove-Item -Path ".\file-downloader.ps1" -Force

Start-Process powershell.exe -ArgumentList "-Command", '".\launcher-downloader.ps1"' -NoNewWindow -Wait
Remove-Item -Path ".\launcher-downloader.ps1" -Force

if ($DownloadJava) {
    Start-Process powershell.exe -ArgumentList "-Command", '".\java-downloader.ps1"' -NoNewWindow -Wait
}
Remove-Item -Path ".\java-downloader.ps1" -Force

if ($InstallFabric) {
    Start-Process powershell.exe -ArgumentList "-Command", '".\fabric-downloader.ps1"' -NoNewWindow -Wait

    $fileExists = Test-Path -Path ".\$DataFolderName\launcher_profiles.json" > $null

    if (-not ($fileExists)) {
        Start-Process powershell.exe -ArgumentList "-Command", {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('The file launcher_profiles.json does not exist. The launcher is starting, wait then close it.') > $null
        } -NoNewWindow

        Write-Host "[33mWaiting for the launcher to be closed...[0m"
        Start-Process -FilePath $javaPath -ArgumentList "-jar", '".\SKlauncher.jar"', "--workDir", $DataFolderName -NoNewWindow -Wait
        Write-Host "[32mSuccessfully installed Fabric[0m"
    }

    Start-Process -FilePath $javaPath -ArgumentList "-jar", '".\fabric.jar"', "client", "-dir", $DataFolderName -NoNewWindow -Wait
    Remove-Item -Path ".\fabric.jar" -Force

    if ($InstallMods) {
        $projectNames = @("fabric-api", "iris", "lithium", "sodium", "starlight")

        foreach ($projectName in $projectNames) {
            Start-Process powershell.exe -ArgumentList "-Command", '".\mods-downloader.ps1"', "-projectName", $projectName, "-DataFolderName", $DataFolderName -NoNewWindow -Wait
        }
    }
}

Remove-Item -Path ".\fabric-downloader.ps1" -Force
Remove-Item -Path ".\mods-downloader.ps1" -Force