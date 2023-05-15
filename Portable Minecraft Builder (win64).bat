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

set javaUrl=https://dl.dropboxusercontent.com/s/l0dho2lme8h2csv/OpenJDK17U-jdk_x64_windows_hotspot_17.0.7_7.zip
set launcherUrl=https://dl.dropboxusercontent.com/s/oiq7f0vkwuz9ltx/SKlauncher.jar
set batchUrl=https://dl.dropboxusercontent.com/s/iu2fcnk648f0f25/minecraft.bat
set vbsUrl=https://dl.dropboxusercontent.com/s/q5bmyflmiw7nn1a/Minecraft.vbs
set dlUrl=https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/master/asset-downloader.bat
set javaFolder=jre

for %%F in ("%javaUrl%") do set "javaZip=%%~nxF"
for %%F in ("%launcherUrl%") do set "launcherJar=%%~nxF"
for %%F in ("%batchUrl%") do set "batchName=%%~nF"
for %%F in ("%vbsUrl%") do set "vbsName=%%~nF"
for %%F in ("%dlUrl%") do set "dlName=%%~nF"

set batchName=%batchName%.bat
set vbsName=%vbsName%.vbs
set dlName=%dlName%.bat

echo [36mPortable Minecraft Builder (Windows 64 bit only)[0m
echo.
echo [36mUsing SKlauncher and JDK 17 (Temurin 17 LTS)[0m
echo [35mVisit https://skmedix.pl/ and https://adoptium.net/ [0m
echo.
echo [ENTER] to begin the installation process.
pause >NUL 2>&1

curl -L -o "%dlName%" "%dlUrl%" >NUL 2>&1
%~dp0%dlName% *windows_arm64*.tar.gz* https://api.github.com/repos/jreisinger/ghrel/releases/latest
powershell -command "Expand-Archive -Force '%~dp0%dlName%' '%~dp0'"

echo.
set dataFolder=minecraft
set /p dataFolder="Custom name for the Minecraft data folder (optional, [ENTER] to skip): "
set dataFolder=.%dataFolder%

if exist "%dataFolder%" (
    echo.
    set clearDataFolder=n
    set /p clearDataFolder="A folder with this name already exists. Do you want to delete it and so your Minecraft data? [y/(n)]: "
    echo.

    if /I "!clearDataFolder!"=="y" (
        echo [33mDeleting pre-existing Minecraft data folder...[0m
        rmdir /s /q "%dataFolder%"
        echo [32mDone.[0m
    ) else (
        echo [31mSkipped Minecraft data folder creation.[0m
        goto skipDataFolder
    )
)

echo.
echo [33mCreating Minecraft data directory...[0m

mkdir "%~dp0%dataFolder%"

echo [32mDone.[0m

:skipDataFolder

if exist "%javaFolder%" (
    echo.
    set redownloadJava=n
    set /p redownloadJava="The Java folder already exists. Do you want to re-download it? [y/(n)]: "
    echo.

    if /I "!redownloadJava!"=="y" (
        echo [33mDeleting pre-existing Java folder...[0m
        rmdir /s /q "%javaFolder%"
        echo [32mDone.[0m
    ) else (
        echo [31mSkipped Java download.[0m
        goto skipJavaDownload
    )
)

echo.
echo [33mDownloading Java...[0m

curl -L -o "%javaZip%" "%javaUrl%" >NUL 2>&1

echo [32mDone.[0m

echo.
echo [33mExtracting Java...[0m

powershell -command "Expand-Archive -Force '%~dp0%javaZip%' '%~dp0'"

for /d %%i in (jdk*) do (
    ren "%%i" "jre"
)

echo [32mDone.[0m

:skipJavaDownload

echo.
echo [33mDownloading SKlauncher...[0m

curl -L -o "%launcherJar%" "%launcherUrl%" >NUL 2>&1

echo [32mDone.[0m

echo.
echo [33mDownloading templates...[0m

curl -L -o "%batchName%" "%batchUrl%" >NUL 2>&1
curl -L -o "%vbsName%" "%vbsUrl%" >NUL 2>&1

echo [32mDone.[0m

echo.
echo [33mModifying templates...[0m

set tempFile=temp.bat

powershell -command "((Get-Content %batchName%) -replace 'javafolder', '%javaFolder%' -replace 'launchername', '%launcherJar%' -replace 'datadir', '%dataFolder%') | Set-Content %tempFile%"
powershell -command "Get-Content %tempFile% | Set-Content %batchName%"

attrib +h "%~dp0%batchName%"

echo [32mDone.[0m

echo.
echo [33mRemoving unnecessary files...[0m

del "%~dp0%tempFile%" >NUL 2>&1
del "%~dp0%javaZip%" >NUL 2>&1

echo [32mDone.[0m

echo.
echo [31mDO NOT move any of the created files/directories. If you really have to do it, you MUST move them all together.[0m
echo.
echo [35mAll done. Execute %vbsName% to start playing.[0m

echo.
echo [ENTER] to exit the program.
pause >NUL 2>&1