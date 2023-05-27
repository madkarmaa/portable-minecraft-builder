param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
)

Import-Module -Name ".\helper.psm1" -Force

try {
    $webClient = New-Object System.Net.WebClient

    $uri = New-Object System.Uri($Url)
    $filename = [System.IO.Path]::GetFileName($uri.LocalPath)
    $destinationPath = ".\$filename"

    if (Test-Path $destinationPath) {
        Remove-Item -Path $destinationPath -Force
    }

    $webClient.DownloadFile($Url, $destinationPath)
    $webClient.Dispose()

    Log "Successfully downloaded '$filename'" -logLevel "SUCCESS"
}
catch {
    ErrorLog $_
}