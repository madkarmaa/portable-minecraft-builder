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

Import-Module -Name ".\helper.psm1" -Force

# Convert the string values to boolean
$InstallFabric = [bool]::Parse($InstallFabric)
$InstallMods = [bool]::Parse($InstallMods)
$DownloadJava = [bool]::Parse($DownloadJava)

$urls = @(
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/templates/minecraft.bat",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/templates/Minecraft.vbs",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/launcher-downloader.ps1",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/java-downloader.ps1",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/fabric-downloader.ps1",
    "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/mods-downloader.ps1"
)

$tempfile = "temp"
$javaFolder = "Java"
$javaPath = ".\$JavaFolder\bin\javaw.exe"
$launcherJar = 'SKlauncher.jar'

try {
    Log "Downloading resources..."
    
    foreach ($url in $urls) {
        Start-Process powershell.exe -ArgumentList "-Command", '".\file-downloader.ps1"', "-Url", $url -NoNewWindow -Wait
    }
    Remove-Item -Path ".\file-downloader.ps1" -Force
    
    Log "Done" -logLevel "SUCCESS"
    
    Log "Creating Minecraft data directory..."
    
    New-Item -ItemType Directory -Path ".\$DataFolderName" > $null
    
    Log "Done" -logLevel "SUCCESS"
    
    Log "Downloading launcher..."
    
    Start-Process powershell.exe -ArgumentList "-Command", '".\launcher-downloader.ps1"' -NoNewWindow -Wait
    Remove-Item -Path ".\launcher-downloader.ps1" -Force
    
    Log "Done" -logLevel "SUCCESS"
    
    if ($DownloadJava -eq $true) {
        Log "Downloading Java..."
    
        Start-Process powershell.exe -ArgumentList "-Command", '".\java-downloader.ps1"' -NoNewWindow -Wait
    
        Log "Done" -logLevel "SUCCESS"
    }
    Remove-Item -Path ".\java-downloader.ps1" -Force
    
    if ($InstallFabric -eq $true) {
        Start-Process powershell.exe -ArgumentList "-Command", '".\fabric-downloader.ps1"' -NoNewWindow -Wait
    
        Log "Installing Fabric..."
        $fileExists = Test-Path -Path ".\$DataFolderName\launcher_profiles.json" > $null
    
        if (-not ($fileExists)) {
            Start-Process powershell.exe -ArgumentList "-Command", {
                Add-Type -AssemblyName System.Windows.Forms
                [System.Windows.Forms.MessageBox]::Show('The file launcher_profiles.json does not exist. The launcher is starting, please wait, then close it.') > $null
            } -NoNewWindow
        
            Log "Waiting for the launcher to be closed..." -logLevel "WARNING"
            Start-Process -FilePath $javaPath -ArgumentList "-jar", ".\$launcherJar", "--workDir", $DataFolderName -NoNewWindow -Wait
        }
    
        Start-Process -FilePath $javaPath -ArgumentList "-jar", '".\fabric.jar"', "client", "-dir", $DataFolderName -NoNewWindow -Wait
        Remove-Item -Path ".\fabric.jar" -Force
    
        Log "Done" -logLevel "SUCCESS"
    
        if ($InstallMods -eq $true) {
            $projectNames = @("fabric-api", "iris", "lithium", "sodium", "starlight", "memoryleakfix", "krypton", "ferrite-core", "better-ping-display-fabric", "dynamic-fps", "modmenu")
        
            Log "Installing mods..."
        
            foreach ($projectName in $projectNames) {
                Start-Process powershell.exe -ArgumentList "-Command", '".\mods-downloader.ps1"', "-projectName", $projectName, "-DataFolderName", $DataFolderName -NoNewWindow -Wait
            }
        
            Log "Done" -logLevel "SUCCESS"
        }
    }
    
    $filesToHide = @(".\minecraft.bat", ".\$launcherJar")
    
    Log "Modifying templates..."
    
    ((Get-Content ".\minecraft.bat") -replace 'javafolder', "$javaFolder" -replace 'launchername', "$launcherJar" -replace 'datadir', "$DataFolderName") | Set-Content $tempfile
    Get-Content $tempfile | Set-Content ".\minecraft.bat"
    Remove-Item -Path $tempfile -Force
    
    foreach ($file in $filesToHide) {
        (Get-Item $file).Attributes += [System.IO.FileAttributes]::Hidden
    }
    
    Log "Done" -logLevel "SUCCESS"
    
    Remove-Item -Path ".\fabric-downloader.ps1" -Force
    Remove-Item -Path ".\mods-downloader.ps1" -Force
}
catch {
    ErrorLog $_
}