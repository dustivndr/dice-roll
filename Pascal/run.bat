@echo off
cls
echo Building Pascal...

rem Assumes 'fpc' (Free Pascal Compiler) is in your PATH
fpc dice.pas

if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b
)

cls
echo Running...
dice.exe
echo.
pause