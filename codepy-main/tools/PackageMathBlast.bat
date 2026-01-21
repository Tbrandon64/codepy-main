@echo off
REM Math Blast Auto-Packager
REM Drag MathBlast.exe onto this file to auto-package with README
REM Creates: MathBlast_setup.exe with all files zipped

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Math Blast Auto-Packager v1.0
echo ==========================================
echo.

if "%~1"=="" (
    echo Usage: Drag MathBlast.exe onto this file
    pause
    exit /b
)

set "EXE_PATH=%~1"
set "EXE_NAME=%~n1"
set "EXE_DIR=%~dp1"

echo Found: %EXE_NAME%
echo Location: %EXE_DIR%
echo.

REM Check if 7-Zip or WinRAR is installed
if exist "C:\Program Files\7-Zip\7z.exe" (
    set "ZIP_CMD=C:\Program Files\7-Zip\7z.exe"
    set "ZIP_TYPE=7zip"
) else if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    set "ZIP_CMD=C:\Program Files\WinRAR\WinRAR.exe"
    set "ZIP_TYPE=winrar"
) else (
    echo ERROR: 7-Zip or WinRAR not found
    echo Please install 7-Zip from: https://www.7-zip.org/
    pause
    exit /b
)

REM Create packaging folder
set "PACK_DIR=%EXE_DIR%MathBlast_Package"
if exist "%PACK_DIR%" rmdir /s /q "%PACK_DIR%"
mkdir "%PACK_DIR%"

echo Copying files...
copy "%EXE_PATH%" "%PACK_DIR%\MathBlast.exe"
copy "%EXE_DIR%README.md" "%PACK_DIR%\README.md"
copy "%EXE_DIR%LICENSE" "%PACK_DIR%\LICENSE" 2>nul

REM Create ZIP archive
echo Compressing files...
if "%ZIP_TYPE%"=="7zip" (
    "%ZIP_CMD%" a -tzip "%PACK_DIR%\MathBlast.zip" "%PACK_DIR%\*" -x "*.zip"
) else (
    "%ZIP_CMD%" a -ep1 "%PACK_DIR%\MathBlast.zip" "%PACK_DIR%\*"
)

REM Rename to setup executable
if exist "%PACK_DIR%\MathBlast.zip" (
    echo Finalizing...
    ren "%PACK_DIR%\MathBlast.zip" "MathBlast_setup.exe"
    move "%PACK_DIR%\MathBlast_setup.exe" "%EXE_DIR%"
    echo.
    echo SUCCESS! Created: %EXE_DIR%MathBlast_setup.exe
) else (
    echo ERROR: Failed to create archive
)

REM Cleanup
rmdir /s /q "%PACK_DIR%"

echo.
pause
