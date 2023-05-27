function Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$message
    )

    $logFilePath = ".\InstallerLog.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fileName = (Get-PSCallStack | Select-Object -Skip 1 -First 1).Command

    $logEntry = "[[34m$timestamp[0m] [[32m$fileName[0m] $message"

    Write-Host $logEntry
    ($logEntry -replace '\e\[[0-9;]*m') | Out-File -Append -FilePath $logFilePath -Force
}