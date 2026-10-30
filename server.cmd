@echo off
rem Runs scripts/server.sh with the bash that ships with Git for Windows.
setlocal
for /f "delims=" %%P in ('git --exec-path 2^>nul') do set "GIT_EXEC=%%P"
if not defined GIT_EXEC (
    echo Git for Windows is required: https://git-scm.com/download/win
    pause
    exit /b 1
)
for %%B in ("%GIT_EXEC%/../../../bin/bash.exe") do set "GIT_BASH=%%~fB"
"%GIT_BASH%" "%~dp0scripts/server.sh" %*
if errorlevel 1 pause
