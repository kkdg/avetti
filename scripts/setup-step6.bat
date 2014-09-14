@echo off
REM Copyright 2014 Avetti.com Corporation
REM setup-step6.bat
verify >nul
echo  Avetti Commerce Installation Script (Step 6 of 6)
echo  "Starting Apache and Tomcat..."
echo.
SET drive=%cd:~0,3%
set oldpwd=%cd%
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

set CATALINA_HOME=%drive%avetti\tomcat
set CATALINA_BASE=%drive%avetti\tomcat

REM cd %httpdpath%\bin
REM httpd.exe -k stop 2>nul
REM httpd.exe -k start
net stop apache2.2
net start apache2.2


cd \avetti\tomcat\bin\
taskkill /IM java.exe 2>nul
call startup.bat
cd %oldpwd%

echo  Step 6 Complete

