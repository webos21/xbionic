@echo off
rem # -------------------------------------------------------------------------
rem #  Set up the Build Environment for Windows
rem # -------------------------------------------------------------------------

@if not "%ECHO%" == ""  echo %ECHO%

if "%OS%" == "Windows_NT" (
  set "DIRNAME=%~dp0%"
) else (
  set DIRNAME=.\
)

rem # Read an optional configuration file.
if "x%BUILD_CONF%" == "x" (
   set "BUILD_CONF=%DIRNAME%build.conf.bat"
)
if exist "%BUILD_CONF%" (
   echo Calling "%BUILD_CONF%"
   call "%BUILD_CONF%" %*
) else (
   echo Config file not found "%BUILD_CONF%"
)

rem # Set the Build Path
set PATH=%BUILD_TOOLCHANIN_BIN%;%MAKE_COMMAND_BIN%;%POSIX_COMMAND_BIN%;%PATH%

rem # Notice the 'MAKE' commands
@echo.
@echo "Use the 'mingw32-make' command instead of 'make'"
@echo.

rem # Start the command-shel
cmd /K cd %CD%
