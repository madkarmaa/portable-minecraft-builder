@echo off

set java="%~dp0javafolder\bin\javaw.exe"
set launcher="%~dp0launchername"
set workingDirectory="%~dp0datadir"

%java% -jar %launcher% --workDir %workingDirectory%
