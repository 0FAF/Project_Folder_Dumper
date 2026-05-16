@echo off
setlocal EnableDelayedExpansion

if "%~1"=="" (
    echo Usage: %~nx0 ^<folder^> [exclude...]
    exit /b 1
)

set "TARGET=%~f1"

if "%TARGET:~-1%"=="\" set "TARGET=%TARGET:~0,-1%"

shift

set "OUTPUT=project_dump.txt"
set "FILELIST=%TEMP%\filelist.txt"

del "%FILELIST%" 2>nul

REM ============================================
REM Normalize excludes
REM ============================================

set EXCLUDES=

:collect_excludes
if "%~1"=="" goto done_excludes

set "EX=%~1"

set "EX=!EX:/=\!"

if /i "!EX:~0,2!"==".\" set "EX=!EX:~2!"
if "!EX:~0,1!"=="\" set "EX=!EX:~1!"
if "!EX:~-1!"=="\" set "EX=!EX:~0,-1!"

set EXCLUDES=!EXCLUDES! "!EX!"

shift
goto collect_excludes

:done_excludes

REM ============================================
REM Build valid file list
REM ============================================

call :scanDir "%TARGET%"

REM ============================================
REM Write structure
REM ============================================

echo. > "%OUTPUT%"

echo Project structure for: %TARGET%>> "%OUTPUT%"
echo.>> "%OUTPUT%"
echo --- >> "%OUTPUT%"
echo # FOLDER STRUCTURE>> "%OUTPUT%"
echo.>> "%OUTPUT%"

for /f "usebackq delims=" %%F in ("%FILELIST%") do (

    set "REL=%%F"
    set "REL=!REL:%TARGET%\=!"

    echo !REL!>> "%OUTPUT%"
)

echo.>> "%OUTPUT%"
echo --- >> "%OUTPUT%"
echo # FILE CONTENTS>> "%OUTPUT%"
echo.>> "%OUTPUT%"

REM ============================================
REM Write file contents
REM ============================================

for /f "usebackq delims=" %%F in ("%FILELIST%") do (

    set "REL=%%F"
    set "REL=!REL:%TARGET%\=!"

    echo ```!REL!>> "%OUTPUT%"

    type "%%F" >> "%OUTPUT%" 2>nul

    if errorlevel 1 (
        echo [BINARY OR UNREADABLE FILE]>> "%OUTPUT%"
    )

    echo ```>> "%OUTPUT%"
    echo.>> "%OUTPUT%"
)

del "%FILELIST%" 2>nul

echo Output written to %OUTPUT%
exit /b

REM ============================================
REM Recursive directory scanner
REM ============================================

:scanDir

set "CURDIR=%~f1"

REM ----------------------------
REM Scan files
REM ----------------------------

for %%F in ("%CURDIR%\*") do (

    if exist "%%F" (

        set "NAME=%%~nxF"
        set "SKIP="

        for %%E in (!EXCLUDES!) do (

            if /i "%%~nxF"=="%%~E" set "SKIP=1"

            echo "%%~fF" | findstr /i /r /c:"\\%%~E\\.*" >nul && set "SKIP=1"
        )

        if not defined SKIP (
            echo %%~fF>> "%FILELIST%"
        )
    )
)

REM ----------------------------
REM Recurse subdirectories
REM ----------------------------

for /d %%D in ("%CURDIR%\*") do (

    set "SKIP="

    for %%E in (!EXCLUDES!) do (
        if /i "%%~nxD"=="%%~E" set "SKIP=1"
    )

    if not defined SKIP (
        call :scanDir "%%~fD"
    )
)

exit /b