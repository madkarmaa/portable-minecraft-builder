param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
)

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

$webClient = New-Object System.Net.WebClient

$uri = New-Object System.Uri($Url)
$filename = [System.IO.Path]::GetFileName($uri.LocalPath)
$destinationPath = ".\$filename"

$webClient.DownloadFile($Url, $destinationPath)

$webClient.Dispose()
