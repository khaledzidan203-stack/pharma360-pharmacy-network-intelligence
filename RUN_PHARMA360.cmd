@echo off
setlocal
if "%~1"=="--verify-only" goto verify
if not "%~1"=="" goto usage
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch_pharma360.ps1"
exit /b %errorlevel%
:verify
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch_pharma360.ps1" -VerifyOnly
exit /b %errorlevel%
:usage
echo Usage: RUN_PHARMA360.cmd [--verify-only]
exit /b 2
