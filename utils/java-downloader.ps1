Import-Module -Name ".\helper.psm1" -Force

$apiUrl = "https://api.github.com/repos/adoptium/temurin17-binaries/releases/latest"
$javaMatchPattern = "OpenJDK17U-jdk_x64_windows_hotspot*.zip"

try {
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
}
catch {
    ErrorLog $_
}