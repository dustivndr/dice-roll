@echo off

cls
echo Building...
g++ *.cpp -o main.exe

if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b
)

cls

echo Running...

main.exe

echo.
pause
