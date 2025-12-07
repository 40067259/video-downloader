Video Downloader - Windows Installation Instructions
=====================================================

IMPORTANT: Antivirus Warning
-----------------------------
Your antivirus software may flag or delete native_host.exe as a false positive.
This is a common issue with executable files from unknown sources.

Before Installing:
------------------
1. First, run check-files.bat to verify all files are present
2. If native_host.exe is missing, check your antivirus quarantine
3. Add the extracted folder to your antivirus exclusion list

Installation Steps:
-------------------
1. Extract ALL files from the ZIP
2. Run check-files.bat to verify files (IMPORTANT!)
3. Right-click install.bat -> "Run as Administrator"
4. Follow the on-screen instructions

Troubleshooting:
----------------
Problem: "native_host.exe not found" or compilation errors
Solution:
  - Check Windows Defender quarantine
  - Temporarily disable antivirus
  - Re-extract the ZIP file
  - Add folder to Windows Defender exclusions:
    Settings -> Virus & threat protection ->
    Manage settings -> Exclusions -> Add an exclusion

Problem: "Failed to copy native_host.exe"
Solution:
  - Run as Administrator
  - Close all Chrome windows
  - Disable antivirus temporarily

For more help, visit:
https://github.com/40067259/video-downloader/issues
