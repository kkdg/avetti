@echo off
REM Copyright 2014 Avetti.com Corporation
REM setup-step4.bat
echo  Avetti Commerce Installation Script (Step 4 of 6)
echo  Downloading Avetti Commerce from SVN...
echo.
IF "%1"=="" GOTO USAGE
verify >nul
SET oldpwd=%CD%
SET drive=%cd:~0,3%
SET version_to_install=%1
SET MAVEN_OPTS=-Xms512m -Xmx700m -XX:PermSize=256M -XX:MaxPermSize=700M
SET M2_HOME=%drive%avetti\mvn
SET M2=%M2_HOME%\bin

SET codeNum=%version_to_install%
:LOOP
For /f "tokens=1* delims=/" %%a in ("%codeNum%") do (
SET codeNum=%%a
SET comp=%%b
)
IF NOT "%comp%" == "" (
set codeNum=%comp%
GOTO LOOP
)

cd \avetti\svn
IF %errorlevel% neq 0 exit /b %errorlevel%
svn checkout --trust-server-cert --non-interactive --no-auth-cache --username=%avettisvnuser% --password=%avettisvnpassword% https://svn.avetticommerce.com/software/avetticommerce/%version_to_install%
svn checkout --trust-server-cert --non-interactive --no-auth-cache --username=avetti-lgpl-access --password=avetti-lgpl-access https://svn.avetticommerce.com/software/LGPL-software
IF NOT EXIST "%codeNum%" (
echo ERROR: %codeNum% does not exist, svn checkout must have failed.
cd %oldpwd%
exit /b 1
)

cd %oldpwd%
echo "Step 4 Complete"

GOTO END
:USAGE
echo  USAGE: Enter the latest version number of Avetti Commerce to install.
echo   For example:
echo    setup-step4.bat 8.3.8
echo.
REM echo The available versions are:";
REM svn ls --no-auth-cache --username=avetti-lgpl-access --password=avetti-lgpl-access --config-dir /home/avetti/.subversion https://svn.avetticommerce.com/software/avetticommerce/commerce8/tags/community | findstr /v core
exit /B 1
:END

