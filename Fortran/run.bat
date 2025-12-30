@echo off

cls
echo Building...
gfortran main.f90 -o main.exe

if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b
)

cls

echo Running...

cls

main.exe

echo.
pause
