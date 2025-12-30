@echo off

rem Build all Java sources under src and run Main, forwarding args

pushd "%~dp0" || exit /b 1

setlocal enabledelayedexpansion

if not exist out mkdir out

set "SOURCES="

for /r "%~dp0src" %%f in (*.java) do (
  set SOURCES=!SOURCES! "%%~f"
)

if "!SOURCES!"=="" (
  echo No Java source files found under src.
  endlocal
  popd
  exit /b 1
)

echo Compiling Java sources: !SOURCES!
javac -d out !SOURCES!
if errorlevel 1 (
  echo Compilation failed.
  endlocal
  popd
  exit /b 1
)

echo Running Dice...
java -cp out Dice %*
echo.

pause

endlocal
popd
