@echo off
setlocal EnableDelayedExpansion
title AethexFlow Enterprise - Deploy
color 0C
cls
echo.
echo  ========================================
echo   AethexFlow Enterprise
echo   the 1st Real Ai
echo  ========================================
echo.

cd /d "%~dp0"

:: ========== FORCE PATH ==========
set "PATH=%ProgramFiles%\nodejs;%ProgramFiles(x86)%\nodejs;%LOCALAPPDATA%\Programs\node;%APPDATA%\npm;%PATH%"

:: ========== 1. NODE ==========
echo  [1/4] Node.js check...
node -v >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('node -v') do echo  OK - %%i
) else (
    echo  Node nahi mila.
    echo  https://nodejs.org se LTS install karo.
    echo  Install ke baad PC restart karke dobara chalao.
    pause
    exit /b 1
)
echo.

:: ========== 2. WRANGLER ==========
echo  [2/4] Wrangler check...
wrangler --version >nul 2>&1
if !errorlevel! equ 0 (
    echo  OK - Wrangler already present
) else (
    echo  Installing Wrangler...
    call npm install -g wrangler --allow-scripts=esbuild,workerd >nul 2>&1
    if !errorlevel! neq 0 (
        call npm config set allow-scripts=esbuild,workerd --location=user >nul 2>&1
        call npm install -g wrangler
    )
    wrangler --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo  FAIL - Wrangler install nahi hua
        echo  Manual: npm install -g wrangler
        pause
        exit /b 1
    )
    echo  OK - Wrangler installed
)
echo.

:: ========== 3. D1 ID ==========
echo  [3/4] D1 Database...
findstr /C:"PASTE_YOUR_EXISTING_D1_ID_HERE" wrangler.toml >nul
if !errorlevel! equ 0 (
    echo.
    echo  ========================================
    echo   Existing D1 use hoga: aethexflow-production
    echo.
    echo   1. Cloudflare Dashboard kholo
    echo   2. Workers ^& Pages ^> D1 ^> aethexflow-production
    echo   3. Database ID copy karo
    echo   4. wrangler.toml kholo
    echo   5. PASTE_YOUR_EXISTING_D1_ID_HERE hatao
    echo      uski jagah ID paste karo
    echo   6. Save karo
    echo   7. Yeh deploy.cmd DOBARA chalao
    echo  ========================================
    echo.
    pause
    exit /b 0
) else (
    echo  OK - D1 ID already set
)
echo.

:: ========== 4. DEPLOY ==========
echo  [4/4] Deploying...
call wrangler deploy
if !errorlevel! neq 0 (
    echo.
    echo  Deploy FAIL. Error upar dekho.
    pause
    exit /b 1
)

echo.
echo  ========================================
echo   SUCCESS
echo  ========================================
echo.
echo  Ab kholo: /owner.html
echo  Wahan 6-digit code generate karo.
echo.
pause
