param (
    [Parameter(Mandatory=$true)]
    [string]$projectName
)

$url = "https://api.modrinth.com/v2/project/$projectName/version"
$response = Invoke-RestMethod -Uri $url -Method GET

$releaseVersions = $response | Where-Object { $_.version_type -eq "release" }

if ($releaseVersions.Count -gt 0) {
    $firstReleaseVersion = $releaseVersions[0]
    $url = $firstReleaseVersion.files[0].url
    $filename = $firstReleaseVersion.files[0].filename

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, ".\$filename")
    Write-Host "File downloaded successfully."
} else {
    Write-Host "No release versions found."
}
