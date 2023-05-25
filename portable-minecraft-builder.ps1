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

$ErrorActionPreference = 'Stop'

Trap {
    $errorMessage = $_.Exception

    # Get the error record containing file, line, and column information
    $errorRecord = $_.InvocationInfo.ScriptLineNumber
    $fileName = $_.InvocationInfo.ScriptName
    $line = $_.InvocationInfo.Line
    $column = $_.InvocationInfo.OffsetInLine

    # Format the error message
    $formattedMessage = "`nError in file '$fileName' at line $line, column $column :`n`n$errorMessage"

    $logFilePath = ".\ErrorLog.txt"

    # Display an error message to the user
    Write-Host "[31mAn error occurred, check the log file for more details: $logFilePath[0m"

    # Log the error to a file
    $formattedMessage | Out-File -FilePath $logFilePath -Append

    # Wait for user input before closing the script
    Pause
    Exit 1
}

# Convert the string values to boolean
$InstallFabric = [bool]::Parse($InstallFabric)
$InstallMods = [bool]::Parse($InstallMods)
$DownloadJava = [bool]::Parse($DownloadJava)

Write-Host "[33mCreating Minecraft data directory...[0m"

New-Item -ItemType Directory -Path ".\$DataFolderName" > $null

Write-Host "[32mDone[0m"

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

Write-Host "`n[33mDownloading resources...[0m"

foreach ($url in $urls) {
    Start-Process powershell.exe -ArgumentList "-Command", '".\file-downloader.ps1"', "-Url", $url -NoNewWindow -Wait
}
Remove-Item -Path ".\file-downloader.ps1" -Force

Write-Host "[32mDone[0m"

Write-Host "`n[33mDownloading launcher...[0m"

Start-Process powershell.exe -ArgumentList "-Command", '".\launcher-downloader.ps1"' -NoNewWindow -Wait

Remove-Item -Path ".\launcher-downloader.ps1" -Force
Write-Host "[32mDone[0m"

if ($DownloadJava -eq $true) {
    Write-Host "`n[33mDownloading Java...[0m"

    Start-Process powershell.exe -ArgumentList "-Command", '".\java-downloader.ps1"' -NoNewWindow -Wait

    Write-Host "[32mDone[0m"
}
Remove-Item -Path ".\java-downloader.ps1" -Force

if ($InstallFabric -eq $true) {
    Write-Host "`n[33mInstalling Fabric...[0m"

    Start-Process powershell.exe -ArgumentList "-Command", '".\fabric-downloader.ps1"' -NoNewWindow -Wait

    $fileExists = Test-Path -Path ".\$DataFolderName\launcher_profiles.json" > $null

    if (-not ($fileExists)) {
        Start-Process powershell.exe -ArgumentList "-Command", {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('The file launcher_profiles.json does not exist. The launcher is starting, please wait, then close it.') > $null
        } -NoNewWindow

        Write-Host "[33mWaiting for the launcher to be closed...[0m"
        Start-Process -FilePath $javaPath -ArgumentList "-jar", ".\$launcherJar", "--workDir", $DataFolderName -NoNewWindow -Wait
    }

    Start-Process -FilePath $javaPath -ArgumentList "-jar", '".\fabric.jar"', "client", "-dir", $DataFolderName -NoNewWindow -Wait
    Remove-Item -Path ".\fabric.jar" -Force

    Write-Host "[32mDone[0m"

    if ($InstallMods -eq $true) {
        $projectNames = @("fabric-api", "iris", "lithium", "sodium", "starlight", "memoryleakfix", "krypton", "ferrite-core", "better-ping-display-fabric", "dynamic-fps", "modmenu")

        Write-Host "`n[33mInstalling mods...[0m`n"

        foreach ($projectName in $projectNames) {
            Start-Process powershell.exe -ArgumentList "-Command", '".\mods-downloader.ps1"', "-projectName", $projectName, "-DataFolderName", $DataFolderName -NoNewWindow -Wait
        }

        Write-Host "`n[32mDone[0m"
    }
}

$filesToHide = @(".\minecraft.bat", ".\$launcherJar")

Write-Host "`n[33mModifying templates...[0m"

((Get-Content ".\minecraft.bat") -replace 'javafolder', "$javaFolder" -replace 'launchername', "$launcherJar" -replace 'datadir', "$DataFolderName") | Set-Content $tempfile
Get-Content $tempfile | Set-Content ".\minecraft.bat"
Remove-Item -Path $tempfile -Force

foreach ($file in $filesToHide) {
    (Get-Item $file).Attributes += [System.IO.FileAttributes]::Hidden
}

Write-Host "[32mDone[0m"

Remove-Item -Path ".\fabric-downloader.ps1" -Force
Remove-Item -Path ".\mods-downloader.ps1" -Force