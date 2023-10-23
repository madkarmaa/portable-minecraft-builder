@echo off

cd "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/madkarmaa/portable-minecraft-builder/main/pmb.ps1 | iex"