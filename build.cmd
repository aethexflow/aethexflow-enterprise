@echo off
title AethexFlow - Build ZIP
cd /d "%~dp0"
echo.
echo  Building latest ZIP...
echo.
python scripts\update_and_pack.py
if %errorlevel% neq 0 (
    echo.
    echo  Python not found or error occurred.
    echo  Make sure Python is installed.
    pause
    exit /b 1
)
echo.
echo  ZIP ready in parent folder.
pause
