@echo off
setlocal EnableDelayedExpansion
title Dang build APK Doc Truyen...

echo ============================================
echo   BUILD APK - Doc Truyen
echo   Dung tat cua so nay!
echo ============================================
echo.

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "TOOLS=%USERPROFILE%\DocTruyen_Tools"
set "JDK_DIR=%TOOLS%\jdk17"
set "SDK_DIR=%TOOLS%\android-sdk"
set "JAVA_HOME=%JDK_DIR%"
set "ANDROID_HOME=%SDK_DIR%"
set "ANDROID_SDK_ROOT=%SDK_DIR%"
set "SDKMANAGER=%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat"
set "WRAPPER_JAR=%ROOT%\gradle\wrapper\gradle-wrapper.jar"
set "PATH=%JDK_DIR%\bin;%SDK_DIR%\cmdline-tools\latest\bin;%SDK_DIR%\build-tools\34.0.0;%SDK_DIR%\platform-tools;%PATH%"

if not exist "%TOOLS%" mkdir "%TOOLS%"

echo Thu muc goc: %ROOT%
echo.

:: ── Kiểm tra source code ──
if not exist "%ROOT%\app\src\main\AndroidManifest.xml" (
    echo [LOI] Khong tim thay source code!
    echo Hay giai nen file ZIP, vao thu muc DocTruyen
    echo roi chay BUILD_APK.bat tu trong do.
    echo.
    pause & exit /b 1
)
echo [OK] Source code hop le
echo.

:: ══════════════════════════════════════
:: BUOC 1: JDK 17
:: ══════════════════════════════════════
echo [1/5] Kiem tra Java JDK 17...
if exist "%JDK_DIR%\bin\java.exe" (
    echo [OK] JDK san sang
) else (
    echo Tai JDK 17 portable ~175MB...
    set "F=%TOOLS%\jdk17.zip"
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "[Net.ServicePointManager]::SecurityProtocol='Tls12,Tls13';" ^
        "Invoke-WebRequest 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13+11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.zip' -OutFile '!F!' -UseBasicParsing"
    if not exist "!F!" (
        echo [LOI] Khong tai duoc JDK. Kiem tra Internet.
        pause & exit /b 1
    )
    echo Giai nen JDK...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive '!F!' '%TOOLS%\jdk_tmp' -Force"
    for /d %%i in ("%TOOLS%\jdk_tmp\jdk*") do (
        if not "%%i"=="" (
            xcopy /E /I /Y "%%i" "%JDK_DIR%" >nul 2>&1
        )
    )
    rd /s /q "%TOOLS%\jdk_tmp" >nul 2>&1
    del /f /q "!F!" >nul 2>&1
    if not exist "%JDK_DIR%\bin\java.exe" (
        echo [LOI] Giai nen JDK that bai!
        pause & exit /b 1
    )
    echo [OK] JDK 17 da cai
)
echo.

:: ══════════════════════════════════════
:: BUOC 2: Android SDK
:: ══════════════════════════════════════
echo [2/5] Kiem tra Android Command Line Tools...
if exist "%SDKMANAGER%" (
    echo [OK] Android SDK san sang
) else (
    echo Tai Android cmdline-tools ~150MB...
    set "F=%TOOLS%\cmdtools.zip"
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "[Net.ServicePointManager]::SecurityProtocol='Tls12,Tls13';" ^
        "Invoke-WebRequest 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip' -OutFile '!F!' -UseBasicParsing"
    if not exist "!F!" (
        echo [LOI] Khong tai duoc Android tools.
        pause & exit /b 1
    )
    echo Giai nen...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive '!F!' '%TOOLS%\cmd_tmp' -Force"
    if not exist "%SDK_DIR%\cmdline-tools\latest" mkdir "%SDK_DIR%\cmdline-tools\latest"
    :: Tìm đúng thư mục chứa bin\sdkmanager.bat
    set "FOUND="
    for /r "%TOOLS%\cmd_tmp" %%f in (sdkmanager.bat) do (
        if not defined FOUND (
            set "FOUND=%%~dpf"
            for %%d in ("%%~dpf.") do (
                xcopy /E /I /Y "%%~dpfd.." "%SDK_DIR%\cmdline-tools\latest\" >nul 2>&1
            )
        )
    )
    rd /s /q "%TOOLS%\cmd_tmp" >nul 2>&1
    del /f /q "!F!" >nul 2>&1
    if not exist "%SDKMANAGER%" (
        echo [LOI] Khong tim thay sdkmanager!
        pause & exit /b 1
    )
    echo [OK] Android tools da cai
)
echo.

:: ══════════════════════════════════════
:: BUOC 3: Platform + Build Tools
:: ══════════════════════════════════════
echo [3/5] Kiem tra Android build-tools;34.0.0 ...
if exist "%SDK_DIR%\build-tools\34.0.0\aapt2.exe" (
    echo [OK] Build tools san sang
) else (
    echo Chap nhan license Android...
    (
        for /l %%i in (1,1,15) do echo y
    ) | "%JDK_DIR%\bin\java.exe" -jar "%SDK_DIR%\cmdline-tools\latest\lib\sdkmanager-classpath.jar" --sdk_root="%SDK_DIR%" --licenses >nul 2>&1
    :: Cách đơn giản hơn - chấp nhận bằng echo y
    echo y|call "%SDKMANAGER%" --sdk_root="%SDK_DIR%" --licenses >nul 2>&1
    echo y|call "%SDKMANAGER%" --sdk_root="%SDK_DIR%" --licenses >nul 2>&1
    echo y|call "%SDKMANAGER%" --sdk_root="%SDK_DIR%" --licenses >nul 2>&1
    echo Cai platform-tools, build-tools, platform-34 ^(~400MB^)...
    call "%SDKMANAGER%" --sdk_root="%SDK_DIR%" "platform-tools" "build-tools;34.0.0" "platforms;android-34"
    if errorlevel 1 (
        echo [LOI] Cai build tools that bai!
        pause & exit /b 1
    )
    echo [OK] Build tools da cai
)
echo.

:: ══════════════════════════════════════
:: BUOC 4: Gradle wrapper JAR
:: ══════════════════════════════════════
echo [4/5] Kiem tra Gradle wrapper jar...
if exist "%WRAPPER_JAR%" (
    echo [OK] Gradle wrapper san sang
) else (
    echo Tai gradle-wrapper.jar...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "[Net.ServicePointManager]::SecurityProtocol='Tls12,Tls13';" ^
        "Invoke-WebRequest 'https://github.com/gradle/gradle/raw/v8.4.0/gradle/wrapper/gradle-wrapper.jar' -OutFile '%WRAPPER_JAR%' -UseBasicParsing" >nul 2>&1
    if not exist "%WRAPPER_JAR%" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command ^
            "[Net.ServicePointManager]::SecurityProtocol='Tls12,Tls13';" ^
            "Invoke-WebRequest 'https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar' -OutFile '%WRAPPER_JAR%' -UseBasicParsing" >nul 2>&1
    )
    if not exist "%WRAPPER_JAR%" (
        echo [LOI] Khong tai duoc gradle-wrapper.jar!
        pause & exit /b 1
    )
    echo [OK] Gradle wrapper san sang
)
echo.

:: ══════════════════════════════════════
:: BUOC 5: BUILD
:: ══════════════════════════════════════
echo [5/5] Dang build APK...
echo (Lan dau Gradle tu tai them ~150MB, mat 5-10 phut)
echo.

cd /d "%ROOT%"

:: Ghi local.properties
> "%ROOT%\local.properties" echo sdk.dir=%SDK_DIR:\=/%

:: Build
call "%ROOT%\gradlew.bat" assembleDebug --no-daemon 2>&1
set "ERR=%errorlevel%"
echo.

if "%ERR%"=="0" (
    set "APK=%ROOT%\app\build\outputs\apk\debug\app-debug.apk"
    set "OUT=%USERPROFILE%\Desktop\DocTruyen.apk"
    if exist "!APK!" (
        copy /Y "!APK!" "!OUT!" >nul
        echo ============================================
        echo   THANH CONG!
        echo   File da luu: Desktop\DocTruyen.apk
        echo.
        echo   Gui qua Zalo sang dien thoai roi cai.
        echo ============================================
        start explorer /select,"!OUT!"
    ) else (
        echo [LOI] Khong tim thay APK du build OK
        echo Tim kiem tai: !APK!
    )
) else (
    echo ============================================
    echo   BUILD THAT BAI - Ma loi: %ERR%
    echo ============================================
    echo Hay chup man hinh nay va gui cho ho tro.
)

echo.
pause
endlocal
