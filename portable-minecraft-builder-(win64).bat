@echo off
setlocal enabledelayedexpansion

title Portable Minecraft Builder (win64)

if "%PROCESSOR_ARCHITECTURE%" neq "AMD64" (
    echo [31mThis script requires a 64-bit version of Windows.[0m
    echo.
    echo [ENTER] to exit the program.
    pause >NUL 2>&1
    exit /b 1
)

set batchUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/templates/minecraft.bat
set vbsUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/templates/Minecraft.vbs
set apiUrl=https://api.github.com/repos/adoptium/temurin17-binaries/releases/latest
set pwsUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/utils/launcher-downloader.ps1
set fabricInstallerUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/utils/fabric-installer.bat
set modsDlUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/utils/mods-downloader.ps1

set javaMatchPattern=OpenJDK17U-jdk_x64_windows_hotspot*.zip

for %%F in ("%batchUrl%") do set "batchName=%%~nF"
for %%F in ("%vbsUrl%") do set "vbsName=%%~nF"
for %%F in ("%pwsUrl%") do set "pwsName=%%~nF"
for %%F in ("%modsDlUrl%") do set "modsDlName=%%~nF"
for %%F in ("%fabricInstallerUrl%") do set "fabricInstallerName=%%~nF"

set javaFolder=jdk
set javaZip=java.zip
set batchName=%batchName%.bat
set vbsName=%vbsName%.vbs
set pwsName=%pwsName%.ps1
set modsDlName=%modsDlName%.ps1
set fabricInstallerName=%fabricInstallerName%.bat
set launcherJar=SKlauncher.jar
set tempFile=temp

echo [36mPortable Minecraft Builder (Windows 64-bit only)[0m
echo.
echo [36mUsing SKlauncher and JDK 17 (Temurin 17 LTS)[0m
echo [35mVisit https://skmedix.pl/ and https://adoptium.net/ [0m
echo.
echo [ENTER] to begin the installation process.
pause >NUL 2>&1

echo.
echo [33mSetting up requirements...[0m

if exist ".\%vbsName%" (
    del /F ".\%vbsName%" >NUL 2>&1
)

if exist ".\%batchName%" (
    del /F /AH ".\%batchName%" >NUL 2>&1
)

if exist ".\%launcherJar%" (
    del /F /AH ".\%launcherJar%" >NUL 2>&1
)

powershell -command "(New-Object System.Net.WebClient).DownloadFile('%pwsUrl%', '.\%pwsName%')" >NUL 2>&1
powershell -command "(New-Object System.Net.WebClient).DownloadFile('%fabricInstallerUrl%', '.\%fabricInstallerName%')" >NUL 2>&1
powershell -command "(New-Object System.Net.WebClient).DownloadFile('%modsDlUrl%', '.\%modsDlName%')" >NUL 2>&1

echo [32mDone.[0m

echo.
set dataFolder=minecraft
set /p dataFolder="Custom name for the Minecraft data folder (optional, [ENTER] to skip): "
set dataFolder=%dataFolder: =-%
set dataFolder=.%dataFolder%

if exist ".\%dataFolder%" (
    echo.
    set clearDataFolder=n
    set /p clearDataFolder="A folder with this name already exists. Do you want to delete it and so your Minecraft data? [y/(n)]: "
    echo.

    if /I "!clearDataFolder!"=="y" (
        echo [33mDeleting pre-existing Minecraft data folder...[0m
        rmdir /s /q ".\%dataFolder%"
        echo [32mDone.[0m
    ) else (
        echo [31mSkipped Minecraft data folder creation.[0m
        goto skipDataFolder
    )
)

set addFabric=n
set /p addFabric="Do you want to add Fabric to your versions? (latest game version) [y/(n)]: "

echo.
echo [33mCreating Minecraft data directory...[0m

mkdir ".\%dataFolder%"

echo [32mDone.[0m

:skipDataFolder

if exist ".\%javaFolder%" (
    echo.
    set redownloadJava=n
    set /p redownloadJava="The Java folder already exists. Do you want to re-download it? [y/(n)]: "
    echo.

    if /I "!redownloadJava!"=="y" (
        echo [33mDeleting pre-existing Java folder...[0m
        rmdir /s /q ".\%javaFolder%"
        echo [32mDone.[0m
    ) else (
        echo [31mSkipped Java download.[0m
        goto skipJavaDownload
    )
)

echo.
echo [33mDownloading Java...[0m

powershell -Command "Invoke-RestMethod -Uri '%apiUrl%' | Select-Object -ExpandProperty assets | Where-Object { $_.name -like '%javaMatchPattern%' } | ForEach-Object { $assetUrl = $_.browser_download_url; $outputPath = Join-Path (Get-Location) $_.name; (New-Object System.Net.WebClient).DownloadFile($assetUrl, $outputPath) }"

echo [32mDone.[0m

echo.
echo [33mExtracting Java...[0m

for /F "delims=" %%G in ('powershell -command "Get-ChildItem -Filter '%javaMatchPattern%'"') do (
    for %%F in (%%G) do (
        set "javaZip=%%~nxF"
    )
)

tar -xf ".\%javaZip%" -C .

for /d %%i in (jdk*) do (
    ren "%%i" "%javaFolder%"
)

echo [32mDone.[0m

:skipJavaDownload

echo.
echo [33mDownloading SKlauncher...[0m

powershell -ExecutionPolicy Bypass -File "%pwsName%" >NUL 2>&1

attrib +h ".\%launcherJar%"

echo [32mDone.[0m

echo.
echo [33mDownloading templates...[0m

powershell -command "(New-Object System.Net.WebClient).DownloadFile('%batchUrl%', '.\%batchName%')" >NUL 2>&1
powershell -command "(New-Object System.Net.WebClient).DownloadFile('%vbsUrl%', '.\%vbsName%')" >NUL 2>&1

echo [32mDone.[0m

echo.
echo [33mModifying templates...[0m

powershell -command "((Get-Content %batchName%) -replace 'javafolder', '%javaFolder%' -replace 'launchername', '%launcherJar%' -replace 'datadir', '%dataFolder%') | Set-Content %tempFile%"
powershell -command "Get-Content %tempFile% | Set-Content %batchName%"

if exist ".\%tempFile%" (
    del /F ".\%tempFile%" >NUL 2>&1
)

powershell -command "((Get-Content %fabricInstallerName%) -replace 'javafolder', '%javaFolder%' -replace 'launchername', '%launcherJar%' -replace 'datadir', '%dataFolder%') | Set-Content %tempFile%"
powershell -command "Get-Content %tempFile% | Set-Content %fabricInstallerName%"

if exist ".\%tempFile%" (
    del /F ".\%tempFile%" >NUL 2>&1
)

powershell -command "((Get-Content %modsDlName%) -replace 'datadir', '%dataFolder%') | Set-Content %tempFile%"
powershell -command "Get-Content %tempFile% | Set-Content %modsDlName%"

if exist ".\%tempFile%" (
    del /F ".\%tempFile%" >NUL 2>&1
)

attrib +h ".\%batchName%"

echo [32mDone.[0m

echo.

set addOpt=n

if /I "!addFabric!"=="y" (
    echo [33mInstalling Fabric...[0m
    echo.

    call ".\%fabricInstallerName%"

    echo [32mDone.[0m
    echo.

    set /p addOpt="Do you want to add Fabric-based optimization mods? (latest game version) [y/(n)]: "
    echo.

    if /I "!addOpt!"=="y" (
        echo [33mInstalling mods...[0m
        echo.

        powershell -ExecutionPolicy Bypass -File "%modsDlName%" fabric-api
        powershell -ExecutionPolicy Bypass -File "%modsDlName%" iris
        powershell -ExecutionPolicy Bypass -File "%modsDlName%" lithium
        powershell -ExecutionPolicy Bypass -File "%modsDlName%" sodium
        powershell -ExecutionPolicy Bypass -File "%modsDlName%" starlight

        echo.
        echo [32mDone.[0m
    ) else (
        echo [31mSkipped adding mods.[0m
    )
) else (
    echo [31mSkipped installing Fabric.[0m
)

echo.
echo [33mRemoving unnecessary files...[0m

if exist ".\%javaZip%" (
    del /F ".\%javaZip%" >NUL 2>&1
)

if exist ".\%pwsName%" (
    del /F ".\%pwsName%" >NUL 2>&1
)

if exist ".\%fabricInstallerName%" (
    del /F ".\%fabricInstallerName%" >NUL 2>&1
)

if exist ".\%modsDlName%" (
    del /F ".\%modsDlName%" >NUL 2>&1
)

echo [32mDone.[0m

echo.
echo [31mDO NOT move any of the created files/directories. If you really have to do it, you MUST move them all together.[0m
echo.
echo [33mTwo files have been set as hidden, since you don't need to execute them.[0m
echo [33mIf they're not visible, yet you want to see them, enable 'Show hidden files' in the file explorer.[0m
echo.
echo [35mAll done. Execute %vbsName% to start playing.[0m

echo.
echo [ENTER] to exit the program.
pause >NUL 2>&1