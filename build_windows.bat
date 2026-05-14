@echo off
setlocal

where dotnet >nul 2>&1
if errorlevel 1 (
  echo [ERROR] .NET 8 SDK가 설치되어 있지 않습니다.
  echo 아래 링크에서 설치 후 다시 실행하세요:
  echo https://dotnet.microsoft.com/download/dotnet/8.0
  echo.
  pause
  exit /b 1
)

echo [INFO] Building NumberOverlay.exe ...
dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true -o publish
if errorlevel 1 (
  echo [ERROR] 빌드 실패
  echo.
  pause
  exit /b 1
)

echo [OK] 생성 완료: publish\NumberOverlay.exe
echo.
pause
endlocal
