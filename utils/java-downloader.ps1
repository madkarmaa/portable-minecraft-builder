$apiUrl = "https://api.github.com/repos/adoptium/temurin17-binaries/releases/latest"
$javaMatchPattern = "OpenJDK17U-jdk_x64_windows_hotspot*.zip"

Invoke-RestMethod -Uri $apiUrl |
    Select-Object -ExpandProperty assets |
    Where-Object { $_.name -like $javaMatchPattern } |
    ForEach-Object {
        $assetUrl = $_.browser_download_url
        $outputPath = Join-Path (Get-Location) $_.name
        (New-Object System.Net.WebClient).DownloadFile($assetUrl, $outputPath)
    }
