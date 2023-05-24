$is64Bit = [System.Environment]::Is64BitOperatingSystem

if (-not $is64Bit) {
    Write-Host "[31mThis script requires a 64-bit operating system.[0m"
    Pause
    Exit
}

Add-Type -AssemblyName System.Windows.Forms

$folderPath = ".\Java"

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Portable Minecraft Builder (win64)"
$form.Size = New-Object System.Drawing.Size(800, 500)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(53, 55, 64)
$form.ForeColor = [System.Drawing.Color]::White

# Set the accent color to purple
$accentColor = [System.Drawing.Color]::FromArgb(155, 89, 182)
$successColor = [System.Drawing.Color]::FromArgb(124, 252, 0)

# Create the label for SKlauncher and JDK 17
$labelTop = New-Object System.Windows.Forms.Label
$labelTop.Location = New-Object System.Drawing.Point(10, 10)
$labelTop.AutoSize = $true
$labelTop.Text = "Using SKlauncher and JDK 17 (Temurin 17 LTS). Visit https://skmedix.pl/ and https://adoptium.net/"
$labelTop.ForeColor = $accentColor
# $labelTop.Font = "Comic Sans,20"
$form.Controls.Add($labelTop)

# Check if the "jdk" folder exists in the current directory
$jdkFolderExists = Test-Path -Path $folderPath -PathType Container

# Create a label for the "Delete Java folder" switch
$labelDeleteJdk = New-Object System.Windows.Forms.Label
$labelDeleteJdk.Location = New-Object System.Drawing.Point(10, 170)
$labelDeleteJdk.Size = New-Object System.Drawing.Size(200, 30)
$labelDeleteJdk.Text = "Delete pre-existing Java folder?"
$labelDeleteJdk.ForeColor = $accentColor
$form.Controls.Add($labelDeleteJdk)

# Create a switch for the "Delete Java folder" option
$switchDeleteJdk = New-Object System.Windows.Forms.CheckBox
$switchDeleteJdk.Location = New-Object System.Drawing.Point(210, 165)
$switchDeleteJdk.Size = New-Object System.Drawing.Size(20, 30)
$switchDeleteJdk.Add_CheckStateChanged({
    Write-Host "Delete Java:" $switchDeleteJdk.Checked
})
$form.Controls.Add($switchDeleteJdk)

# Create a label for the "Delete data folder" switch
$labelDeleteData = New-Object System.Windows.Forms.Label
$labelDeleteData.Location = New-Object System.Drawing.Point(10, 210)
$labelDeleteData.Size = New-Object System.Drawing.Size(200, 30)
$labelDeleteData.Text = "Delete pre-existing data folder?"
$labelDeleteData.ForeColor = $accentColor
$form.Controls.Add($labelDeleteData)

# Create a switch for the "Delete data folder" option
$switchDeleteData = New-Object System.Windows.Forms.CheckBox
$switchDeleteData.Location = New-Object System.Drawing.Point(210, 205)
$switchDeleteData.Size = New-Object System.Drawing.Size(20, 30)
$switchDeleteData.Add_CheckStateChanged({
    Write-Host "Delete data folder:" $switchDeleteData.Checked
})
$form.Controls.Add($switchDeleteData)

$dataFolderExists = Test-Path -Path ".\.minecraft" -PathType Container

if ($dataFolderExists) {
    $labelDeleteData.Visible = $true
    $switchDeleteData.Visible = $true
} else {
    $labelDeleteData.Visible = $false
    $switchDeleteData.Visible = $false
}

if ($jdkFolderExists) {
    $labelDeleteJdk.Visible = $true
    $switchDeleteJdk.Visible = $true
} else {
    $labelDeleteJdk.Visible = $false
    $switchDeleteJdk.Visible = $false
}

# Create a label for the custom data folder name input
$labelFolder = New-Object System.Windows.Forms.Label
$labelFolder.Location = New-Object System.Drawing.Point(10, 50)
$labelFolder.Size = New-Object System.Drawing.Size(200, 30)
$labelFolder.Text = "Custom data folder name:"
$labelFolder.ForeColor = $accentColor
$form.Controls.Add($labelFolder)

# Create a text input for the custom data folder name
$textFolder = New-Object System.Windows.Forms.TextBox
$textFolder.Location = New-Object System.Drawing.Point(210, 45)
$textFolder.Size = New-Object System.Drawing.Size(250, 30)
$textFolder.Text = ".minecraft"
$textFolder.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$textFolder.ForeColor = [System.Drawing.Color]::White
$textFolder.Add_TextChanged({
    $newText = $textFolder.Text
    $newText = $newText -replace '\s', '-'
    if (-not $newText.StartsWith('.')) {
        $newText = '.' + $newText
    }
    $textFolder.Text = $newText
    $textFolder.SelectionStart = $newText.Length

    $dataFolderExists = (Test-Path -Path ".\$newText" -PathType Container) -and ($newText -ne ".")

    if ($dataFolderExists) {
        $labelDeleteData.Visible = $true
        $switchDeleteData.Visible = $true
    } else {
        $labelDeleteData.Visible = $false
        $switchDeleteData.Visible = $false
    }

    Write-Host "Custom data folder name changed: $newText"
})
$form.Controls.Add($textFolder)

# Create a label for the "Install Fabric" switch
$labelFabric = New-Object System.Windows.Forms.Label
$labelFabric.Location = New-Object System.Drawing.Point(10, 90)
$labelFabric.Size = New-Object System.Drawing.Size(200, 30)
$labelFabric.Text = "Install Fabric:"
$labelFabric.ForeColor = $accentColor
$form.Controls.Add($labelFabric)

# Create a switch for the "Install Fabric" option
$switchFabric = New-Object System.Windows.Forms.CheckBox
$switchFabric.Location = New-Object System.Drawing.Point(210, 85)
$switchFabric.Size = New-Object System.Drawing.Size(20, 30)
$switchFabric.Add_CheckStateChanged({
    Write-Host "Install Fabric:" $switchFabric.Checked
    if ($switchFabric.Checked) {
        $labelMods.Visible = $true
        $switchMods.Visible = $true
    } else {
        $labelMods.Visible = $false
        $switchMods.Visible = $false
    }
})
$form.Controls.Add($switchFabric)

# Create a label for the "Install optimization mods" switch
$labelMods = New-Object System.Windows.Forms.Label
$labelMods.Location = New-Object System.Drawing.Point(10, 130)
$labelMods.Size = New-Object System.Drawing.Size(200, 30)
$labelMods.Text = "Install optimization mods:"
$labelMods.ForeColor = $accentColor
$labelMods.Visible = $false
$form.Controls.Add($labelMods)

# Create a switch for the "Install optimization mods" option
$switchMods = New-Object System.Windows.Forms.CheckBox
$switchMods.Location = New-Object System.Drawing.Point(210, 125)
$switchMods.Size = New-Object System.Drawing.Size(20, 30)
$switchMods.Visible = $false
$switchMods.Add_CheckStateChanged({
    Write-Host "Install optimization mods:" $switchMods.Checked
})
$form.Controls.Add($switchMods)

# Create a button for the installation
$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Size = New-Object System.Drawing.Size(150, 40)
$buttonInstall.Text = "Install"
$buttonInstall.Anchor = [System.Windows.Forms.AnchorStyles]::None
$buttonInstall.Left = ($form.ClientSize.Width - $buttonInstall.Width) / 2
$buttonInstall.Top = $form.ClientSize.Height - $buttonInstall.Height - 50
$buttonInstall.BackColor = $accentColor
$buttonInstall.ForeColor = [System.Drawing.Color]::White
$buttonInstall.Add_Click({
    Write-Host "`n[35m========== INSTALLATION START ==========[0m`n"
    $buttonInstall.Enabled = $false
    $buttonInstall.Text = "Installing..."

    $invalidChars = [IO.Path]::GetInvalidFileNameChars()

    # Check if the input text is "." or contains any invalid characters
    if ($textFolder.Text -eq "." -or $textFolder.Text -match "[{0}]" -f [RegEx]::Escape($invalidChars)) {
        $textFolder.Text = ".minecraft"
    }

    $mcDataFolderExists = Test-Path -Path (Join-Path -Path ".\" -ChildPath $textFolder.Text) -PathType Container

    $Url = "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/file-downloader.ps1"
    $webClient = New-Object System.Net.WebClient

    $uri = New-Object System.Uri($Url)
    $filename = [System.IO.Path]::GetFileName($uri.LocalPath)
    $destinationPath = ".\$filename"

    $webClient.DownloadFile($Url, $destinationPath)

    $webClient.Dispose()

    Start-Process powershell.exe -ArgumentList "-Command", '".\file-downloader.ps1"', "-Url", '"https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/portable-minecraft-builder.ps1"' -NoNewWindow -Wait

    $dlJava = $true
    if ($switchDeleteJdk.Visible) {
        $dlJava = $switchDeleteJdk.Checked
    }

    if ($dlJava -and $jdkFolderExists) {
        Remove-Item -Path $folderPath -Recurse
    }

    $removeData = $true
    if ($switchDeleteData.Visible) {
        $removeData = $switchDeleteData.Checked
    }

    if ($removeData -and $mcDataFolderExists) {
        Remove-Item -Path (Join-Path -Path ".\" -ChildPath $textFolder.Text) -Recurse
    }

    Start-Process powershell.exe -ArgumentList "-Command", '".\portable-minecraft-builder.ps1"', "-DataFolderName", $textFolder.Text, "-InstallFabric", $switchFabric.Checked.ToString(), "-InstallMods", $switchMods.Checked.ToString(), "-DownloadJava", $dlJava.ToString() -NoNewWindow -Wait
    Remove-Item -Path ".\portable-minecraft-builder.ps1" -Force

    $buttonInstall.BackColor = $successColor
    $buttonInstall.Text = "Done!"

    Write-Host "`n[35m========== INSTALLATION END ==========[0m"
})
$form.Controls.Add($buttonInstall)

# Show the form
[void]$form.ShowDialog()