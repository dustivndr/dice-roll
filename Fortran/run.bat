@REM @echo off

@REM cls
@REM echo Building...
@REM gfortran main.f90 -o main.exe

@REM if %errorlevel% neq 0 (
@REM     echo Build failed!
@REM     pause
@REM     exit /b
@REM )

@REM cls

@REM echo Running...

@REM cls

@REM main.exe

@REM echo.
@REM pause

@echo off

cls
echo Building C wrapper...
gcc -c getch_wrapper.c -o getch_wrapper.o

if %errorlevel% neq 0 (
    echo C build failed!
    pause
    exit /b
)

echo Creating library...
ar rcs libgetch.a getch_wrapper.o

if %errorlevel% neq 0 (
    echo Library creation failed!
    pause
    exit /b
)

echo Building Fortran program...
gfortran main.f90 libgetch.a -o main.exe

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