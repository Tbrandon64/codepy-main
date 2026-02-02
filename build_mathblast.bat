@echo off
REM ============================================================================
REM Math Blast - Complete Build & Package Script
REM ============================================================================
REM This script automates the complete build and packaging process for Math Blast
REM Godot 4.6 project on Windows.
REM
REM Features:
REM - Exports to Windows, Linux, and Web platforms
REM - Sets custom .exe icon using rcedit
REM - Creates zip packages for distribution
REM - Includes error checking and recovery
REM
REM Prerequisites:
REM - Godot 4.6+ in PATH or specify path below
REM - rcedit.exe in ./tools/rcedit.exe
REM - icon file at res://icons/math_blast.ico (in project)
REM - PowerShell 5.0+ (for Compress-Archive)
REM ============================================================================

setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ============================================================================
REM Configuration
REM ============================================================================
set VERSION=v1.0
set PROJECT_NAME=MathBlast
set BUILD_DIR=build
set RELEASES_DIR=releases
set TOOLS_DIR=tools
set RCEDIT=%TOOLS_DIR%\rcedit.exe
set ICON_PATH=icons\math_blast.ico

REM Try to find Godot in PATH first, otherwise use full path
for /f "delims=" %%A in ('where godot.exe 2^>nul') do (
    set GODOT_EXE=%%A
    goto godot_found
)

REM If not in PATH, use default path
set GODOT_EXE=C:\Users\tb586\Documents\Godot_v4.6-stable_win64.exe

:godot_found
echo.
echo ============================================================================
echo  Math Blast Build & Package Script
echo ============================================================================
echo.
echo Configuration:
echo   Godot Executable: %GODOT_EXE%
echo   Build Directory: %BUILD_DIR%
echo   Releases Directory: %RELEASES_DIR%
echo   Version: %VERSION%
echo.

REM ============================================================================
REM Verify Prerequisites
REM ============================================================================
echo [1/6] Verifying prerequisites...

if not exist "%GODOT_EXE%" (
    echo ERROR: Godot executable not found at %GODOT_EXE%
    echo Please ensure Godot 4.5+ is in PATH or update GODOT_EXE variable
    pause
    exit /b 1
)
echo   ✓ Godot executable found

if not exist "%RCEDIT%" (
    echo WARNING: rcedit.exe not found at %RCEDIT%
    echo   Icon customization will be skipped
    set RCEDIT_AVAILABLE=0
) else (
    echo   ✓ rcedit.exe found
    set RCEDIT_AVAILABLE=1
)

REM ============================================================================
REM Create Directories
REM ============================================================================
echo.
echo [2/6] Creating directories...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
echo   ✓ Build directory created

if not exist "%RELEASES_DIR%" mkdir "%RELEASES_DIR%"
echo   ✓ Releases directory created

REM ============================================================================
REM Export Windows Desktop
REM ============================================================================
echo.
echo [3/6] Exporting Windows Desktop...
set WINDOWS_EXE=%BUILD_DIR%\%PROJECT_NAME%.exe

"%GODOT_EXE%" --headless --export-release "Windows Desktop" "%WINDOWS_EXE%"

if errorlevel 1 (
    echo ERROR: Windows export failed
    set WINDOWS_SUCCESS=0
) else (
    echo   ✓ Windows export successful: %WINDOWS_EXE%
    set WINDOWS_SUCCESS=1
    
    REM ========================================================================
    REM Set Custom Icon for Windows EXE
    REM ========================================================================
    if !RCEDIT_AVAILABLE! equ 1 (
        echo   Setting custom icon...
        "%RCEDIT%" "%WINDOWS_EXE%" --set-icon "%ICON_PATH%"
        if errorlevel 1 (
            echo   WARNING: Failed to set custom icon, continuing...
        ) else (
            echo   ✓ Custom icon applied
        )
    )
)

REM ============================================================================
REM Export Linux/X11
REM ============================================================================
echo.
echo [4/6] Exporting Linux/X11...
set LINUX_EXE=%BUILD_DIR%\%PROJECT_NAME%.x86_64

"%GODOT_EXE%" --headless --export-release "Linux/X11" "%LINUX_EXE%"

if errorlevel 1 (
    echo ERROR: Linux export failed
    set LINUX_SUCCESS=0
) else (
    echo   ✓ Linux export successful: %LINUX_EXE%
    set LINUX_SUCCESS=1
)

REM ============================================================================
REM Export Web (HTML5)
REM ============================================================================
echo.
echo [5/6] Exporting Web (HTML5)...
set WEB_INDEX=%BUILD_DIR%\index.html

"%GODOT_EXE%" --headless --export-release "Web" "%WEB_INDEX%"

if errorlevel 1 (
    echo ERROR: Web export failed
    set WEB_SUCCESS=0
) else (
    echo   ✓ Web export successful
    set WEB_SUCCESS=1
)

REM ============================================================================
REM Create Distribution Packages (using PowerShell)
REM ============================================================================
echo.
echo [6/6] Creating distribution packages...

REM Use PowerShell for Compress-Archive with fallback to tar
powershell -NoProfile -ExecutionPolicy Bypass -Command "^
$ErrorActionPreference = 'Stop'
$BuildDir = '%BUILD_DIR%'
$ReleasesDir = '%RELEASES_DIR%'
$Version = '%VERSION%'
$ProjectName = '%PROJECT_NAME%'
$WindowsSuccess = %WINDOWS_SUCCESS%
$LinuxSuccess = %LINUX_SUCCESS%
$WebSuccess = %WEB_SUCCESS%

try {
    # Windows Package
    if ($WindowsSuccess -eq 1) {
        Write-Host '   Creating Windows package...' -ForegroundColor Cyan
        $WindowsZip = Join-Path $ReleasesDir ($ProjectName + '_' + $Version + '_Windows.zip')
        $FilesToAdd = @(
            (Join-Path $BuildDir ($ProjectName + '.exe')),
            'README.md'
        )
        
        # Check for .pck file (separate resource pack)
        $PckFile = Join-Path $BuildDir ($ProjectName + '.pck')
        if (Test-Path $PckFile) {
            $FilesToAdd += $PckFile
        }
        
        # Remove existing zip if it exists
        if (Test-Path $WindowsZip) { Remove-Item $WindowsZip }
        
        # Create zip using PowerShell 5.0+
        Compress-Archive -Path $FilesToAdd -DestinationPath $WindowsZip -CompressionLevel Optimal
        Write-Host ('   ✓ Windows package created: ' + $WindowsZip) -ForegroundColor Green
    }
    
    # Linux Package
    if ($LinuxSuccess -eq 1) {
        Write-Host '   Creating Linux package...' -ForegroundColor Cyan
        $LinuxZip = Join-Path $ReleasesDir ($ProjectName + '_' + $Version + '_Linux.zip')
        $FilesToAdd = @(
            (Join-Path $BuildDir ($ProjectName + '.x86_64')),
            'README.md'
        )
        
        # Check for .pck file
        $PckFile = Join-Path $BuildDir ($ProjectName + '.pck')
        if (Test-Path $PckFile) {
            $FilesToAdd += $PckFile
        }
        
        if (Test-Path $LinuxZip) { Remove-Item $LinuxZip }
        
        Compress-Archive -Path $FilesToAdd -DestinationPath $LinuxZip -CompressionLevel Optimal
        Write-Host ('   ✓ Linux package created: ' + $LinuxZip) -ForegroundColor Green
    }
    
    # Web Package (entire build folder)
    if ($WebSuccess -eq 1) {
        Write-Host '   Creating Web package...' -ForegroundColor Cyan
        $WebZip = Join-Path $ReleasesDir ($ProjectName + '_' + $Version + '_Web.zip')
        
        if (Test-Path $WebZip) { Remove-Item $WebZip }
        
        # Add all files from build directory
        Compress-Archive -Path (Join-Path $BuildDir '*') -DestinationPath $WebZip -CompressionLevel Optimal
        Write-Host ('   ✓ Web package created: ' + $WebZip) -ForegroundColor Green
    }
}
catch {
    Write-Host ('ERROR: Packaging failed - ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
"

if errorlevel 1 (
    echo ERROR: PowerShell packaging failed. Attempting tar fallback...
    
    if !WINDOWS_SUCCESS! equ 1 (
        echo   Attempting tar for Windows...
        cd "%BUILD_DIR%"
        tar -czf "..\%RELEASES_DIR%\%PROJECT_NAME%_%VERSION%_Windows.tar.gz" "%PROJECT_NAME%.exe" 2>nul
        cd ..
    )
    
    if !LINUX_SUCCESS! equ 1 (
        echo   Attempting tar for Linux...
        cd "%BUILD_DIR%"
        tar -czf "..\%RELEASES_DIR%\%PROJECT_NAME%_%VERSION%_Linux.tar.gz" "%PROJECT_NAME%.x86_64" 2>nul
        cd ..
    )
    
    if !WEB_SUCCESS! equ 1 (
        echo   Attempting tar for Web...
        cd "%BUILD_DIR%"
        tar -czf "..\%RELEASES_DIR%\%PROJECT_NAME%_%VERSION%_Web.tar.gz" * 2>nul
        cd ..
    )
)

REM ============================================================================
REM Summary
REM ============================================================================
echo.
echo ============================================================================
echo  Build Summary
echo ============================================================================
echo.

if !WINDOWS_SUCCESS! equ 1 (
    echo ✓ Windows Desktop: %WINDOWS_EXE%
    echo   Package: %RELEASES_DIR%\%PROJECT_NAME%_%VERSION%_Windows.zip
) else (
    echo ✗ Windows Desktop: FAILED
)

if !LINUX_SUCCESS! equ 1 (
    echo ✓ Linux/X11: %LINUX_EXE%
    echo   Package: %RELEASES_DIR%\%PROJECT_NAME%_%VERSION%_Linux.zip
) else (
    echo ✗ Linux/X11: FAILED
)

if !WEB_SUCCESS! equ 1 (
    echo ✓ Web/HTML5: %BUILD_DIR%\index.html
    echo   Package: %RELEASES_DIR%\%PROJECT_NAME%_%VERSION%_Web.zip
) else (
    echo ✗ Web/HTML5: FAILED
)

echo.
echo Build directory: %cd%\%BUILD_DIR%
echo Packages directory: %cd%\%RELEASES_DIR%
echo.

REM Final status
if !WINDOWS_SUCCESS! equ 1 (
    if !LINUX_SUCCESS! equ 1 (
        if !WEB_SUCCESS! equ 1 (
            echo ✓ ALL BUILDS SUCCESSFUL! Ready for distribution.
            echo.
            echo Next steps:
            echo   1. Test packages in %RELEASES_DIR%\
            echo   2. Upload to itch.io
            echo   3. Create GitHub release with builds as assets
            echo   4. Share with community!
            echo.
            pause
            exit /b 0
        )
    )
)

echo.
echo ⚠ WARNING: Some builds failed. Check output above for details.
pause
exit /b 1
