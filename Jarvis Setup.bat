@ECHO OFF
TITLE Mark-XXXIX Complete Auto-Setup Python 3.11
COLOR 0A
MODE CON: COLS=100 LINES=40

ECHO.
ECHO ======================================================
ECHO    Mark-XXXIX Auto-Setup - NO ADMIN - Python 3.11
ECHO ======================================================
ECHO.

:: Create target directory in user folder
SET "TARGET=%USERPROFILE%\Mark-XXXIX"
IF EXIST "%TARGET%" (
    ECHO [INFO] Mazu starou instalaci...
    RD /S /Q "%TARGET%"
)
MKDIR "%TARGET%"
CD /D "%TARGET%"

:: Check if Git is available
ECHO [1/5] Checking installed tools...
WHERE git >NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 (
    ECHO [INFO] Git nenalezen - stahuji portable Git...
    POWERSHELL -Command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/PortableGit-2.45.2-64-bit.7z.exe' -OutFile '%TARGET%\PortableGit.exe' -UseBasicParsing"
    IF NOT EXIST "%TARGET%\PortableGit.exe" (
        ECHO [ERROR] Stazeni Git selhalo! Zkontroluj internet.
        PAUSE
        EXIT /B 1
    )
    ECHO [INFO] Rozbaluji Git...
    START /WAIT "" "%TARGET%\PortableGit.exe" -o"%TARGET%\git" -y
    SET "PATH=%TARGET%\git\bin;%PATH%"
    DEL "%TARGET%\PortableGit.exe"
)

:: Install Python 3.11.9
ECHO [2/5] Stahuji Python 3.11.9...
POWERSHELL -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -OutFile '%TARGET%\python-install.exe' -UseBasicParsing"
IF NOT EXIST "%TARGET%\python-install.exe" (
    ECHO [ERROR] Stazeni Pythonu selhalo!
    PAUSE
    EXIT /B 1
)

ECHO [INFO] Instaluji Python 3.11.9 (pouze pro tohoto uzivatele)...
START /WAIT "" "%TARGET%\python-install.exe" /quiet TargetDir="%TARGET%\python311" InstallAllUsers=0 PrependPath=0 Include_test=0 Include_debug=0 Include_doc=0 Include_tcltk=0 Include_launcher=0
DEL "%TARGET%\python-install.exe"

:: Add Python to PATH for this session
SET "PATH=%TARGET%\python311;%TARGET%\python311\Scripts;%PATH%"

:: Verify Python version
python --version
IF %ERRORLEVEL% NEQ 0 (
    ECHO [ERROR] Python 3.11 se nenainstaloval!
    PAUSE
    EXIT /B 1
)

:: Get pip
ECHO [INFO] Instaluji pip...
python -m ensurepip --upgrade
python -m pip install --upgrade pip setuptools wheel

ECHO [3/5] Cloning Mark-XXXIX...
git clone https://github.com/FatihMakes/Mark-XXXIX.git "%TARGET%\repo"
XCOPY "%TARGET%\repo\*" "%TARGET%" /E /I /Y >NUL
RD /S /Q "%TARGET%\repo"

ECHO [4/5] Installing PyAudio + numpy + dependencies...
python -m pip install --only-binary=all pyaudio numpy
python -m pip install -r requirements.txt
IF %ERRORLEVEL% NEQ 0 (
    ECHO [WARNING] requirements.txt selhal, instaluji jednotlive...
    python -m pip install --only-binary=all pillow requests beautifulsoup4 google-generativeai google-genai keyboard
)

ECHO [5/5] Installing Playwright + Chromium...
python -m playwright install chromium
IF %ERRORLEVEL% NEQ 0 (
    python -m pip install playwright
    python -m playwright install chromium
)

ECHO.
ECHO ======================================================
ECHO    Mark-XXXIX READY - Python 3.11.9
ECHO ======================================================
ECHO.
ECHO Testing PyAudio...
python -c "import pyaudio; print('[OK] PyAudio:', pyaudio.get_portaudio_version_text())" 2>NUL
IF %ERRORLEVEL% NEQ 0 ECHO [WARNING] PyAudio neni k dispozici
ECHO Testing numpy...
python -c "import numpy; print('[OK] numpy:', numpy.__version__)" 2>NUL
IF %ERRORLEVEL% NEQ 0 ECHO [WARNING] numpy neni k dispozici
ECHO.
ECHO Spoustim Mark-XXXIX...
TIMEOUT /T 2 /NOBREAK >NUL

:LAUNCH
CLS
ECHO [LAUNCH] python main.py
ECHO.
python main.py

ECHO.
ECHO ======================================================
ECHO    Mark-XXXIX ukoncen
ECHO ======================================================
ECHO.
ECHO [R] - Restart
ECHO [X] - Konec
ECHO.
SET /P choice="Volba: "
IF /I "%choice%"=="R" GOTO LAUNCH

ECHO [DONE] Hotovo.
PAUSE
