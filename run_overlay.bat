@echo off
setlocal

echo [INFO] Starting overlay...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0number_overlay.ps1"

if errorlevel 1 (
  echo.
  echo [ERROR] Failed to start overlay.
  echo - Check if PowerShell is blocked by policy.
  echo - Try running CMD as administrator once.
  echo.
  pause
  exit /b 1
)

endlocal
