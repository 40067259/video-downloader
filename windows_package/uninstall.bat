@echo off
setlocal enabledelayedexpansion

REM Video Downloader Chrome Extension Uninstaller for Windows

echo ==========================================
echo Video Downloader Extension Uninstaller
echo ==========================================
echo.

REM Confirm uninstallation
set /p CONFIRM="Are you sure you want to uninstall Video Downloader? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Uninstallation cancelled
    pause
    exit /b 0
)

echo.
echo Removing installed files...

REM Define paths
set "INSTALL_DIR=%LOCALAPPDATA%\video-downloader"
set "BIN_FILE=%LOCALAPPDATA%\Programs\videodl_host.exe"
set "CHROME_MANIFEST=%LOCALAPPDATA%\Google\Chrome\User Data\NativeMessagingHosts\com.videodl.host.json"
set "DOWNLOADS_DIR=%USERPROFILE%\Downloads\VideoDownloader"

REM Remove files
if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%"
    echo [OK] Removed installation directory
)

if exist "%BIN_FILE%" (
    del /F /Q "%BIN_FILE%"
    echo [OK] Removed native host binary
)

if exist "%CHROME_MANIFEST%" (
    del /F /Q "%CHROME_MANIFEST%"
    echo [OK] Removed Chrome configuration
)

echo.
set /p REMOVE_DOWNLOADS="Do you want to remove downloaded files in %DOWNLOADS_DIR%? (Y/N): "
if /i "%REMOVE_DOWNLOADS%"=="Y" (
    if exist "%DOWNLOADS_DIR%" (
        rmdir /S /Q "%DOWNLOADS_DIR%"
        echo [OK] Removed downloaded files
    )
)

echo.
echo ==========================================
echo Uninstallation Complete!
echo ==========================================
echo.
echo The extension files in the plugin\ directory were not removed.
echo You can manually delete them if needed.
echo.
echo Thank you for using Video Downloader!
echo.
pause
