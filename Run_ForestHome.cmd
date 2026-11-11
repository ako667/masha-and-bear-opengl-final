@echo off
cd /d "%~dp0bin"
if not exist ForestHome.exe (
 echo Run build.ps1 first. See README.md.
 pause
 exit /b 1
)
ForestHome.exe
