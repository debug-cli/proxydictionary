@echo off
setlocal EnableDelayedExpansion

:: Self-repair line endings if the file was downloaded via curl/iwr (GitHub raw uses LF)
for /f "delims=" %%a in ('powershell -NoProfile -Command "if ((Get-Content '%~f0' -Raw) -notmatch '\r\n') { (Get-Content '%~f0' -Raw) -replace \"`n\",\"`r`n\" | Set-Content '%~f0' -Encoding ASCII; echo fixed } else { echo ok }"') do (
  if "%%a"=="fixed" (
    cmd /c "%~f0"
    exit /b
  )
)

:: proxydictionary Windows bootstrap installer
:: Flashy but 100% compatible with stock blue Windows PowerShell + CMD
:: Asks drive letter, ensures git, clones so you can git pull later.

title proxydictionary Installer

:: Header - split into multiple calls for robustness (LF vs CRLF from downloads)
powershell -NoProfile -Command "Write-Host ''; Write-Host ('='*60) -ForegroundColor Cyan"
powershell -NoProfile -Command "Write-Host '  PROXYDICTIONARY  -  PROXY DICTIONARY  BOOTSTRAP' -ForegroundColor White -BackgroundColor DarkBlue"
powershell -NoProfile -Command "Write-Host ('='*60) -ForegroundColor Cyan; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  Monolithic client-side proxy index (5k+ mirrors)' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '  Zero deps | localStorage favs | one-click copy | git-updatable' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host ''; Write-Host '  This .bat will:' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    - Prompt for a drive letter (C, D, E...)' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    - Auto-install git via winget if missing' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    - Clone to DRIVE:\proxydictionary' -ForegroundColor Yellow; Write-Host ''"
powershell -NoProfile -Command "Write-Host ('-'*60) -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host '  IMPORTANT NOTE ABOUT THIS SCRIPT' -ForegroundColor Red -BackgroundColor Black"
powershell -NoProfile -Command "Write-Host '  Running a downloaded batch file might look suspicious to you or your antivirus software.' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '  This project is completely open source. You can review every line of the code.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '  1. Copy the URL you used to fetch install.bat' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '  2. Go to https://www.virustotal.com and scan it' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '  3. Read the script in the repository before running it' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host ('-'*60) -ForegroundColor DarkGray; Write-Host ''"

echo.
set /p _ans="Continue with installation? (Y/N): "
if /I "%_ans%"=="Y" goto :continue_install
powershell -NoProfile -Command "Write-Host 'Aborted.' -ForegroundColor Red"
goto :eof

:continue_install

:: Drive letter prompt with validation + examples
:DRIVE_PROMPT
powershell -NoProfile -Command "Write-Host ''"
powershell -NoProfile -Command "Write-Host '>>> STEP 1: Choose installation drive' -ForegroundColor Cyan -BackgroundColor Black"
powershell -NoProfile -Command "Write-Host '    Type ONLY the letter and press ENTER' -ForegroundColor Gray"
powershell -NoProfile -Command "Write-Host ''"
powershell -NoProfile -Command "Write-Host '    EXAMPLES:' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '      D     to use D:\proxydictionary' -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host '      C     to use C:\proxydictionary (works too)' -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host '      E     to use E:\proxydictionary' -ForegroundColor DarkGray"
powershell -NoProfile -Command "Write-Host ''"

set /p "DRIVE=Drive letter [A-Z]: "
set DRIVE=%DRIVE:~0,1%

if not defined DRIVE goto :invalid_drive
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  if /I "%DRIVE%"=="%%L" goto :valid_drive
)

:invalid_drive
powershell -NoProfile -Command "Write-Host 'Invalid drive letter. Must be A-Z.' -ForegroundColor Red"
goto DRIVE_PROMPT

:valid_drive

set "TARGET=%DRIVE%:\proxydictionary"

powershell -NoProfile -Command "Write-Host ''; Write-Host \"Target folder: %TARGET%\" -ForegroundColor White -BackgroundColor DarkGreen; Write-Host ''"

if exist "%TARGET%\.git" (
  powershell -NoProfile -Command "Write-Host 'Existing git repo detected. Will UPDATE instead of full clone.' -ForegroundColor Yellow"
  set "MODE=update"
) else if exist "%TARGET%" (
  powershell -NoProfile -Command "Write-Host 'Folder exists but is not a git repo. Will remove and fresh clone.' -ForegroundColor Yellow"
  set "MODE=clone"
) else (
  set "MODE=clone"
)

:: Ensure git
where git >nul 2>&1
if %errorlevel% neq 0 (
  powershell -NoProfile -Command "Write-Host 'git not found on PATH. Trying winget...' -ForegroundColor Yellow"
  winget --version >nul 2>&1 || (
    powershell -NoProfile -Command "Write-Host 'No winget. Install Git manually from https://git-scm.com then re-run this.' -ForegroundColor Red; exit 1"
  )
  echo Running winget install for Git...
  winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements --silent
  set "PATH=%PATH%;C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
  where git >nul 2>&1 || (
    powershell -NoProfile -Command "Write-Host 'Git install appeared to succeed but not in PATH yet. Restart this terminal and run installer again.' -ForegroundColor Red; exit 1"
  )
  powershell -NoProfile -Command "Write-Host 'Git is now available.' -ForegroundColor Green"
)

powershell -NoProfile -Command "Write-Host ('git version: ' + (git --version)) -ForegroundColor Green"

:: Perform clone or pull
powershell -NoProfile -Command "Write-Host ''; Write-Host '>>> STEP 2: Acquiring latest dictionary...' -ForegroundColor Cyan"

if "%MODE%"=="update" (
  pushd "%TARGET%"
  git pull --ff-only
  if errorlevel 1 (
    powershell -NoProfile -Command "Write-Host 'Pull failed.' -ForegroundColor Red"
    popd
    goto :fail
  )
  popd
  set "ACTION=UPDATED via git pull"
) else (
  if exist "%TARGET%" rd /s /q "%TARGET%" >nul 2>&1
  git clone --depth 1 https://github.com/debug-cli/proxydictionary.git "%TARGET%"
  if errorlevel 1 goto :fail
  set "ACTION=CLONED"
)

:: Big success banner + reminder (split for download robustness)
powershell -NoProfile -Command "Write-Host ''; Write-Host ('='*60) -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '   SUCCESS! proxydictionary %ACTION%' -ForegroundColor Black -BackgroundColor Green"
powershell -NoProfile -Command "Write-Host ('='*60) -ForegroundColor Green; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  Installed to: %TARGET%' -ForegroundColor White; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  TO OPEN:' -ForegroundColor Cyan"
powershell -NoProfile -Command "Write-Host '    Open File Explorer to navigate to the folder above' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    Double click:  index.html' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    (proxydictionary.html also works)' -ForegroundColor DarkGray; Write-Host ''"
powershell -NoProfile -Command "Write-Host ('-'*60) -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '  *** UPDATE REMINDER (do this often) ***' -ForegroundColor Yellow -BackgroundColor DarkRed"
powershell -NoProfile -Command "Write-Host '  Open PowerShell or CMD and run:' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host ''; Write-Host '    cd %TARGET%' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    git pull' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    (then reload the .html page - Ctrl + Shift + R)' -ForegroundColor White; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  This pulls the newest proxy mirrors into your local copy.' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host ('-'*60) -ForegroundColor Yellow; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  Live version (always fresh): https://proxydict.vercel.app' -ForegroundColor Magenta"
powershell -NoProfile -Command "Write-Host ''; Write-Host 'All done. Enjoy the dictionary.' -ForegroundColor Green; Write-Host ''"

goto :end

:fail
powershell -NoProfile -Command "Write-Host 'Something went wrong. See messages above.' -ForegroundColor Red"

:end
powershell -NoProfile -Command "Write-Host ''; Write-Host 'Press any key to exit...' -ForegroundColor DarkGray"
pause >nul
exit /b 0
