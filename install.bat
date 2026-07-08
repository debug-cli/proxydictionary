@echo off
setlocal enabledelayedexpansion

:: =====================================================
::  proxydictionairy - One-Run Installer (Windows)
::  Drops the Proxy Dictionary to your chosen drive
::  via git so you can git pull for fresh mirrors later.
:: =====================================================

powershell -NoProfile -Command ^
    "Write-Host '';^
     Write-Host '===========================================================' -ForegroundColor Cyan;^
     Write-Host '   PROXYDICTIONAIRY  |  PROXY DICTIONARY DEPLOYMENT       ' -ForegroundColor White -BackgroundColor DarkBlue;^
     Write-Host '===========================================================' -ForegroundColor Cyan;^
     Write-Host '';^
     Write-Host '  Zero-dependency monolithic recon payload' -ForegroundColor Green;^
     Write-Host '  4100+ verified proxy mirrors • client-side only' -ForegroundColor Green;^
     Write-Host '  Updates via git pull • works in air-gapped browsers' -ForegroundColor Green;^
     Write-Host '';^
     Write-Host '  This script will:' -ForegroundColor Yellow;^
     Write-Host '    1. Ask which DRIVE (C D E ...) to place the folder on' -ForegroundColor Yellow;^
     Write-Host '    2. Check / install git if missing (winget)' -ForegroundColor Yellow;^
     Write-Host '    3. git clone the dictionary to DRIVE:\proxydictionairy' -ForegroundColor Yellow;^
     Write-Host '';^
     Write-Host '-----------------------------------------------------------' -ForegroundColor DarkGray;^
     Write-Host '  DISCLAIMER (READ THIS)' -ForegroundColor Red -BackgroundColor Black;^
     Write-Host '  The command you used to get this .bat (curl / iwr | iex style)' -ForegroundColor Yellow;^
     Write-Host '  can look shady to antivirus and security tools.' -ForegroundColor Yellow;^
     Write-Host '  THIS IS AN OPEN SOURCE PROJECT.' -ForegroundColor Green;^
     Write-Host '  You can (and should) paste the raw URL of install.bat into' -ForegroundColor Yellow;^
     Write-Host '  VirusTotal.com to verify before running.' -ForegroundColor Yellow;^
     Write-Host '  Nothing is hidden. Full source is in the public repo.' -ForegroundColor Yellow;^
     Write-Host '-----------------------------------------------------------' -ForegroundColor DarkGray;^
     Write-Host ''"

echo.
echo Press ANY key to continue (or Ctrl+C to abort)...
pause >nul

:: --- Ask for drive letter -------------------------------------------------
:ASK_DRIVE
powershell -NoProfile -Command "Write-Host '>>> Which drive letter should we install to?' -ForegroundColor Cyan; Write-Host '    Example: type D and press Enter   (recommended if you have D:)' -ForegroundColor DarkGray; Write-Host '    Common choices: C   D   E   F' -ForegroundColor DarkGray"
set /p DRIVELETTER="Drive letter (single letter, no colon): "

:: Sanitize
set DRIVELETTER=%DRIVELETTER:~0,1%
set DRIVELETTER=%DRIVELETTER:~0,1%

if "%DRIVELETTER%"=="" goto ASK_DRIVE

:: Uppercase
for %%A in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") do (
    set DRIVELETTER=!DRIVELETTER:%%~A!
)

echo %DRIVELETTER% | findstr /R "^[A-Z]$" >nul
if errorlevel 1 (
    powershell -NoProfile -Command "Write-Host 'ERROR: Must be a single letter A-Z' -ForegroundColor Red"
    goto ASK_DRIVE
)

set TARGET=%DRIVELETTER%:\proxydictionairy

powershell -NoProfile -Command "Write-Host ''; Write-Host 'Target location: %TARGET%' -ForegroundColor White -BackgroundColor DarkGreen; Write-Host ''"

if exist "%TARGET%" (
    powershell -NoProfile -Command "Write-Host 'WARNING: %TARGET% already exists.' -ForegroundColor Yellow"
    choice /C YN /M "Do you want to UPDATE it in place (git pull) instead of fresh clone? (Y/N)"
    if errorlevel 2 (
        powershell -NoProfile -Command "Write-Host 'Aborted by user.' -ForegroundColor Red"
        goto END
    )
    set DO_UPDATE=1
) else (
    set DO_UPDATE=0
)

:: --- Git check / install --------------------------------------------------
where git >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -Command "Write-Host 'git not found. Attempting install via winget...' -ForegroundColor Yellow"
    winget --version >nul 2>&1
    if %errorlevel% neq 0 (
        powershell -NoProfile -Command "Write-Host 'winget not available. Please install Git manually:' -ForegroundColor Red; Write-Host 'https://git-scm.com/download/win' -ForegroundColor Cyan"
        goto END
    )
    echo Installing Git for Windows (this may take a minute and may require admin rights)...
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    if %errorlevel% neq 0 (
        powershell -NoProfile -Command "Write-Host 'Git install failed. Try running this script from an Administrator PowerShell window.' -ForegroundColor Red"
        goto END
    )
    :: refresh path
    set "PATH=%PATH%;C:\Program Files\Git\bin;C:\Program Files\Git\cmd"
    where git >nul 2>&1
    if %errorlevel% neq 0 (
        powershell -NoProfile -Command "Write-Host 'Git still not in PATH. Close and reopen your terminal, then run the installer again.' -ForegroundColor Red"
        goto END
    )
    powershell -NoProfile -Command "Write-Host 'git installed successfully.' -ForegroundColor Green"
) else (
    powershell -NoProfile -Command "Write-Host 'git found: ' -NoNewline -ForegroundColor Green; git --version"
)

:: --- Clone or Update ------------------------------------------------------
powershell -NoProfile -Command "Write-Host ''; Write-Host '>>> Preparing proxydictionairy...' -ForegroundColor Cyan"

if "%DO_UPDATE%"=="1" (
    pushd "%TARGET%"
    git pull
    if %errorlevel% neq 0 (
        powershell -NoProfile -Command "Write-Host 'git pull failed. Check your internet or folder permissions.' -ForegroundColor Red"
        popd
        goto END
    )
    popd
    set SUCCESS_MSG=UPDATED in place
) else (
    if exist "%TARGET%" rmdir /s /q "%TARGET%" >nul 2>&1
    git clone https://github.com/debug-cli/proxydictionairy.git "%TARGET%"
    if %errorlevel% neq 0 (
        powershell -NoProfile -Command "Write-Host 'Clone failed. Check internet connection and that the repo is public.' -ForegroundColor Red"
        goto END
    )
    set SUCCESS_MSG=CLONED
)

:: --- Success dazzle --------------------------------------------------------
powershell -NoProfile -Command ^
    "Write-Host '';^
     Write-Host '===========================================================' -ForegroundColor Green;^
     Write-Host '   SUCCESS - proxydictionairy %SUCCESS_MSG%                 ' -ForegroundColor Black -BackgroundColor Green;^
     Write-Host '===========================================================' -ForegroundColor Green;^
     Write-Host '';^
     Write-Host 'Location: %TARGET%' -ForegroundColor White;^
     Write-Host '';^
     Write-Host 'HOW TO OPEN THE DICTIONARY:' -ForegroundColor Cyan;^
     Write-Host '  1. Open File Explorer' -ForegroundColor White;^
     Write-Host '  2. Go to %TARGET%' -ForegroundColor White;^
     Write-Host '  3. Double-click index.html   (or proxydictionary.html)' -ForegroundColor White;^
     Write-Host '';^
     Write-Host '-----------------------------------------------------------' -ForegroundColor DarkGray;^
     Write-Host '  IMPORTANT - KEEP IT FRESH (git pull)' -ForegroundColor Yellow -BackgroundColor Black;^
     Write-Host '  The list of proxies changes. To get the latest mirrors:' -ForegroundColor Yellow;^
     Write-Host '';^
     Write-Host '    cd %TARGET%' -ForegroundColor White;^
     Write-Host '    git pull' -ForegroundColor White;^
     Write-Host '    (then hard-refresh the html page with Ctrl+F5)' -ForegroundColor White;^
     Write-Host '';^
     Write-Host '  Run the above any time you want updated endpoints.' -ForegroundColor Yellow;^
     Write-Host '-----------------------------------------------------------' -ForegroundColor DarkGray;^
     Write-Host '';^
     Write-Host 'You can also visit the live hosted version at:' -ForegroundColor Cyan;^
     Write-Host 'https://proxydict.vercel.app' -ForegroundColor Magenta;^
     Write-Host '';^
     Write-Host 'Thank you. Now go break some filters (responsibly).' -ForegroundColor Green;^
     Write-Host ''"

:END
powershell -NoProfile -Command "Write-Host 'Press any key to close this window...' -ForegroundColor DarkGray"
pause >nul
exit /b 0
