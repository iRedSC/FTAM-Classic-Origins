@echo off
setlocal
rem The one file a new player needs: put it on the desktop and double-click it to play.
rem The first run installs Git if needed and downloads the pack; every run updates the pack and starts the game.
rem It plays the branch below, whatever the downloaded checkout is on. "FTAM Classic Origins (dev).cmd" is the same
rem file for dev; keep the two identical apart from this line and the comment above it.
set "FTAM_BRANCH=main"

if not defined FTAM_REPO set "FTAM_REPO=%USERPROFILE%\FTAM-Classic-Origins"
set "PATH=%ProgramFiles%\Git\cmd;%PATH%"
rem This file is the shortcut, so play.cmd doesn't add another to the desktop.
set "FTAM_NO_SHORTCUT=1"

if exist "%FTAM_REPO%\play.cmd" (
    rem Only the launcher scripts run from this checkout; the pack itself comes from its .channels folder.
    git -C "%FTAM_REPO%" pull -q --ff-only
    goto play
)

where git >nul 2>nul
if errorlevel 1 (
    echo Installing Git...
    winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
    where git >nul 2>nul
    if errorlevel 1 (
        echo Couldn't install Git. Install it from https://git-scm.com/download/win, then run this again.
        pause
        exit /b 1
    )
)
echo Downloading the pack to %FTAM_REPO%...
git clone https://github.com/iRedSC/FTAM-Classic-Origins.git "%FTAM_REPO%"
if errorlevel 1 (
    echo Couldn't download the pack. Check your connection, then run this again.
    pause
    exit /b 1
)

:play
call "%FTAM_REPO%\play.cmd" -Branch %FTAM_BRANCH% %*
