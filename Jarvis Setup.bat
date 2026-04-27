@echo off
title Jarvis MK37 No-Admin Installer
chcp 65001 >nul

:: --- NASTAVENÍ CEST ---
set "INSTALL_DIR=%LOCALAPPDATA%\Jarvis_Setup"
set "PY_DIR=%INSTALL_DIR%\Python311"
set "GIT_DIR=%INSTALL_DIR%\Git"
set "PYTHON_EXE=%PY_DIR%\python.exe"
set "GIT_EXE=%GIT_DIR%\bin\git.exe"

echo ===================================================
echo   Jarvis MK37 - Instalace bez nutnosti Admina
echo ===================================================
echo.

:: Vytvoření instalační složky
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
cd /d "%INSTALL_DIR%"

:: --- 1. PYTHON 3.11.9 (USER ONLY) ---
if not exist "%PYTHON_EXE%" (
    echo [1/6] Stahuji Python 3.11.9 pro uživatele...
    curl -L -o python_inst.exe https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe
    echo [!] Instaluji Python do: %PY_DIR%
    :: Instalace: pouze pro uživatele, bez admina, do konkrétní složky
    python_inst.exe /quiet InstallAllUsers=0 TargetDir="%PY_DIR%" PrependPath=0 Include_test=0
    del python_inst.exe
) else (
    echo [OK] Python je již připraven.
)

:: --- 2. GIT PORTABLE ---
if not exist "%GIT_EXE%" (
    echo [2/6] Stahuji Git Portable...
    :: Stahujeme minimální portable verzi (64-bit)
    curl -L -o git.zip https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/PortableGit-2.44.0-64-bit.7z.exe
    echo [!] Rozbaluji Git (může to chvíli trvat)...
    :: Windows 10/11 umí tar, který zvládne i některé .exe archivy, pokud ne, zkusíme ho spustit jako extraktor
    mkdir "%GIT_DIR%"
    move git.zip "%GIT_DIR%\git_setup.exe"
    cd /d "%GIT_DIR%"
    git_setup.exe -y -o"%GIT_DIR%"
    del git_setup.exe
    cd /d "%INSTALL_DIR%"
) else (
    echo [OK] Git je již připraven.
)

:: --- 3. KONTROLA VERZE ---
"%PYTHON_EXE%" -V | find "3.11." >nul
if %errorLevel% neq 0 (
    echo [CHYBA] Python se nenainstaloval správně.
    pause
    exit /b 1
)

:: --- 4. PYAUDIO A NUMPY (BINARY ONLY) ---
echo.
echo [3/6] Instaluji PyAudio a NumPy (Wheely)...
"%PYTHON_EXE%" -m pip install --upgrade pip
"%PYTHON_EXE%" -m pip install pyaudio numpy --only-binary=:all:
if %errorLevel% neq 0 (
    echo [WARNING] Binary selhaly, zkouším běžný install...
    "%PYTHON_EXE%" -m pip install pyaudio numpy
)

:: --- 5. KLONOVÁNÍ A REQUIREMENTS ---
echo.
echo [4/6] Stahuji projekt Jarvis-MK37...
if exist "Jarvis-MK37" (
    echo Složka Jarvis-MK37 už existuje, aktualizuji...
    cd Jarvis-MK37
    "%GIT_EXE%" pull
) else (
    "%GIT_EXE%" clone https://github.com/FatihMakes/Jarvis-MK37
    cd Jarvis-MK37
)

echo [5/6] Instaluji závislosti projektu...
"%PYTHON_EXE%" -m pip install -r requirements.txt
"%PYTHON_EXE%" -m playwright install chromium

:: --- 6. SPUŠTĚNÍ ---
echo.
echo [6/6] Test modulů...
"%PYTHON_EXE%" -c "import pyaudio; import numpy; print('PyAudio + NumPy: OK')"

echo.
echo ===================================================
echo   HOTOVO! Jarvis se nyní spustí.
echo   Příště stačí spustit: %PYTHON_EXE% main.py
echo ===================================================
echo.

"%PYTHON_EXE%" main.py
pause
