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

$apiUrl = "https://api.github.com/repos/adoptium/temurin17-binaries/releases/latest"
$javaMatchPattern = "OpenJDK17U-jdk_x64_windows_hotspot*.zip"

# Download the Java file matching the pattern
$javaZip = Invoke-RestMethod -Uri $apiUrl |
    Select-Object -ExpandProperty assets |
    Where-Object { $_.name -like $javaMatchPattern } |
    ForEach-Object {
        $assetUrl = $_.browser_download_url
        $outputPath = Join-Path (Get-Location) $_.name
        (New-Object System.Net.WebClient).DownloadFile($assetUrl, $outputPath)

        $_.name
    }

Log "Successfully downloaded '$javaZip'" -logLevel "SUCCESS"

# Extract the downloaded ZIP file using tar
Start-Process tar -ArgumentList "-xf", ".\$javaZip", "-C", "." -NoNewWindow -Wait
Remove-Item -Path ".\$javaZip" -Force

# Rename the extracted folder to "jdk"
$extractedFolder = Get-ChildItem -Directory | Where-Object { $_.Name -like "jdk*" }
$newFolderName = "Java"
Rename-Item -Path $extractedFolder.FullName -NewName $newFolderName -Force

Log "Successfully extracted '$javaZip'" -logLevel "SUCCESS"