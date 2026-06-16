@echo off
REM ====================================================================
REM  Command-line build for the Mini-IDE (Delphi XE8 / RAD Studio 16.0)
REM
REM  Usage:   build.bat [Release|Debug]   (default: Release)
REM
REM  Requires RAD Studio. The script calls rsvars.bat to set up the
REM  Delphi MSBuild environment, then builds Project1.dproj for Win32.
REM ====================================================================

setlocal

set "RSVARS=%ProgramFiles(x86)%\Embarcadero\Studio\16.0\bin\rsvars.bat"
if not exist "%RSVARS%" (
  echo.
  echo   Could not find rsvars.bat at:
  echo     "%RSVARS%"
  echo.
  echo   Edit build.bat and point RSVARS at your RAD Studio "bin\rsvars.bat".
  exit /b 1
)
call "%RSVARS%"

set "CONFIG=%~1"
if "%CONFIG%"=="" set "CONFIG=Release"

echo.
echo   Building Project1.dproj  (Config=%CONFIG%, Platform=Win32)...
echo.
msbuild Project1.dproj /t:Build /p:Config=%CONFIG% /p:Platform=Win32
exit /b %errorlevel%
