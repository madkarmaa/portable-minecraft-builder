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

Add-Type -AssemblyName System.Net.Http

$fetchUrl = "https://skmedix.pl/downloads/json"
$outputPath = ".\SKlauncher.jar"

# Create an HttpClient object
$httpClient = New-Object System.Net.Http.HttpClient

try {
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
            throw "Failed to download the file"
        }
    } else {
        throw "Network response was not OK"
    }
} catch {
    throw "An error occurred: $_"
} finally {
    # Dispose of the HttpClient object
    $httpClient.Dispose()
}

# File downloaded successfully
