@echo off

set java=".\javafolder\bin\javaw.exe"
set launcher=".\launchername"
set workingDirectory=".\datadir"

%java% -jar %launcher% --workDir %workingDirectory%
