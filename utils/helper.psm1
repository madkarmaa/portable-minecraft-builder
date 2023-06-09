function Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$message,
        [string]$logLevel = "INFO"
    )

    $logFilePath = Join-Path $env:TEMP "InstallerLog.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fileName = (Get-PSCallStack | Where-Object Command | Select-Object -Skip 1 -First 1).Command

    $levelColor = @{
        "INFO"    = "[36m"
        "WARN"    = "[33m"
        "WARNING" = "[33m"
        "ERROR"   = "[31m"
        "SUCCESS" = "[32m"
    }

    $level = $levelColor[$logLevel.ToUpper()] + $logLevel + "[0m"
    $logEntry = "[[34m$timestamp[0m] [[35m$fileName[0m] [$level] $message"

    Write-Host $logEntry
    ($logEntry -replace '\e\[[0-9;]*m') | Out-File -Append -FilePath $logFilePath -Force
}

function ErrorLog {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $logFilePath = Join-Path $env:TEMP "InstallerLog.txt"
    Log "An error occurred, please check $logFilePath for more details." -logLevel "ERROR"

    $scriptName = (Get-PSCallStack | Where-Object Command | Select-Object -Skip 1 -First 1).Command
    $errorMessage = "========== Exception in $scriptName =========="
    $errorMessage += "`nLine: $($ErrorRecord.InvocationInfo.ScriptLineNumber)"
    $errorMessage += "`nColumn: $($ErrorRecord.InvocationInfo.OffsetInLine)"
    $errorMessage += "`nMessage: $($ErrorRecord.Exception.Message)"

    $errorMessage | Out-File -Append -FilePath $logFilePath -Force
}