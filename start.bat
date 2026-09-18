@echo off
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul

set "MANAGER=%~dp0target\release\codex-plus-plus-manager.exe"
if not exist "%MANAGER%" (
  echo Chua build. Chay setup.bat truoc.
  exit /b 1
)

start "" "%MANAGER%"
exit /b 0
