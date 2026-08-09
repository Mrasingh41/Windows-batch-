@echo off
setlocal EnableExtensions

:: ============================================================
:: Windows SMB / Network Discovery Configuration Script
:: Automatically requests Administrator privileges.
:: ============================================================

:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ============================================================
echo   Windows Network Configuration
echo ============================================================
echo.

echo [1/3] Enabling Function Discovery Resource Publication service...
sc config FDResPub start= auto >nul
if %errorlevel% neq 0 (
    echo ERROR: Could not configure FDResPub service.
) else (
    net start FDResPub >nul 2>&1
    echo FDResPub service is configured as Automatic and started.
)

echo.
echo [2/3] Disabling "Microsoft network client: Digitally sign
echo        communications (always)"...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" ^
    /v "EnableSecuritySignature" /t REG_DWORD /d 0 /f >nul

if %errorlevel% neq 0 (
    echo ERROR: Could not update the SMB signing setting.
) else (
    echo SMB client mandatory signing has been disabled.
)

echo.
echo [3/3] Enabling insecure guest logons...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" ^
    /v "AllowInsecureGuestAuth" /t REG_DWORD /d 1 /f >nul

if %errorlevel% neq 0 (
    echo ERROR: Could not enable insecure guest logons.
) else (
    echo Insecure guest logons have been enabled.
)

echo.
echo ============================================================
echo   Configuration completed.
echo   Please restart Windows for all changes to take effect.
echo ============================================================
echo.
pause
endlocal
