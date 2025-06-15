@echo off
:: =============================================================================
::           Developed by Nahid.
:: =============================================================================

:check_admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

echo.
echo [INFO] Starting system cleanup process...
echo [ACTION] Clearing Event Viewer logs...
for /F "tokens=*" %%a in ('wevtutil el') DO (wevtutil cl "%%a" >nul 2>&1)

echo [ACTION] Clearing Windows temporary files...
if exist "%SystemRoot%\Temp\*.*" (
    del /q /f /s "%SystemRoot%\Temp\*.*" >nul 2>&1
    rd /s /q "%SystemRoot%\Temp" >nul 2>&1
    md "%SystemRoot%\Temp" >nul 2>&1
)

echo [ACTION] Clearing user temporary files...
if exist "%Temp%\*.*" (
    del /q /f /s "%Temp%\*.*" >nul 2>&1
    rd /s /q "%Temp%" >nul 2>&1
    md "%Temp%" >nul 2>&1
)

echo [ACTION] Clearing Prefetch files...
if exist "%SystemRoot%\Prefetch\*.*" (
    del /q /f /s "%SystemRoot%\Prefetch\*.*" >nul 2>&1
)

echo [ACTION] Clearing Windows Update cache...
net stop wuauserv >nul 2>&1
if exist "%SystemRoot%\SoftwareDistribution\Download\*.*" (
    del /q /f /s "%SystemRoot%\SoftwareDistribution\Download\*.*"
)
net start wuauserv >nul 2>&1
echo [SUCCESS] System cleanup completed.
echo.

echo [INFO] Applying performance and system tweaks...
echo [ACTION] Setting visual effects for best performance...
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d "2" /f >nul

echo [ACTION] Optimizing for program performance...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "26" /f >nul

echo [ACTION] Disabling non-essential services for gaming...
sc config "DiagTrack" start= disabled >nul
sc config "dmwappushservice" start= disabled >nul
sc config "DusmSvc" start= disabled >nul
sc config "diagnosticshub.standardcollector.service" start= disabled >nul
sc config "MapsBroker" start= disabled >nul
sc config "wscsvc" start= disabled >nul
sc config "lfsvc" start= disabled >nul
sc config "TroubleshootingSvc" start= disabled >nul
sc config "PcaSvc" start= disabled >nul
sc config "Spooler" start= disabled >nul
sc config "Fax" start= disabled >nul

echo [ACTION] Ensuring Xbox Game Bar services are enabled...
sc config "XblAuthManager" start= auto >nul
sc config "XblGameSave" start= auto >nul
sc config "XboxGipSvc" start= auto >nul
sc config "XboxNetApiSvc" start= auto >nul
sc config "BcastDVRUserService" start= auto >nul
echo [SUCCESS] Performance tweaks applied.
echo.

echo [INFO] Closing games, launchers, and unnecessary background processes...
taskkill /f /im VALORANT-Win64-Shipping.exe >nul 2>&1
taskkill /f /im RiotClientServices.exe >nul 2>&1
taskkill /f /im FortniteClient-Win64-Shipping.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im OneDrive.exe >nul 2>&1
taskkill /f /im "steam.exe" >nul 2>&1
taskkill /f /im "steamservice.exe" >nul 2>&1
taskkill /f /im "SearchHost.exe" >nul 2>&1
taskkill /f /im YourPhone.exe >nul 2>&1
taskkill /f /im "Cortana.exe" >nul 2>&1
taskkill /f /im "qbittorrent.exe" >nul 2>&1
taskkill /f /im "WinStore.App.exe" >nul 2>&1
taskkill /f /im "spoolsv.exe" >nul 2>&1
taskkill /f /im "CrossDeviceResume.exe" >nul 2>&1
echo [SUCCESS] Unnecessary processes closed.
echo.

echo [INFO] Starting Disk Optimization...
echo [ACTION] Optimizing System Drive (C:)...
defrag C: /O
cleanmgr /sagerun:1 >nul
echo [SUCCESS] Disk Optimization completed.
echo.

:ending
echo.
echo [INFO] Your PC is now optimized. This window will close in 3 seconds...
timeout /t 3 >nul
exit /B
