@ECHO OFF
TITLE Mark-XXXIX Launcher
COLOR 0A
MODE CON: COLS=80 LINES=20

:: Zkusit najít Mark-XXXIX ve více umístěních
SET "TARGET1=%USERPROFILE%\Mark-XXXIX"
SET "TARGET2=%USERPROFILE%\mark-xxxix"
SET "TARGET3=C:\Mark-XXXIX"
SET "TARGET4=%CD%"

SET "FOUND="
FOR %%T IN ("%TARGET1%" "%TARGET2%" "%TARGET3%") DO (
    IF EXIST "%%~T\main.py" SET "FOUND=%%~T"
)

IF NOT DEFINED FOUND (
    ECHO [ERROR] Mark-XXXIX nenalezen!
    ECHO Hledal jsem v:
    ECHO   %TARGET1%
    ECHO   %TARGET2%
    ECHO   %TARGET3%
    ECHO.
    ECHO Kam jsi to rozbalil? Dej sem cestu...
    SET /P "MANUAL_PATH=Zadej cestu: "
    IF EXIST "%MANUAL_PATH%\main.py" (
        SET "FOUND=%MANUAL_PATH%"
    ) ELSE (
        ECHO [ERROR] Ani tam to neni!
        PAUSE
        EXIT /B 1
    )
)

CD /D "%FOUND%"
ECHO [OK] Cesta: %CD%

:: Zkusit najít Python 3.11 lokálně
SET "PYTHON_PATH=%FOUND%\python311\python.exe"
IF EXIST "%PYTHON_PATH%" (
    SET "PATH=%FOUND%\python311;%FOUND%\python311\Scripts;%PATH%"
    GOTO RUN
)

:: Zkusit normální python
WHERE python >NUL 2>NUL
IF %ERRORLEVEL% EQU 0 (
    GOTO RUN
)

:: Zkusit python.exe z PATH
FOR %%P IN (python python3 py) DO (
    WHERE %%P >NUL 2>NUL
    IF %ERRORLEVEL% EQU 0 (
        SET "PYTHON_CMD=%%P"
        GOTO RUN
    )
)

ECHO [ERROR] Python nenalezen! Spust nejdriv Mark-XXXIX-Setup.bat
PAUSE
EXIT /B 1

:RUN
CLS
ECHO ========================================
ECHO      Mark-XXXIX Framework
ECHO ========================================
ECHO.
ECHO [OK] Python:
python --version
ECHO.

:LAUNCH
ECHO ========================================
ECHO      Spoustim Mark-XXXIX...
ECHO ========================================
ECHO.
python main.py

ECHO.
ECHO ========================================
ECHO    Mark-XXXIX ukoncen
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
