param (
    [Parameter(Mandatory=$true)]
    [string]$projectName,
    [Parameter(Mandatory=$true)]
    [string]$DataFolderName
)

$url = "https://api.modrinth.com/v2/project/$projectName/version"
$response = Invoke-RestMethod -Uri $url -Method GET

$releaseVersions = $response | Where-Object { $_.version_type -eq "release" }

if ($releaseVersions.Count -gt 0) {
    $firstReleaseVersion = $releaseVersions[0]
    $url = $firstReleaseVersion.files[0].url
    $filename = $firstReleaseVersion.files[0].filename

    $destinationDirectory = ".\$DataFolderName\mods"
    $destinationPath = Join-Path $destinationDirectory $filename

    # Create missing directories recursively
    if (-not (Test-Path $destinationDirectory)) {
        New-Item -Path $destinationDirectory -ItemType Directory -Force | Out-Null
    }

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $destinationPath)
    Write-Host "Successfully installed[32m" $firstReleaseVersion.name "[0m"
} else {
    Write-Host "[31mNo release versions found.[0m"
}
