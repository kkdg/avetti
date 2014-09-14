@echo off
REM Copyright 2014 Avetti.com Corporation
REM setup-step1.bat

echo  Avetti Commerce Installation Script (Step 1 of 6)
echo  Creating mysql user for MySQL.
echo.
IF "%1"=="" GOTO USAGE
rem IF "%2"=="" GOTO USAGE
verify >nul

SET your_mysql_root_password=%1
SET your_mysql_avetti_user_password=%2
IF NOT DEFINED JAVA_HOME (
echo  Please Install Java Development Kit and add the "JAVA_HOME" variable.
EXIT /B 1
)

IF NOT EXIST "%JAVA_HOME%/bin/javac.exe" (
echo ERROR: JAVA_HOME must point to a Java Development Kit installation.
cd %oldpwd%
exit /b 1
)

verify >nul
mysql -V >nul
IF %ERRORLEVEL% neq 0 (
ECHO  Please install MySQL and add the binaries folder to you PATH.
EXIT /B 1
)

echo  Running Mysql client to add a mysql user...
verify >nul
mysql -uroot -p%your_mysql_root_password% -e "GRANT ALL PRIVILEGES ON *.* TO 'avetti'@'localhost' IDENTIFIED BY '%your_mysql_avetti_user_password%';"

IF %errorlevel% neq 0 exit /b %errorlevel%
echo  Step 1 Complete

GOTO END

:USAGE
echo  USAGE: Enter the the MySQL root password and the mysql user password
echo  to be set for this MySQL installation.
echo.
echo   For example:  
echo    setup-step1.bat your_mysql_root_password your_mysql_avetti_user_password
EXIT /B 1

:END

