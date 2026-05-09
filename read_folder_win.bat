@echo off
setlocal enabledelayedexpansion

REM ============================================
REM Usage:
REM   read_folder_win.bat <folder> [exclude1] [exclude2] ...
REM ============================================

if "%~1"=="" (
    echo Usage: %~nx0 ^<folder^> [exclude1] [exclude2] ...
    exit /b 1
)

set "TARGET=%~f1"
shift

set "OUTPUT=project_dump.txt"

REM Store exclusions
set EXCLUDES=
:collect_excludes
if "%~1"=="" goto done_excludes
set EXCLUDES=!EXCLUDES! %~1
shift
goto collect_excludes

:done_excludes

REM Clear output file
echo. > "%OUTPUT%"

echo Project structure for: %TARGET%>> "%OUTPUT%"
echo.>> "%OUTPUT%"
echo ---  >> "%OUTPUT%"
echo # FOLDER STRUCTURE>> "%OUTPUT%"
echo >> "%OUTPUT%"
echo.>> "%OUTPUT%"

REM ============================================
REM TREE STRUCTURE
REM ============================================

for /f "delims=" %%D in ('dir "%TARGET%" /b /s /a') do (

    set "SKIP="

    for %%E in (!EXCLUDES!) do (
        echo %%D | findstr /i /c:"\%%E\" >nul && set "SKIP=1"
        echo %%D | findstr /i /c:"\%%E" >nul && set "SKIP=1"
    )

    if not defined SKIP (
        set "REL=%%D"
        set "REL=!REL:%TARGET%=!"
        if "!REL:~0,1!"=="\" set "REL=!REL:~1!"
        echo !REL!>> "%OUTPUT%"
    )
)

echo.>> "%OUTPUT%"
echo --->> "%OUTPUT%"
echo # FILE CONTENTS>> "%OUTPUT%"
echo.>> "%OUTPUT%"

REM ============================================
REM FILE CONTENTS
REM ============================================

for /r "%TARGET%" %%F in (*) do (

    set "SKIP="

    for %%E in (!EXCLUDES!) do (
        echo %%F | findstr /i /c:"\%%E\" >nul && set "SKIP=1"
        echo %%F | findstr /i /c:"\%%E" >nul && set "SKIP=1"
    )

    if not defined SKIP (

        set "REL=%%F"
        set "REL=!REL:%TARGET%=!"
        if "!REL:~0,1!"=="\" set "REL=!REL:~1!"

        echo ```!REL!>> "%OUTPUT%"

        REM Try reading file
        type "%%F" >> "%OUTPUT%" 2>nul

        if errorlevel 1 (
            echo [BINARY OR UNREADABLE FILE]>> "%OUTPUT%"
        )

        echo ```>> "%OUTPUT%"
        echo.>> "%OUTPUT%"
    )
)

echo Output written to %OUTPUT%