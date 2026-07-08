@echo off
setlocal EnableDelayedExpansion

:: proxydictionary Windows bootstrap installer
:: Flashy but 100% compatible with stock blue Windows PowerShell + CMD
:: Asks drive letter, ensures git, clones so you can git pull later.

title proxydictionary Installer

powershell -NoProfile -Command ^
"$esc = [char]27; ^
Write-Host ''; ^
Write-Host ('='*60) -ForegroundColor Cyan; ^
Write-Host '  PROXYDICTIONARY  -  PROXY DICTIONARY  BOOTSTRAP' -ForegroundColor White -BackgroundColor DarkBlue; ^
Write-Host ('='*60) -ForegroundColor Cyan; ^
Write-Host ''; ^
Write-Host '  Monolithic client-side proxy index (5k+ mirrors)' -ForegroundColor Green; ^
Write-Host '  Zero deps | localStorage favs | one-click copy | git-updatable' -ForegroundColor Green; ^
Write-Host ''; ^
Write-Host '  This .bat will:' -ForegroundColor Yellow; ^
Write-Host '    - Prompt for a drive letter (C, D, E...)' -ForegroundColor Yellow; ^
Write-Host '    - Auto-install git via winget if missing' -ForegroundColor Yellow; ^
Write-Host '    - Clone to DRIVE:\proxydictionary' -ForegroundColor Yellow; ^
Write-Host ''; ^
Write-Host ('-'*60) -ForegroundColor DarkGray; ^
Write-Host '  SHADY-LOOKING COMMAND DISCLAIMER' -ForegroundColor Red -BackgroundColor Black; ^
Write-Host '  Running a downloaded .bat via curl/iwr can trigger AV.' -ForegroundColor Yellow; ^
Write-Host '  THIS PROJECT IS FULLY OPEN SOURCE AND AUDITABLE.' -ForegroundColor Green; ^
Write-Host '  1. Copy the URL you used to fetch install.bat' -ForegroundColor Yellow; ^
Write-Host '  2. Go to https://www.virustotal.com and scan it' -ForegroundColor Yellow; ^
Write-Host '  3. Read the source in the repo before trusting' -ForegroundColor Yellow; ^
Write-Host ('-'*60) -ForegroundColor DarkGray; ^
Write-Host ''"

echo.
choice /C YN /M "Continue with installation? (Y=Yes, N=Abort)"
if errorlevel 2 (
  powershell -NoProfile -Command "Write-Host 'Aborted.' -ForegroundColor Red"
  goto :eof
)

:: Drive letter prompt with validation + examples
:DRIVE_PROMPT
powershell -NoProfile -Command ^
"Write-Host ''; ^
 Write-Host '>>> STEP 1: Choose installation drive' -ForegroundColor Cyan -BackgroundColor Black; ^
 Write-Host '    Type ONLY the letter and press ENTER' -ForegroundColor Gray; ^
 Write-Host ''; ^
 Write-Host '    EXAMPLES:' -ForegroundColor White; ^
 Write-Host '      D     -> will use D:\proxydictionary' -ForegroundColor DarkGray; ^
 Write-Host '      C     -> will use C:\proxydictionary (works too)' -ForegroundColor DarkGray; ^
 Write-Host '      E     -> E:\proxydictionary' -ForegroundColor DarkGray; ^
 Write-Host ''"

set /p "DRIVE=Drive letter [A-Z]: "
set DRIVE=%DRIVE:~0,1%
set DRIVE=%DRIVE:~0,1%

for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  if /I "%DRIVE%"=="%%L" set DRIVE=%%L
)

echo %DRIVE%| findstr /R "^[A-Z]$" >nul 2>&1 || (
  powershell -NoProfile -Command "Write-Host 'Invalid drive letter. Must be A-Z.' -ForegroundColor Red"
  goto DRIVE_PROMPT
)

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

:: Big success banner + reminder (colored, PS compatible)
powershell -NoProfile -Command ^
"Write-Host ''; ^
Write-Host ('='*60) -ForegroundColor Green; ^
Write-Host '   SUCCESS! proxydictionary %ACTION%' -ForegroundColor Black -BackgroundColor Green; ^
Write-Host ('='*60) -ForegroundColor Green; ^
Write-Host ''; ^
Write-Host '  Installed to: %TARGET%' -ForegroundColor White; ^
Write-Host ''; ^
Write-Host '  TO OPEN:' -ForegroundColor Cyan; ^
Write-Host '    Open File Explorer -> navigate to the folder above' -ForegroundColor White; ^
Write-Host '    Double click:  index.html' -ForegroundColor White; ^
Write-Host '    (proxydictionary.html also works)' -ForegroundColor DarkGray; ^
Write-Host ''; ^
Write-Host ('-'*60) -ForegroundColor Yellow; ^
Write-Host '  *** UPDATE REMINDER (do this often) ***' -ForegroundColor Yellow -BackgroundColor DarkRed; ^
Write-Host '  Open PowerShell or CMD and run:' -ForegroundColor Yellow; ^
Write-Host ''; ^
Write-Host '    cd %TARGET%' -ForegroundColor White; ^
Write-Host '    git pull' -ForegroundColor White; ^
Write-Host '    (then reload the .html page - Ctrl + Shift + R)' -ForegroundColor White; ^
Write-Host ''; ^
Write-Host '  This pulls the newest proxy mirrors into your local copy.' -ForegroundColor Yellow; ^
Write-Host ('-'*60) -ForegroundColor Yellow; ^
Write-Host ''; ^
Write-Host '  Live version (always fresh): https://proxydict.vercel.app' -ForegroundColor Magenta; ^
Write-Host ''; ^
Write-Host 'All done. Enjoy the dictionary.' -ForegroundColor Green; ^
Write-Host ''"

goto :end

:fail
powershell -NoProfile -Command "Write-Host 'Something went wrong. See messages above.' -ForegroundColor Red"

:end
powershell -NoProfile -Command "Write-Host ''; Write-Host 'Press any key to exit...' -ForegroundColor DarkGray"
pause >nul
exit /b 0
