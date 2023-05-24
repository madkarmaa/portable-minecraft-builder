$ErrorActionPreference = 'Stop'

Trap {
    $errorMessage = $_.Exception.Message
    $logFilePath = ".\ErrorLog.txt"

    # Display an error message to the user
    Write-Host "[31mAn error occurred, check the log file for more details: $logFilePath[0m"

    # Log the error to a file
    $errorMessage | Out-File -FilePath $logFilePath -Append

    # Wait for user input before closing the script
    Pause
    Exit 1
}

$r = Invoke-WebRequest -UseBasicParsing -Uri "https://meta.fabricmc.net/v2/versions/installer" -Method GET

if ($r.StatusCode -ne 200) {
    throw New-Object System.Exception("Network response was not ok")
}

$data = $r.Content | ConvertFrom-Json

$downloadUrl = $null

foreach ($item in $data) {
    if ($item.stable) {
        $downloadUrl = $item.url
        break
    }
}

if ($downloadUrl) {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($downloadUrl, "fabric.jar")
} else {
    Write-Host "No stable URL found."
}
