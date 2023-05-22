$is64Bit = [System.Environment]::Is64BitOperatingSystem

if (-not $is64Bit) {
    Write-Host "This script requires a 64-bit operating system."
    Pause
    Exit
}

Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Portable Minecraft Builder (win64)"
$form.Size = New-Object System.Drawing.Size(800, 500)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(53, 55, 64)
$form.ForeColor = [System.Drawing.Color]::White

# Set the accent color to purple
$accentColor = [System.Drawing.Color]::FromArgb(155, 89, 182)

# Create the label for SKlauncher and JDK 17
$labelTop = New-Object System.Windows.Forms.Label
$labelTop.Location = New-Object System.Drawing.Point(10, 10)
$labelTop.Size = New-Object System.Drawing.Size(600, 30)
$labelTop.Text = "Using SKlauncher and JDK 17 (Temurin 17 LTS). Visit https://skmedix.pl/ and https://adoptium.net/"
$labelTop.ForeColor = $accentColor
$form.Controls.Add($labelTop)

# Check if the "jdk" folder exists in the current directory
$jdkFolderExists = Test-Path -Path ".\jdk" -PathType Container

# Create a label for the "Install Fabric" switch
$labelDeleteJdk = New-Object System.Windows.Forms.Label
$labelDeleteJdk.Location = New-Object System.Drawing.Point(10, 170)
$labelDeleteJdk.Size = New-Object System.Drawing.Size(200, 30)
$labelDeleteJdk.Text = "Delete pre-existing Java folder?"
$labelDeleteJdk.ForeColor = $accentColor
$form.Controls.Add($labelDeleteJdk)

# Create a switch for the "Install Fabric" option
$switchDeleteJdk = New-Object System.Windows.Forms.CheckBox
$switchDeleteJdk.Location = New-Object System.Drawing.Point(210, 165)
$switchDeleteJdk.Size = New-Object System.Drawing.Size(20, 30)
$switchDeleteJdk.Add_CheckStateChanged({
    Write-Host "Delete JDK:" $switchDeleteJdk.Checked
})
$form.Controls.Add($switchDeleteJdk)


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
    Write-Host "Installing..."
    $buttonInstall.Enabled = $false
    $buttonInstall.Text = "Installing..."

    $Url = "https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/file-downloader.ps1"
    $webClient = New-Object System.Net.WebClient

    $uri = New-Object System.Uri($Url)
    $filename = [System.IO.Path]::GetFileName($uri.LocalPath)
    $destinationPath = ".\$filename"

    $webClient.DownloadFile($Url, $destinationPath)

    $webClient.Dispose()

    Start-Process powershell.exe -ArgumentList "-File", '".\file-downloader.ps1"', "-Url", '"https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/portable-minecraft-builder.ps1"' -NoNewWindow

    if ($switchDeleteJdk.Checked) {
        $folderPath = ".\jdk"

        if (Test-Path -Path $folderPath) {
            Remove-Item -Path $folderPath -Recurse
        }
    }

    $installFabricString = if ($switchFabric.Checked) { "true" } else { "false" }
    $installModsString = if ($switchMods.Checked) { "true" } else { "false" }

    Start-Process -FilePath powershell.exe -ArgumentList "-File", '".\portable-minecraft-builder.ps1"', "-DataFolderName", $textFolder.Text, "-InstallFabric", $installFabricString, "-InstallMods", $installModsString -NoNewWindow
})
$form.Controls.Add($buttonInstall)

# Show the form
[void]$form.ShowDialog()
