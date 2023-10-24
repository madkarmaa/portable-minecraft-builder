###############################################################################
##   Created by mk_                                                          ##
##   GitHub: https://github.com/madkarmaa/                                   ##
##   Project page: https://github.com/madkarmaa/portable-minecraft-builder/  ##
###############################################################################

$dir = Join-Path $env:APPDATA "PMB-DATA"

# create script data dir if it doesn't exist
if (!(Test-Path -Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force > $null
}

$logFilePath = Join-Path $dir "portable-minecraft-builder.log"
function Log {
    param (
        [Parameter(Mandatory = $true)]
        [string] $msg, 
        [string] $level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $levelColor = @{
        "INFO"    = "[36m"
        "WARN"    = "[33m"
        "WARNING" = "[33m"
        "ERROR"   = "[31m"
        "SUCCESS" = "[32m"
    }
    $level = $levelColor[$level.ToUpper()] + $level + "[0m"
    $logEntry = "[[34m$timestamp[0m] [$level] $msg"

    Write-Host $logEntry
    ($logEntry -replace '\e\[[0-9;]*m') | Out-File -Append -FilePath $logFilePath -Force
}

# check if the device has a 64-bit Windows OS
Log "Checking system requirements..."
if (!([Environment]::Is64BitProcess) -or ([Environment]::OSVersion.Platform -ne "Win32NT")) {
    Log "This script requires a 64-bit Windows environment!" -level "ERROR"
    exit
} else {
    Log "System requirements met" -level "SUCCESS"
}

$ProgressPreference = 'SilentlyContinue' # for performance
Log "Progress bars disabled"

# create minecraft data dir if it doesn't exist
$gameDir = Read-Host -Prompt "Minecraft data directory name (Enter to skip)"
if (!$gameDir) {
    $gameDir = '.minecraft'
}
$gameDir = Join-Path "./" $gameDir
if (!(Test-Path -Path $gameDir)) {
    New-Item -ItemType Directory -Path $gameDir -Force > $null
    Log "Created game data dir at $gameDir" -level "SUCCESS"
} else {
    Log "Game data dir '$gameDir' already exists"
}

$curlDir = (Get-ChildItem $dir | Where-Object { $_.Name -like "curl*" }).FullName
# if curl is not available, download it
if (!$curlDir -or !(Test-Path -Path $curlDir)) {
    Log "Curl not found! Downloading..." -level "WARN"

    # download the curl zip file
    $curlZip = Join-Path $dir "curl.zip"
    Invoke-WebRequest -Uri "https://curl.se/windows/dl-8.4.0_3/curl-8.4.0_3-win64-mingw.zip" -OutFile $curlZip
    # extract the downloaded curl zip file
    Expand-Archive -Path $curlZip -DestinationPath $dir
    # delete after extraction
    Remove-Item -Path $curlZip -Force
    # give the variable a value
    $curlDir = (Get-ChildItem $dir | Where-Object { $_.Name -like "curl*" }).FullName

    Log "Downloaded Curl at $curlDir" -level "SUCCESS"
}
# add curl variable
$curl = Join-Path $curlDir (Join-Path "bin" "curl.exe")

# function to download a file
function Download {
  param (
    [string] $url, 
    [string] $outPath
  )
  Start-Process $curl "-L $url -o $outPath -s" -NoNewWindow -Wait
}

function GetMinecraftReleaseVersion {
    $apiUrl = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    $response = Invoke-RestMethod -Uri $apiUrl
    $latestReleaseVersion = $response.versions | Where-Object { $_.type -eq "release" } | Select-Object -First 1 -ExpandProperty id
    $latestReleaseVersion
}

$javaFolder = (Get-ChildItem -Directory | Where-Object { $_.Name -like "jdk*" }).Name
# if the java folder doesn't exist, download it
if (!$javaFolder -or !(Test-Path -Path $javaFolder)) {
    Log "Java not found! Downloading..." -level "WARN"

    $javaDlURL = "https://api.github.com/repos/adoptium/temurin17-binaries/releases/tags/jdk-17.0.8.1%2B1"
    $javaMatchPattern = "OpenJDK17U-jdk_x64_windows_hotspot*.zip"

    # download the java zip file
    $javaZip = Invoke-RestMethod -Uri $javaDlURL |
        Select-Object -ExpandProperty assets |
        Where-Object { $_.name -like $javaMatchPattern } |
        ForEach-Object {
            $assetUrl = $_.browser_download_url
            $outputPath = Join-Path "./" $_.name
            Download -url $assetUrl -outPath $outputPath
            $outputPath
        }

    # extract the downloaded java zip file
    Expand-Archive -Path $javaZip -DestinationPath "./"
    # delete after extraction
    Remove-Item -Path $javaZip -Force
    # give the variable a value
    $javaFolder = (Get-ChildItem -Directory | Where-Object { $_.Name -like "jdk*" }).Name

    Log "Java downloaded"
} else {
    Log "Java folder already exists"
}
# add java variable
$java = Join-Path (Join-Path "./" $javaFolder) (Join-Path "bin" "javaw.exe")

Log "Downloading game launcher..."
# TODO: auto update
$launcher = Join-Path "./" "sklauncher.jar"
Download -url "https://skmedix.pl/binaries_/SKlauncher-3.1.2.jar" -outPath $launcher
Log "Game launcher downloaded" -level "SUCCESS"

# ask the user if they want to install optimization mods
$installMods = Read-Host -Prompt "Install optimization mods? (y/N)"
if (!$installMods -or ($installMods.ToLower() -ne "y")) {
    $installMods = 'n'
}

if (($installMods.ToLower() -eq "y")) {
    # search for the latest stable version of the fabric installer
    $fabricData = (Invoke-RestMethod -Uri "https://meta.fabricmc.net/v2/versions/installer")
    $fabricURL = $null

    foreach ($item in $fabricData) {
        if ($item.stable) {
            $fabricURL = $item.url
            break
        }
    }

    # download the fabric installer if it exists
    Log "Downloading Fabric installer..."
    if ($fabricURL) {
        Download -url $fabricURL -outPath (Join-Path "./" "fabric.jar")
        Log "Fabric installer downloaded" -level "SUCCESS"
    } else {
        Log "No stable Fabric installer found!" -level "ERROR"
        exit
    }

    $profiles = Join-Path "./" (Join-Path "mods" "launcher_profiles.json")
    if (!(Test-Path $profiles -PathType Leaf)) {
        Log "Missing profiles file, running launcher..." -level "WARN"
        Log "Wait until the launcher is completely loaded, then close it!" -level "WARN"
        Start-Process $java "-jar ./sklauncher.jar --workDir $gameDir" -NoNewWindow -Wait
        Log "Installing Fabric..."
        # TODO: check if fabric installer fails
        Start-Process $java "-jar ./fabric.jar client -dir $gameDir" -NoNewWindow -Wait
        Log "Installed Fabric" -level "SUCCESS"
    }

    Remove-Item -Path (Join-Path "./" "fabric.jar") -Force

    # mods list
    $mods = @("lazydfu", "entityculling", "fabric-api", "iris", "lithium", "sodium", "starlight", "memoryleakfix", "krypton", "dynamic-fps")
    # latest mc version
    $minecraftVersion = GetMinecraftReleaseVersion

    $modsDir = Join-Path $gameDir "mods"
    # create mods folder
    if (!(Test-Path $modsDir)) {
        New-Item -Path $modsDir -ItemType Directory -Force > $null
        Log "Mods folder created" -level "SUCCESS"
    } else {
        Log "Mods folder already exists"
    }

    foreach ($mod in $mods) {
        $nameUrl = "https://api.modrinth.com/v2/project/" + $mod
        $url = $nameUrl + "/version"

        $response = Invoke-RestMethod -Uri $url
        $nameResponse = Invoke-RestMethod -Uri $nameUrl
        $modName = $nameResponse.title

        # fabric mod for selected game version
        # ($_.version_type -eq "release") -and
        [array]$matchingFiles = $response | Where-Object { ($_.loaders -contains "fabric") -and ($_.game_versions -contains $minecraftVersion) }

        if ($matchingFiles.Count -gt 0) {
            $fileToDownload = $null

            # search for the primary file
            foreach ($file in $matchingFiles.files) {
                $fileToDownload = $file | Where-Object { ($_.primary -eq "true") }
                break
            }

            $modFile = $fileToDownload.filename
            $modUrl = $fileToDownload.url
            $destinationPath = Join-Path $modsDir $modFile

            Download -url $modUrl -outPath $destinationPath
            Log "Successfully downloaded [32m$modName[0m" -level "SUCCESS"
        } else {
            Log "No matching files found for [31m$modName[0m in game version [31m$minecraftVersion[0m" -level "ERROR"
        }
    }
} else {
    Log "Optimization mods will not be downloaded"
}

# create runnable files
if (Test-Path (Join-Path "./" "Minecraft.vbs") -PathType Leaf) {
    Remove-Item -Path (Join-Path "./" "Minecraft.vbs") -Force
}
"Set WshShell = CreateObject(`"WScript.Shell`")`nWshShell.Run Chr(34) & `".\minecraft.bat`" & Chr(34), 0`nSet WshShell = Nothing" | Out-File -Force (Join-Path "./" "Minecraft.vbs")
if (Test-Path (Join-Path "./" "minecraft.bat") -PathType Leaf) {
    Remove-Item -Path (Join-Path "./" "minecraft.bat") -Force
}
"@echo off`nset java=`"$java`"`nset launcher=`"$launcher`"`nset workingDirectory=`"$gameDir`"`n%java% -jar %launcher% --workDir %workingDirectory%" | Out-File -Force (Join-Path "./" "minecraft.bat")

# hide files the user should not run
$filesToHide = @(".\minecraft.bat", $launcher)
foreach ($file in $filesToHide) {
    $file = Get-Item $file -Force
    $file.attributes = $file.attributes -bxor [System.IO.FileAttributes]::Hidden
}

Log "Files generated" -level "SUCCESS"

# EOF
$ProgressPreference = 'Continue' # reset to default
Log "Progress bars enabled"