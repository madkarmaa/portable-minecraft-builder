$host.ui.RawUI.WindowTitle = "Portable Minecraft Builder"

$is64Bit = [System.Environment]::Is64BitOperatingSystem

if (-not $is64Bit) {
    Write-Host "[31mThis script requires a 64-bit operating system.[0m"
    Pause
    Exit 1
}

Import-Module -Name ".\helper.psm1" -Force

$folderPath = ".\Java"

try {
    Add-Type -AssemblyName System.Windows.Forms

    # Color palette
    $accentColor1 = [System.Drawing.Color]::FromArgb(25, 23, 37)
    # $accentColor2 = [System.Drawing.Color]::FromArgb(89, 81, 140)
    $accentColor3 = [System.Drawing.Color]::FromArgb(117, 108, 191)
    $accentColor4 = [System.Drawing.Color]::FromArgb(202, 172, 242)
    $accentColor5 = [System.Drawing.Color]::FromArgb(241, 195, 242)
    $successColor = [System.Drawing.Color]::FromArgb(124, 252, 0)

    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Portable Minecraft Builder (win64)"
    $form.Size = New-Object System.Drawing.Size(800, 500)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = $accentColor1
    $form.ForeColor = [System.Drawing.Color]::White

    # Create the label for the title
    $title = New-Object System.Windows.Forms.Label
    $title.Size = New-Object System.Drawing.Size(410, 40)
    $title.Anchor = [System.Windows.Forms.AnchorStyles]::None
    $title.Left = ($form.ClientSize.Width - $title.Width) / 2
    $title.Top = 10
    $title.Text = "Portable Minecraft Builder"
    $title.ForeColor = $accentColor3
    $title.Font = "Lucida Console Regular,20"
    $form.Controls.Add($title)

    # Create the label for attributions
    $labelTop = New-Object System.Windows.Forms.Label
    $labelTop.Size = New-Object System.Drawing.Size(390, 20)
    $labelTop.Anchor = [System.Windows.Forms.AnchorStyles]::None
    $labelTop.Left = ($form.ClientSize.Width - $labelTop.Width) / 2
    $labelTop.Top = 55
    $labelTop.AutoSize = $true
    $labelTop.Text = "Using SKlauncher and JDK 17 (Temurin 17 LTS)."
    $labelTop.ForeColor = $accentColor4
    $labelTop.Font = "Lucida Console Regular,10, style=Underline"
    $form.Controls.Add($labelTop)

    # Create a label for the logo
    $labelLogo = New-Object System.Windows.Forms.Label
    $labelLogo.Anchor = [System.Windows.Forms.AnchorStyles]::None
    $labelLogo.Top = 10
    $labelLogo.Size = New-Object System.Drawing.Size(100, 50)
    $labelLogo.Left = ($form.ClientSize.Width - $labelLogo.Width) - 10
    $labelLogo.Text = 'mk'
    $labelLogo.Font = "Lucida Console Regular,40"
    $labelLogo.ForeColor = $accentColor3
    $labelLogo.Add_Click({
        $url = "https://github.com/madkarmaa/"
        Start-Process $url
    })
    $form.Controls.Add($labelLogo)

    # Check if the "jdk" folder exists in the current directory
    $jdkFolderExists = Test-Path -Path $folderPath -PathType Container

    # Create a label for the "Delete Java folder" switch
    $labelDeleteJdk = New-Object System.Windows.Forms.Label
    $labelDeleteJdk.Location = New-Object System.Drawing.Point(10, 220)
    $labelDeleteJdk.Size = New-Object System.Drawing.Size(210, 50)
    $labelDeleteJdk.Text = "Delete pre-existing Java folder?"
    $labelDeleteJdk.Font = "Lucida Console Regular,10"
    $labelDeleteJdk.ForeColor = $accentColor5
    $form.Controls.Add($labelDeleteJdk)

    # Create a switch for the "Delete Java folder" option
    $switchDeleteJdk = New-Object System.Windows.Forms.CheckBox
    $switchDeleteJdk.Location = New-Object System.Drawing.Point(230, 217)
    $switchDeleteJdk.Size = New-Object System.Drawing.Size(30, 30)
    $switchDeleteJdk.Add_CheckStateChanged({
        Write-Host "Delete Java:" $switchDeleteJdk.Checked
    })
    $form.Controls.Add($switchDeleteJdk)

    # Create a label for the "Delete data folder" switch
    $labelDeleteData = New-Object System.Windows.Forms.Label
    $labelDeleteData.Location = New-Object System.Drawing.Point(10, 270)
    $labelDeleteData.Size = New-Object System.Drawing.Size(210, 50)
    $labelDeleteData.Text = "Delete pre-existing data folder?"
    $labelDeleteData.Font = "Lucida Console Regular,10"
    $labelDeleteData.ForeColor = $accentColor5
    $form.Controls.Add($labelDeleteData)

    # Create a switch for the "Delete data folder" option
    $switchDeleteData = New-Object System.Windows.Forms.CheckBox
    $switchDeleteData.Location = New-Object System.Drawing.Point(230, 267)
    $switchDeleteData.Size = New-Object System.Drawing.Size(30, 30)
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
    $labelFolder.Location = New-Object System.Drawing.Point(10, 100)
    $labelFolder.Size = New-Object System.Drawing.Size(210, 30)
    $labelFolder.Text = "Custom data folder name:"
    $labelFolder.Font = "Lucida Console Regular,10"
    $labelFolder.ForeColor = $accentColor5
    $form.Controls.Add($labelFolder)

    # Create a text input for the custom data folder name
    $textFolder = New-Object System.Windows.Forms.TextBox
    $textFolder.Location = New-Object System.Drawing.Point(230, 100)
    $textFolder.Size = New-Object System.Drawing.Size(250, 30)
    $textFolder.Text = ".minecraft"
    $textFolder.BackColor = [System.Drawing.Color]::White
    $textFolder.ForeColor = [System.Drawing.Color]::Black
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
    $labelFabric.Location = New-Object System.Drawing.Point(10, 140)
    $labelFabric.Size = New-Object System.Drawing.Size(210, 30)
    $labelFabric.Text = "Install Fabric:"
    $labelFabric.Font = "Lucida Console Regular,10"
    $labelFabric.ForeColor = $accentColor5
    $form.Controls.Add($labelFabric)

    # Create a switch for the "Install Fabric" option
    $switchFabric = New-Object System.Windows.Forms.CheckBox
    $switchFabric.Location = New-Object System.Drawing.Point(230, 137)
    $switchFabric.Size = New-Object System.Drawing.Size(30, 30)
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
    $labelMods.Location = New-Object System.Drawing.Point(10, 180)
    $labelMods.Size = New-Object System.Drawing.Size(210, 30)
    $labelMods.Text = "Install optimization mods:"
    $labelMods.Font = "Lucida Console Regular,10"
    $labelMods.ForeColor = $accentColor5
    $labelMods.Visible = $false
    $form.Controls.Add($labelMods)

    # Create a switch for the "Install optimization mods" option
    $switchMods = New-Object System.Windows.Forms.CheckBox
    $switchMods.Location = New-Object System.Drawing.Point(230, 177)
    $switchMods.Size = New-Object System.Drawing.Size(30, 30)
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
    $buttonInstall.BackColor = $accentColor3
    $buttonInstall.ForeColor = [System.Drawing.Color]::White
    $buttonInstall.Add_Click({
        Log "========== INSTALLATION START =========="
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

        Start-Process powershell.exe -ArgumentList "-Command", '".\file-downloader.ps1"', "-Url", '"https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/gui/utils/portable-minecraft-builder.ps1"' -NoNewWindow -Wait

        $dlJava = $true
        if ($switchDeleteJdk.Visible) {
            $dlJava = $switchDeleteJdk.Checked
        }

        if ($dlJava -and $jdkFolderExists) {
            Remove-Item -Path $folderPath -Recurse -Force
        }

        $removeData = $true
        if ($switchDeleteData.Visible) {
            $removeData = $switchDeleteData.Checked
        }

        if ($removeData -and $mcDataFolderExists) {
            Remove-Item -Path (Join-Path -Path ".\" -ChildPath $textFolder.Text) -Recurse -Force
        }

        Start-Process powershell.exe -ArgumentList "-Command", '".\portable-minecraft-builder.ps1"', "-DataFolderName", $textFolder.Text, "-InstallFabric", $switchFabric.Checked.ToString(), "-InstallMods", $switchMods.Checked.ToString(), "-DownloadJava", $dlJava.ToString() -NoNewWindow -Wait
        Remove-Item -Path ".\portable-minecraft-builder.ps1" -Force

        $buttonInstall.BackColor = $successColor
        $buttonInstall.Text = "Done!"

        Log "========== INSTALLATION END ==========" -logLevel "SUCCESS"
        Log "Please close the GUI window and not this window." -logLevel "WARNING"
    })
    $form.Controls.Add($buttonInstall)

    # Show the form
    [void]$form.ShowDialog()
}
catch {
    ErrorLog $_
}