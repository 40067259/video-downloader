@echo off
setlocal enabledelayedexpansion

REM Video Downloader Chrome Extension Installer for Windows

echo ==========================================
echo Video Downloader Extension Installer
echo ==========================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Warning: Not running as administrator
    echo Some operations may fail without admin privileges
    echo.
    pause
)

REM Get the script directory
set "SCRIPT_DIR=%~dp0"
echo Installation directory: %SCRIPT_DIR%
echo.

REM Check if native_host.exe already exists (pre-compiled)
set "NEED_COMPILE=0"
if not exist "%SCRIPT_DIR%native_host.exe" (
    set "NEED_COMPILE=1"
    echo Pre-compiled native_host.exe not found
    echo Will compile from source...
    echo.

    REM Check for g++ (MinGW)
    echo Checking for C++ compiler...
    where g++ >nul 2>&1
    if %errorLevel% neq 0 (
        echo Error: g++ not found
        echo Please install MinGW-w64 or Visual Studio
        echo Download from: https://www.mingw-w64.org/
        echo.
        echo Alternatively, download the pre-compiled version from:
        echo https://github.com/40067259/video-downloader/releases
        pause
        exit /b 1
    )
    echo [OK] g++ found
    echo.
) else (
    echo [OK] Using pre-compiled native_host.exe
    echo.
)

REM Create installation directories
echo Creating directories...
set "INSTALL_DIR=%LOCALAPPDATA%\video-downloader"
set "TOOLS_DIR=%INSTALL_DIR%\tools"
set "BIN_DIR=%LOCALAPPDATA%\Programs"
set "CHROME_DIR=%LOCALAPPDATA%\Google\Chrome\User Data\NativeMessagingHosts"
set "DOWNLOADS_DIR=%USERPROFILE%\Downloads\VideoDownloader"

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    if %errorLevel% neq 0 (
        echo Error: Failed to create %INSTALL_DIR%
        echo Please check permissions
        pause
        exit /b 1
    )
)
if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"
if not exist "%BIN_DIR%" (
    mkdir "%BIN_DIR%"
    if %errorLevel% neq 0 (
        echo Error: Failed to create %BIN_DIR%
        echo Please run as administrator
        pause
        exit /b 1
    )
)
if not exist "%CHROME_DIR%" mkdir "%CHROME_DIR%"
if not exist "%DOWNLOADS_DIR%" mkdir "%DOWNLOADS_DIR%"

echo [OK] Directories created
echo   - Install: %INSTALL_DIR%
echo   - Binary: %BIN_DIR%
echo   - Downloads: %DOWNLOADS_DIR%
echo.

REM Compile native_host if needed
if "%NEED_COMPILE%"=="1" (
    echo Compiling native messaging host...
    cd /d "%SCRIPT_DIR%"
    g++ -std=c++11 -o native_host.exe native_host.cpp -lws2_32
    if %errorLevel% neq 0 (
        echo Error: Compilation failed
        echo Please make sure json.hpp is in the windows_package directory
        pause
        exit /b 1
    )
    echo [OK] Compilation successful
    echo.
) else (
    echo Skipping compilation (using pre-compiled binary)
    echo.
)

REM Copy files
echo Installing files...

REM Check if native_host.exe exists
if not exist "%SCRIPT_DIR%native_host.exe" (
    echo Error: native_host.exe not found in %SCRIPT_DIR%
    echo Please make sure you extracted all files correctly
    pause
    exit /b 1
)

REM Show debug info
echo Debug: Source file: %SCRIPT_DIR%native_host.exe
echo Debug: Destination: %BIN_DIR%\videodl_host.exe
echo.

REM Copy with error checking
copy /Y "%SCRIPT_DIR%native_host.exe" "%BIN_DIR%\videodl_host.exe"
if %errorLevel% neq 0 (
    echo.
    echo Error: Failed to copy native_host.exe
    echo Source: %SCRIPT_DIR%native_host.exe
    echo Destination: %BIN_DIR%\videodl_host.exe
    echo.
    echo Possible solutions:
    echo   1. Make sure you're running as Administrator
    echo   2. Check if antivirus is blocking the file
    echo   3. Try closing Chrome and running again
    pause
    exit /b 1
)
echo [OK] Native host installed to: %BIN_DIR%\videodl_host.exe

REM Copy download tools
if exist "yt-dlp.exe" (
    copy /Y yt-dlp.exe "%TOOLS_DIR%\" >nul
    echo [OK] yt-dlp.exe installed
) else (
    echo Warning: yt-dlp.exe not found, YouTube downloads won't work
    echo Download from: https://github.com/yt-dlp/yt-dlp/releases
)

if exist "N_m3u8DL-RE.exe" (
    copy /Y N_m3u8DL-RE.exe "%TOOLS_DIR%\" >nul
    echo [OK] N_m3u8DL-RE.exe installed
) else (
    echo Warning: N_m3u8DL-RE.exe not found, M3U8 downloads won't work
    echo Download from: https://github.com/nilaoda/N_m3u8DL-RE/releases
)

echo.

REM Get Chrome extension ID
echo ==========================================
echo Chrome Extension Setup
echo ==========================================
echo.
echo Please provide your Chrome extension ID.
echo You can find it in chrome://extensions/ (enable Developer mode)
echo.
set /p EXTENSION_ID="Enter extension ID (or press Enter for default): "

if "%EXTENSION_ID%"=="" (
    set "EXTENSION_ID=nkbcigemlaglenoffcejlcokdjjffbpp"
    echo Using default ID: !EXTENSION_ID!
)

echo.

REM Create native messaging host manifest
echo Creating native messaging configuration...
set "MANIFEST_FILE=%CHROME_DIR%\com.videodl.host.json"

REM Replace backslashes with forward slashes for JSON
set "BIN_PATH=%BIN_DIR%\videodl_host.exe"
set "BIN_PATH=%BIN_PATH:\=/%"

(
echo {
echo   "name": "com.videodl.host",
echo   "description": "Native host for Video Downloader extension",
echo   "path": "%BIN_PATH%",
echo   "type": "stdio",
echo   "allowed_origins": [
echo     "chrome-extension://%EXTENSION_ID%/"
echo   ]
echo }
) > "%MANIFEST_FILE%"

echo [OK] Configuration created
echo.

REM Register with Chrome via Registry (Required for Windows)
echo Registering native messaging host in Windows Registry...
reg add "HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\com.videodl.host" /ve /t REG_SZ /d "%MANIFEST_FILE%" /f >nul 2>&1
if %errorLevel% neq 0 (
    echo Warning: Failed to add registry key
    echo The extension may not work without registry configuration
    echo Please run this script as Administrator
) else (
    echo [OK] Registry key added
)
echo.

echo ==========================================
echo Installation Complete!
echo ==========================================
echo.
echo Installation Summary:
echo   Native host: %BIN_DIR%\videodl_host.exe
echo   Tools directory: %TOOLS_DIR%
echo   Downloads will be saved to: %DOWNLOADS_DIR%
echo   Chrome config: %MANIFEST_FILE%
echo.
echo Next steps:
echo   1. Load the extension from: %SCRIPT_DIR%..\plugin
echo   2. Copy the extension ID from chrome://extensions/
echo   3. If the ID is different from %EXTENSION_ID%,
echo      run this script again with the correct ID
echo.
echo Happy downloading!
echo.
pause
