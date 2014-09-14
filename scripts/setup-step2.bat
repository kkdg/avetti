@echo off
REM Copyright 2014 Avetti.com Corporation
REM setup-step2.bat

echo  Avetti Commerce Installation Script (Step 2 of 6)
echo  Configuring Apache Web Server.
echo.
verify >nul
SET oldpwd=%CD%
SET httpdpath=

IF EXIST "C:\Program Files (x86)\Apache Software Foundation\Apache2.2" (
	SET "httpdpath=C:\Program Files (x86)\Apache Software Foundation\Apache2.2"
)
IF EXIST "C:\Program Files\Apache Software Foundation\Apache2.2" (
	SET "httpdpath=C:\Program Files\Apache Software Foundation\Apache2.2"
)
IF NOT DEFINED httpdpath (
	ECHO Apache Installation path was not found.
	SET /P httpdpath="Please enter the Apache Installation path:"
)

cd %httpdpath%\conf

IF %errorlevel% neq 0 exit /b %errorlevel%

xcopy  /S \avetti\httpd-conf\php "%httpdpath%\"

copy  \avetti\httpd-conf\conf\*.crt "%httpdpath%\conf\"
copy  \avetti\httpd-conf\conf\*.key "%httpdpath%\conf\"
copy  \avetti\httpd-conf\conf\*.txt "%httpdpath%\conf\"

copy \avetti\httpd-conf\conf\extra\avetti.conf  "%httpdpath%\conf\extra\"


erase "%httpdpath%\conf\extra\httpd-vhosts.conf"
copy \avetti\httpd-conf\conf\extra\httpd-vhosts.conf  "%httpdpath%\conf\extra\"

cd %oldpwd%
IF %errorlevel% neq 0 exit /b %errorlevel%
echo Step 2 Complete

:END

