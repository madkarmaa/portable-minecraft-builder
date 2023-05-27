$fetchUrl = "https://skmedix.pl/downloads/json"
$outputPath = ".\SKlauncher.jar"

try {
    Add-Type -AssemblyName System.Net.Http
    # Create an HttpClient object
    $httpClient = New-Object System.Net.Http.HttpClient
    # Make a POST request to fetch the JSON data
    $jsonResponse = $httpClient.PostAsync($fetchUrl, $null).Result

    if ($jsonResponse.IsSuccessStatusCode) {
        # Convert the JSON response to a PowerShell object
        $jsonData = ConvertFrom-Json $jsonResponse.Content.ReadAsStringAsync().Result
        # Extract the universal URL from the JSON data
        $downloadUrl = "https://skmedix.pl" + $jsonData.universal
        # Make a GET request to download the file
        $downloadResponse = $httpClient.GetAsync($downloadUrl).Result
    
        if ($downloadResponse.IsSuccessStatusCode) {
            # Read the response content as a byte array
            $fileBytes = $downloadResponse.Content.ReadAsByteArrayAsync().Result
            # Write the byte array to a file
            [System.IO.File]::WriteAllBytes($outputPath, $fileBytes)
        } else {
            throw "Failed to download the launcher file"
        }
    } else {
        throw "Network response was not OK"
    }
    $httpClient.Dispose()
}
catch {
    ErrorLog $_
}