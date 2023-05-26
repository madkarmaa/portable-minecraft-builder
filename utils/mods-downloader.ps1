param (
    [Parameter(Mandatory=$true)]
    [string]$projectName,
    [Parameter(Mandatory=$true)]
    [string]$DataFolderName
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

function GetMinecraftReleaseVersion {
    $apiUrl = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    $response = Invoke-RestMethod -Uri $apiUrl
    $latestReleaseVersion = $response.versions | Where-Object { $_.type -eq "release" } | Select-Object -First 1 -ExpandProperty id
    $latestReleaseVersion
}

$minecraftVersion = GetMinecraftReleaseVersion

$url = "https://api.modrinth.com/v2/project/$projectName/version"
$response = Invoke-RestMethod -Uri $url -Method GET

[array]$matchingFiles = $response | Where-Object { ($_.version_type -eq "release") -and ($_.loaders -contains "fabric") -and ($_.game_versions -contains $minecraftVersion) }

if ($matchingFiles.Count -gt 0) {
    $fileToDownload = $null

    foreach ($file in $matchingFiles.files) {
        $fileToDownload = $file | Where-Object { ($_.primary -eq "true") }
        break
    }

    $modFile = $fileToDownload.filename
    $modUrl = $fileToDownload.url
    $modName = $modFile -replace "\.jar$"

    $destinationDirectory = ".\$DataFolderName\mods"
    $destinationPath = Join-Path $destinationDirectory $modFile

    # Create missing directories recursively
    if (-not (Test-Path $destinationDirectory)) {
        New-Item -Path $destinationDirectory -ItemType Directory -Force | Out-Null
    }

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($modUrl, $destinationPath)
    Write-Host "Successfully installed [32m$modName[0m"
} else {
    Write-Host "[31mNo matching files found for '$projectName'.[0m"
}
