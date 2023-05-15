@echo off
setlocal

set "matchPattern=%~1"
set "apiUrl=%~2"

for /f "usebackq tokens=2 delims== " %%G in (`curl -L -s "%apiUrl%" ^| findstr /C:"browser_download_url"`) do (
  echo %%G | findstr /C:"%matchPattern%" > nul && (
    curl -L -o "%%~nG" "%%G"
    exit /b 0
  )
)

exit /b 1