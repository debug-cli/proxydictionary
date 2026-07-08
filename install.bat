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
:: Selects drive with arrow keys (no manual typing), ensures git, clones so you can git pull later.

title proxydictionary Installer

:: Header - split into multiple calls for robustness (LF vs CRLF from downloads)
powershell -NoProfile -Command "Write-Host ''; Write-Host ('='*60) -ForegroundColor Cyan"
powershell -NoProfile -Command "Write-Host '  PROXYDICTIONARY  -  PROXY DICTIONARY  BOOTSTRAP' -ForegroundColor White -BackgroundColor DarkBlue"
powershell -NoProfile -Command "Write-Host ('='*60) -ForegroundColor Cyan; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  Monolithic client-side proxy index (5k+ mirrors)' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '  Zero deps | localStorage favs | one-click copy | git-updatable' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host ''; Write-Host '  This .bat will:' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    - Show a simple numbered menu to select any drive (mainly for USBs)' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    - Auto-install git via winget if missing' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    - Clone the files into a new proxydictionary folder on the chosen drive' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host ''; Write-Host '  IMPORTANT:' -ForegroundColor Cyan"
powershell -NoProfile -Command "Write-Host '    This is mainly recommended for USB drives so you can carry' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    the Proxy Dictionary with you on a portable USB stick.' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    This will NOT wipe, delete, or change ANY existing files or data' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '    on the drive. It ONLY creates a new folder called proxydictionary.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host ''; Write-Host '    If you are NOT putting this on a USB, it is often easier to' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    just use the live website: https://proxydict.vercel.app' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '    or manually run git commands in any folder on your computer.' -ForegroundColor Yellow; Write-Host ''"
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

:: Drive selection using arrow-key menu (no manual letter typing)
:: Lists system drive first, then plugged-in drives
powershell -NoProfile -Command "Write-Host ''"
powershell -NoProfile -Command "Write-Host '>>> STEP 1: Select drive for proxydictionary' -ForegroundColor Cyan -BackgroundColor Black"
powershell -NoProfile -Command "Write-Host '    Enter the number and press Enter. Mainly for USBs.' -ForegroundColor Gray"
powershell -NoProfile -Command "Write-Host '    SAFETY: This will NOT wipe or delete ANY existing data or files.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host ''"

for /f "delims=" %%D in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "
$sys = $env:SystemDrive
$list = @()
$list += [pscustomobject]@{Letter=$sys.TrimEnd(':'); Display=\"$sys (Windows is installed here)\"}

$rem = Get-WmiObject Win32_LogicalDisk -Filter \"DriveType=2\" | Sort-Object DeviceID
foreach ($r in $rem) {
    $free = if ($r.Size) { [math]::Round($r.FreeSpace/1GB,1) } else { \"?\" }
    $vol = if ($r.VolumeName) { \" - $($r.VolumeName)\" } else { \"\" }
    $list += [pscustomobject]@{Letter=$r.DeviceID.TrimEnd(':'); Display=\"$($r.DeviceID)$vol (USB/Removable, $free GB free)\"}
}

$fixed = Get-WmiObject Win32_LogicalDisk -Filter \"DriveType=3 AND DeviceID != '$sys'\" | Sort-Object DeviceID
foreach ($f in $fixed) {
    $free = if ($f.Size) { [math]::Round($f.FreeSpace/1GB,1) } else { \"?\" }
    $vol = if ($f.VolumeName) { \" - $($f.VolumeName)\" } else { \"\" }
    $list += [pscustomobject]@{Letter=$f.DeviceID.TrimEnd(':'); Display=\"$($f.DeviceID)$vol (Fixed, $free GB free)\"}
}

if ($list.Count -eq 0) { Write-Error \"No drives found\"; exit 1 }

Write-Host \"Available drives:\"
for ($i=0; $i -lt $list.Count; $i++) {
    Write-Host \"  $($i+1)) $($list[$i].Display)\"
}
Write-Host \"\"
$sel = Read-Host \"Enter number\"
$num = [int]$sel
if ($num -lt 1 -or $num -gt $list.Count) { Write-Error \"Invalid selection\"; exit 1 }
Write-Output $list[$num-1].Letter
" ') do (
    set "DRIVE=%%D"
)

if not defined DRIVE (
    powershell -NoProfile -Command "Write-Host 'No drive selected.' -ForegroundColor Red"
    goto :eof
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

:: Big success banner + reminder (split for download robustness)
powershell -NoProfile -Command "Write-Host ''; Write-Host ('='*60) -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host '   SUCCESS! proxydictionary %ACTION%' -ForegroundColor Black -BackgroundColor Green"
powershell -NoProfile -Command "Write-Host ('='*60) -ForegroundColor Green; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  Installed to: %TARGET%' -ForegroundColor White; Write-Host ''"
powershell -NoProfile -Command "Write-Host '  This was placed on your chosen drive (great for USB sticks!).' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '  SAFETY NOTE: No files were deleted or wiped. Only a new folder was added.' -ForegroundColor Green"
powershell -NoProfile -Command "Write-Host ''"
powershell -NoProfile -Command "Write-Host '  TO OPEN:' -ForegroundColor Cyan"
powershell -NoProfile -Command "Write-Host '    Open File Explorer to navigate to the folder above' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    Double click:  index.html' -ForegroundColor White"
powershell -NoProfile -Command "Write-Host '    (proxydictionary.html also works)' -ForegroundColor DarkGray; Write-Host ''"
powershell -NoProfile -Command "Write-Host ''"
powershell -NoProfile -Command "Write-Host '  If this is NOT on a USB, you can just use the website instead:' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host '  https://proxydict.vercel.app' -ForegroundColor Magenta"
powershell -NoProfile -Command "Write-Host '  (Or run git commands directly in any folder - no installer needed.)' -ForegroundColor Yellow"
powershell -NoProfile -Command "Write-Host ''"
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
