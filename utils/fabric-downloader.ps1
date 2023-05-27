Import-Module -Name ".\helper.psm1" -Force

try {
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
        Log "No stable URL found." -logLevel "WARNING"
    }
}
catch {
    ErrorLog $_
}