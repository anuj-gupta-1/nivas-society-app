@echo off
REM Nivas Build Script for Windows
REM Builds Android APK and App Bundle for release

echo.
echo ================================
echo    Nivas Build Script
echo ================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

echo [OK] Flutter found
flutter --version
echo.

REM Clean previous builds
echo [INFO] Cleaning previous builds...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Clean failed
    exit /b 1
)
echo [OK] Clean complete
echo.

REM Get dependencies
echo [INFO] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to get dependencies
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM Run code analysis
echo [INFO] Running code analysis...
call flutter analyze
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Code analysis found issues
    set /p continue="Continue anyway? (y/n): "
    if /i not "%continue%"=="y" exit /b 1
)
echo [OK] Analysis complete
echo.

REM Format code
echo [INFO] Formatting code...
call flutter format .
echo [OK] Code formatted
echo.

REM Build options
echo Select build type:
echo 1) APK (single file, larger size)
echo 2) App Bundle (for Play Store, recommended)
echo 3) Split APKs (multiple files, smaller size)
echo 4) All of the above
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" goto build_apk
if "%choice%"=="2" goto build_bundle
if "%choice%"=="3" goto build_split
if "%choice%"=="4" goto build_all
echo [ERROR] Invalid choice
exit /b 1

:build_apk
echo.
echo [INFO] Building APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] APK build failed
    exit /b 1
)
echo [OK] APK built successfully
echo [INFO] Location: build\app\outputs\flutter-apk\app-release.apk
goto end

:build_bundle
echo.
echo [INFO] Building App Bundle...
call flutter build appbundle --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] App Bundle build failed
    exit /b 1
)
echo [OK] App Bundle built successfully
echo [INFO] Location: build\app\outputs\bundle\release\app-release.aab
goto end

:build_split
echo.
echo [INFO] Building Split APKs...
call flutter build apk --split-per-abi --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Split APKs build failed
    exit /b 1
)
echo [OK] Split APKs built successfully
echo [INFO] Location: build\app\outputs\flutter-apk\
echo    - app-armeabi-v7a-release.apk (32-bit ARM)
echo    - app-arm64-v8a-release.apk (64-bit ARM)
echo    - app-x86_64-release.apk (64-bit Intel)
goto end

:build_all
echo.
echo [INFO] Building APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] APK build failed
    exit /b 1
)
echo [OK] APK built
echo.
echo [INFO] Building App Bundle...
call flutter build appbundle --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] App Bundle build failed
    exit /b 1
)
echo [OK] App Bundle built
echo.
echo [INFO] Building Split APKs...
call flutter build apk --split-per-abi --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Split APKs build failed
    exit /b 1
)
echo [OK] Split APKs built
echo.
echo [OK] All builds completed successfully
echo [INFO] Locations:
echo    APK: build\app\outputs\flutter-apk\app-release.apk
echo    Bundle: build\app\outputs\bundle\release\app-release.aab
echo    Split APKs: build\app\outputs\flutter-apk\
goto end

:end
echo.
echo ================================
echo    Build Complete!
echo ================================
echo.
echo Next steps:
echo 1. Test the APK on a real device
echo 2. Upload to Firebase App Distribution for beta testing
echo 3. Upload App Bundle to Google Play Console for production
echo.
pause
