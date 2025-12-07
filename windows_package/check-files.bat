@echo off
echo ==========================================
echo File Diagnostic Tool
echo ==========================================
echo.

set "SCRIPT_DIR=%~dp0"
echo Current directory: %CD%
echo Script directory: %SCRIPT_DIR%
echo.

echo Checking for required files...
echo.

if exist "%SCRIPT_DIR%native_host.exe" (
    echo [OK] native_host.exe found
    dir "%SCRIPT_DIR%native_host.exe" | findstr "native_host.exe"
) else (
    echo [MISSING] native_host.exe NOT FOUND!
    echo This file may have been deleted by antivirus software
)

if exist "%SCRIPT_DIR%install.bat" (
    echo [OK] install.bat found
) else (
    echo [MISSING] install.bat NOT FOUND!
)

if exist "%SCRIPT_DIR%native_host.cpp" (
    echo [OK] native_host.cpp found
) else (
    echo [MISSING] native_host.cpp NOT FOUND!
)

if exist "%SCRIPT_DIR%json.hpp" (
    echo [OK] json.hpp found
) else (
    echo [MISSING] json.hpp NOT FOUND!
)

echo.
echo All files in this directory:
echo.
dir /b "%SCRIPT_DIR%"

echo.
echo ==========================================
echo If native_host.exe is MISSING:
echo   1. Check your antivirus quarantine
echo   2. Temporarily disable antivirus
echo   3. Re-extract the ZIP file
echo ==========================================
echo.
pause
