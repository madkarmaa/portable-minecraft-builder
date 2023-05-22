param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
)

$webClient = New-Object System.Net.WebClient

$uri = New-Object System.Uri($Url)
$filename = [System.IO.Path]::GetFileName($uri.LocalPath)
$destinationPath = Join-Path $env:TEMP $filename

$webClient.DownloadFile($Url, $destinationPath)

$webClient.Dispose()
