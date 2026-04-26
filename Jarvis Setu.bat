@ECHO OFF
TITLE Jarvis-MK37 Auto-Setup + Launch (No Admin)
COLOR 0A
MODE CON: COLS=100 LINES=40

ECHO.
ECHO ======================================================
ECHO    Jarvis-MK37 Auto-Setup - NO ADMIN NEEDED
ECHO ======================================================
ECHO.

:: Create target directory in user folder
SET "TARGET=%USERPROFILE%\Jarvis-MK37"
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

WHERE python >NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 (
    ECHO [INFO] Python nenalezen - stahuji portable Python...
    POWERSHELL -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip' -OutFile '%TARGET%\python.zip' -UseBasicParsing"
    IF NOT EXIST "%TARGET%\python.zip" (
        ECHO [ERROR] Stazeni Pythonu selhalo!
        PAUSE
        EXIT /B 1
    )
    ECHO [INFO] Rozbaluji Python...
    POWERSHELL -Command "Expand-Archive -Path '%TARGET%\python.zip' -DestinationPath '%TARGET%\python' -Force"
    SET "PATH=%TARGET%\python;%PATH%"
    DEL "%TARGET%\python.zip"
    :: Stahnout a pridat get-pip.py
    POWERSHELL -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%TARGET%\get-pip.py' -UseBasicParsing"
    python "%TARGET%\get-pip.py" --no-warn-script-location
)

ECHO [2/5] Cloning Jarvis-MK37...
git clone https://github.com/FatihMakes/Jarvis-MK37.git "%TARGET%\repo"
XCOPY "%TARGET%\repo\*" "%TARGET%" /E /I /Y >NUL
RD /S /Q "%TARGET%\repo"

ECHO [3/5] Installing PyAudio + numpy (wheels - no build errors)...
python -m pip install --upgrade pip --no-warn-script-location
python -m pip install --only-binary=all --no-warn-script-location pyaudio numpy
IF %ERRORLEVEL% NEQ 0 (
    ECHO [WARNING] Prvni pokus selhal, zkousim znovu...
    python -m pip install --only-binary=all pyaudio numpy wheel
)

ECHO [4/5] Installing dependencies from requirements.txt...
python -m pip install -r requirements.txt --no-warn-script-location
IF %ERRORLEVEL% NEQ 0 (
    ECHO [WARNING] Nektere balicky selhaly, zkousim jednotlive...
    python -m pip install --only-binary=all pillow requests beautifulsoup4 google-generativeai google-genai keyboard
)

ECHO [5/5] Installing Playwright + Chromium...
python -m playwright install chromium
IF %ERRORLEVEL% NEQ 0 (
    ECHO [WARNING] Playwright selhal, zkousim s pip...
    python -m pip install playwright
    python -m playwright install chromium
)

ECHO.
ECHO ======================================================
ECHO    Jarvis-MK37 READY - No Admin Required
ECHO ======================================================
ECHO.
ECHO Testing PyAudio...
python -c "import pyaudio; print('[OK] PyAudio:', pyaudio.get_portaudio_version_text())" 2>NUL
IF %ERRORLEVEL% NEQ 0 ECHO [WARNING] PyAudio neni k dispozici
ECHO Testing numpy...
python -c "import numpy; print('[OK] numpy:', numpy.__version__)" 2>NUL
IF %ERRORLEVEL% NEQ 0 ECHO [WARNING] numpy neni k dispozici
ECHO.
ECHO Spoustim Jarvis-MK37...
TIMEOUT /T 2 /NOBREAK >NUL

:LAUNCH
CLS
ECHO [LAUNCH] python main.py
ECHO.
python main.py

ECHO.
ECHO ======================================================
ECHO    Jarvis-MK37 ukoncen
ECHO ======================================================
ECHO.
ECHO [R] - Restart
ECHO [X] - Konec
ECHO.
SET /P choice="Volba: "
IF /I "%choice%"=="R" GOTO LAUNCH

ECHO [DONE] Hotovo.
PAUSE
