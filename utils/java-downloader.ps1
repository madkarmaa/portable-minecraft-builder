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

# Extract the downloaded ZIP file using tar
Start-Process tar -ArgumentList "-xf", ".\$javaZip", "-C", "." -NoNewWindow -Wait
Remove-Item -Path ".\$javaZip" -Force

# Rename the extracted folder to "jdk"
$extractedFolder = Get-ChildItem -Directory | Where-Object { $_.Name -like "jdk*" }
$newFolderName = "Java"
Rename-Item -Path $extractedFolder.FullName -NewName $newFolderName -Force
