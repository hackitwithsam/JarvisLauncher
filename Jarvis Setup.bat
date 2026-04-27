@echo off
title Jarvis MK37 Auto-Installer
chcp 65001 >nul

:: --- KONTROLA ADMINISTRÁTORA ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Tento skript MUSÍŠ spustit jako Správce!
    echo [!] Klikni na soubor pravým tlačítkem a zvol "Spustit jako správce".
    echo.
    pause
    exit /b 1
)

echo ===================================================
echo   Vítejte v automatickém instalátoru Jarvis MK37   
echo ===================================================
echo.

:: --- 1. INSTALACE GITU ---
echo [1/8] Kontrola a instalace Gitu...
git --version >nul 2>&1
if %errorLevel% neq 0 (
    echo Git nenalezen. Pokouším se nainstalovat přes winget...
    winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements
    
    if %errorLevel% neq 0 (
        echo Winget selhal, stahuji Git ručně přes curl...
        curl -L -o git_installer.exe https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe
        echo Instaluji Git (může to chvíli trvat)...
        git_installer.exe /VERYSILENT /NORESTART
        del git_installer.exe
    )
    :: Přidání gitu do PATH pro tuto běžící relaci
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
) else (
    echo [OK] Git je již nainstalován.
)

:: --- 2. INSTALACE PYTHONU 3.11.9 ---
echo.
echo [2/8] Kontrola a instalace Pythonu 3.11.9...

set "PYTHON_EXE="

:: Zkusíme najít, zda už 3.11 neběží v PATH
where python >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=2" %%i in ('python -V') do set "PY_VER=%%i"
    echo %PY_VER% | find "3.11." >nul
    if %errorLevel% equ 0 (
        set "PYTHON_EXE=python"
        echo [OK] Python 3.11 je již aktivní v PATH.
    )
)

:: Pokud není v PATH, zkusíme prohledat klasické instalační cesty
if "%PYTHON_EXE%"=="" (
    if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python311\python.exe" (
        set "PYTHON_EXE=%USERPROFILE%\AppData\Local\Programs\Python\Python311\python.exe"
    ) else if exist "C:\Program Files\Python311\python.exe" (
        set "PYTHON_EXE=C:\Program Files\Python311\python.exe"
    )
)

:: Pokud Python 3.11 stále nemáme, stáhneme ho a nainstalujeme
if "%PYTHON_EXE%"=="" (
    echo Stahuji Python 3.11.9...
    curl -L -o python_installer.exe https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe
    echo Instaluji Python 3.11.9 (tichý režim)...
    python_installer.exe /quiet PrependPath=1 Include_test=0
    del python_installer.exe
    
    :: Znovu zkusíme nastavit cestu k nově nainstalovanému Pythonu
    if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python311\python.exe" (
        set "PYTHON_EXE=%USERPROFILE%\AppData\Local\Programs\Python\Python311\python.exe"
    ) else if exist "C:\Program Files\Python311\python.exe" (
        set "PYTHON_EXE=C:\Program Files\Python311\python.exe"
    ) else (
        echo [ERROR] Nepodařilo se detekovat Python ani po instalaci!
        pause
        exit /b 1
    )
)

:: Launcher kontroluje, že opravdu běží pod verzí 3.11
"%PYTHON_EXE%" -V | find "3.11." >nul
if %errorLevel% neq 0 (
    echo [ERROR] Detekovaný Python není verze 3.11!
    "%PYTHON_EXE%" -V
    pause
    exit /b 1
) else (
    echo [OK] Ověřeno: Používám Python 3.11.
)

:: --- 3. AKTUALIZACE PIPU ---
echo.
echo [3/8] Aktualizuji pip...
"%PYTHON_EXE%" -m pip install --upgrade pip

:: --- 4. INSTALACE PYAUDIO A NUMPY ---
echo.
echo [4/8] Instaluji PyAudio a NumPy (preferuji hotové binárky/wheely)...

:: Pokus o instalaci s --only-binary pro zamezení chybám při kompilaci
"%PYTHON_EXE%" -m pip install pyaudio numpy --only-binary=:all:
if %errorLevel% neq 0 (
    echo [WARNING] Instalace přes --only-binary selhala. Zkouším standardní fallback...
    "%PYTHON_EXE%" -m pip install pyaudio numpy
) else (
    echo [OK] PyAudio a NumPy nainstalovány z binárních wheelů bez build chyb.
)

:: --- 5. TEST PYAUDIO A NUMPY ---
echo.
echo [5/8] Testuji funkčnost modulů...
"%PYTHON_EXE%" -c "import pyaudio; import numpy; print('Test úspěšný: Moduly se načetly.')" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] PyAudio + NumPy: OK
) else (
    echo [WARNING] PyAudio + NumPy: TEST SELHAL (Chybějící knihovny nebo ovladače zvuku).
)

:: --- 6. KLONOVÁNÍ REPOZITÁŘE ---
echo.
echo [6/8] Klonuji repozitář Jarvis-MK37...
git clone https://github.com/FatihMakes/Jarvis-MK37
cd Jarvis-MK37

:: --- 7. INSTALACE REQUIREMENTS ---
echo.
echo [7/8] Instaluji balíčky z requirements.txt...
"%PYTHON_EXE%" -m pip install -r requirements.txt

:: --- 8. INSTALACE PLAYWRIGHT CHROMIUM ---
echo.
echo [8/8] Instaluji prohlížeč Chromium pro Playwright...
"%PYTHON_EXE%" -m playwright install chromium

:: --- FINÁLNÍ SPUŠTĚNÍ ---
echo.
echo ===================================================
echo   Vše připraveno! Spouštím aplikaci Jarvis MK37...  
echo ===================================================
echo.

"%PYTHON_EXE%" main.py

pause
