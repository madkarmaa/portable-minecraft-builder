param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
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

Import-Module -Name ".\helper.psm1" -Force

$webClient = New-Object System.Net.WebClient

$uri = New-Object System.Uri($Url)
$filename = [System.IO.Path]::GetFileName($uri.LocalPath)
$destinationPath = ".\$filename"

if (Test-Path $destinationPath) {
    Remove-Item $destinationPath
}

$webClient.DownloadFile($Url, $destinationPath)
$webClient.Dispose()

Log "Successfully downloaded '$filename'"
