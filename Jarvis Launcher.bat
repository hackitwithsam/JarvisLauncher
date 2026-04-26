@ECHO OFF
TITLE Jarvis-MK37 Launcher
COLOR 0A
MODE CON: COLS=80 LINES=20

CD /D "%USERPROFILE%\Jarvis-MK37"

IF NOT EXIST "main.py" (
    ECHO [ERROR] Jarvis-MK37 nenalezen v %USERPROFILE%\Jarvis-MK37
    ECHO Nejdriv spust setup.bat
    PAUSE
    EXIT /B 1
)

ECHO ========================================
ECHO       Jarvis-MK37 Launcher
ECHO ========================================
ECHO.
ECHO [OK] Cesta: %CD%
ECHO.

:LAUNCH
CLS
ECHO ========================================
ECHO       Jarvis-MK37
ECHO ========================================
ECHO.
python main.py

ECHO.
ECHO ========================================
ECHO    Jarvis-MK37 ukoncen
ECHO ========================================
ECHO.
ECHO [R] - Restartovat
ECHO [X] - Ukoncit
ECHO.
SET /P choice="Volba: "
IF /I "%choice%"=="R" GOTO LAUNCH

ECHO.
ECHO [DONE] Stiskni libovolnou klavesu...
PAUSE