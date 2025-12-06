@echo off

SET HOST_NAME=com.videodl.host
SET INSTALL_PATH=%USERPROFILE%\videodl\native_host.exe

echo Installing native host...

REM Create folder
mkdir "%USERPROFILE%\videodl"
copy native_host.exe "%INSTALL_PATH%"
copy json.hpp "%USERPROFILE%\videodl\json.hpp"

REM Build host manifest
set MANIFEST_PATH=%USERPROFILE%\videodl\%HOST_NAME%.json
copy com.videodl.host.template.json "%MANIFEST_PATH%"

powershell -Command "(Get-Content '%MANIFEST_PATH%').Replace('__HOST_PATH__','%INSTALL_PATH%') | Set-Content '%MANIFEST_PATH%'"
powershell -Command "(Get-Content '%MANIFEST_PATH%').Replace('__EXTENSION_ID__','%1') | Set-Content '%MANIFEST_PATH%'"

echo Writing registry...

REG ADD "HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\%HOST_NAME%" /ve /t REG_SZ /d "%MANIFEST_PATH%" /f

echo Done!
pause

