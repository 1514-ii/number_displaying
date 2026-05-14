@echo off
setlocal

where dotnet >nul 2>&1
if errorlevel 1 (
  echo [ERROR] .NET 8 SDK is not installed.
  echo Install from: https://dotnet.microsoft.com/download/dotnet/8.0
  echo.
  pause
  exit /b 1
)

echo [INFO] Building NumberOverlay.exe ...
dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true -o publish
if errorlevel 1 (
  echo [ERROR] Build failed.
  echo.
  pause
  exit /b 1
)

echo [OK] Done: publish\NumberOverlay.exe
echo.
pause
endlocal
