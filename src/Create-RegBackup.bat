@echo off
setlocal
title Create Registry Backup
color B

rem Prompt for backup path with default
set "defaultBackupPath=%USERPROFILE%\Documents\REG-Backups"
echo                              == Registry Backup Creator ==



set /p "backupPath=Enter path for backup, or hit enter (default: %defaultBackupPath%): "

if "%backupPath%"=="" set "backupPath=%defaultBackupPath%"
echo.
echo.
echo.
echo.
echo.
echo.
rem Now use %backupPath% in your script as needed
echo Creating registry backup at "%backupPath%"...

rem Create backup folder if it doesn't exist
if not exist "%backupPath%" (
    mkdir "%backupPath%"
)

rem Get current time components
for /f "tokens=1-4 delims=/:. " %%a in ("%time%") do (
    set hour=%%a
    set min=%%b
    set sec=%%c
    set ms=%%d
)

rem Get current date components
for /f "tokens=1-4 delims=, " %%a in ('date /t') do (
    set day=%%a
    set mmddyy=%%b
)

rem Extract month, day, year from mmddyy (assuming MM/DD/YYYY)
for /f "tokens=1-3 delims=/" %%x in ("%mmddyy%") do (
    set mm=%%x
    set dd=%%y
    set yyyy=%%z
)

rem Format hour to 12-hour and get am/pm
set /a h12=hour
if %h12% gtr 12 (
    set /a h12-=12
    set ampm=pm
) else (
    if %h12%==0 (
        set h12=12
        set ampm=am
    ) else (
        set ampm=am
    )
)

rem Remove leading zero from hour
if "%h12:~0,1%"=="0" set h12=%h12:~1%

rem Fix am/pm casing
set ampm=%ampm:~0,2%

rem Format filename: Day_MMDDYY_HHMMam.reg (with underscores, no spaces)
set filename=%day%_%mm%%dd%%yyyy:~2,2%_%h12%%min%%ampm%.reg

rem Check if file with this timestamp already exists
if exist "%backupPath%\%filename%" (
    echo Backup file "%filename%" already exists for this minute.
    echo No new backup created.
    call :WaitForKeyOrTimeout
    exit /b
)

rem Export HKLM and HKCU to temporary files
reg export HKLM "%backupPath%\temp_HKLM.reg" /y >nul
reg export HKCU "%backupPath%\temp_HKCU.reg" /y >nul

rem Combine both files into one
(
    type "%backupPath%\temp_HKLM.reg"

    type "%backupPath%\temp_HKCU.reg"
) > "%backupPath%\%filename%"

rem Delete temp files
del "%backupPath%\temp_HKLM.reg"
del "%backupPath%\temp_HKCU.reg"
echo.

echo Registry backup completed: %filename%

:WaitForKeyOrTimeout

echo.
echo Press any key to exit or wait %timeout% seconds...
echo.

timeout /t 10
exit /b