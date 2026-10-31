@echo off
rem The one file a new player needs: put it on the desktop and double-click it to play.
rem The first run installs Git if needed and downloads the pack; every run updates the pack and starts the game.
setlocal
if not defined FTAM_REPO set "FTAM_REPO=%USERPROFILE%\FTAM-Classic-Origins"
set "PATH=%ProgramFiles%\Git\cmd;%PATH%"
rem This file is the shortcut, so play.cmd doesn't add another to the desktop.
set "FTAM_NO_SHORTCUT=1"

if exist "%FTAM_REPO%\play.cmd" goto play

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
    echo Couldn't download the pack. Ask for access to github.com/iRedSC/FTAM-Classic-Origins, then run this again.
    pause
    exit /b 1
)

:play
call "%FTAM_REPO%\play.cmd" %*
