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

Log "Downloading Fabric..."
$r = Invoke-WebRequest -UseBasicParsing -Uri "https://meta.fabricmc.net/v2/versions/installer" -Method GET

if ($r.StatusCode -ne 200) {
    throw "Network response was not ok"
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
    Log "Done" -logLevel "SUCCESS"
} else {
    Log "No stable URL found." -logLevel "ERROR"
}
