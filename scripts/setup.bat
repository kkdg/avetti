@echo off
REM Copyright 2014 Avetti.com Corporation
REM setup.bat

echo  Avetti Commerce Complete Installation Script
echo  Copyright 2014 Avetti.com Corporation
echo.

IF "%1"=="" GOTO USAGE

SET your_mysql_root_password=%1
SET apphostname=localhost
SET your_mysql_avetti_user_password=%your_mysql_root_password%

echo Detecting permissions...
net session >nul 2>&1
if %errorLevel% == 0 (
	echo Permissions OK
) else (
	echo ERROR: Administrative permissions required.
	exit /b 1
)

echo This script will install Avetti Commerce Using the following parameters:
echo MySQL root password: %1
setlocal EnableDelayedExpansion
IF "%2" == "" (
SET your_mysql_avetti_user_password=%1
SET apphostname=localhost
)
IF NOT "%2"=="" IF "%3" == "" (
SET your_mysql_avetti_user_password=%1
SET apphostname=%2
)
IF NOT "%3"=="" (
SET your_mysql_avetti_user_password=%2
SET apphostname=%3
)
SET your_mysql_avetti_user_password=!your_mysql_avetti_user_password!
SET apphostname=!apphostname!
echo Your MySQL 'avetti' user's password: %your_mysql_avetti_user_password%
echo Hostname: %apphostname%

SET /P useParam=Do you want to use these parameters? [Y/N]?
IF NOT "%useParam%" == "y" (
	IF NOT "%useParam%" == "Y" (
		echo Exiting per user's request...
		exit /b 0
	)
)

SET version_to_install=commerce8.5/tags/enterprise/Commerce8.5.2-enterprise
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

echo The following script will install Avetti Commerce code from %version_to_install%
SET /P ANSWER=Do you want to continue installing this %codeNum% version? [Y/N]?


IF /i {%ANSWER%}=={y} (GOTO :YES)
IF /i {%ANSWER%}=={Y} (GOTO :YES)
IF /i {%ANSWER%}=={n} (GOTO :NO)
IF /i {%ANSWER%}=={N} (GOTO :NO
) ELSE ( ECHO Unknown answer, exiting...
exit /b 1
)


:YES 

SET /P svnuser=Please enter your SVN user:
SET /P svnpassword=Enter your SVN password:
echo Verifying svn credentials...

svn --version >nul

IF %errorlevel% neq 0 (
echo  Please install Subversion and add the binaries folder to you PATH.
exit /b 1
)

svn info --no-auth-cache --trust-server-cert --non-interactive --username=%svnuser% --password=%svnpassword% https://svn.avetticommerce.com/software/avetticommerce/%version_to_install% >nul

IF %errorlevel% neq 0 (
echo  ERROR: You are not authorized to download https://svn.avetticommerce.com/software/avetticommerce/%version_to_install% version.
echo  Please check your input and run the setup.sh script again.
exit /b 1
)

GOTO CONTINUE


:NO

SET /P diffcode=Please enter the desired code path to install (relative path):
echo Verifying path...
SET /P avettisvnuser=Please enter your SVN user:
SET /P avettisvnpassword=Enter your SVN password:

svn --version >nul

IF %errorlevel% neq 0 (
echo  Please install Subversion and add the binaries folder to you PATH.
exit /b 1
)

svn info --no-auth-cache --trust-server-cert --non-interactive --username=%avettisvnuser% --password=%avettisvnpassword% https://svn.avetticommerce.com/software/avetticommerce/%diffcode% >nul

IF %errorlevel% neq 0 (
echo  ERROR: You are not authorized to download https://svn.avetticommerce.com/software/avetticommerce/%version_to_install% version.
echo  Please check your input and run the setup.sh script again.
exit /b 1
) else (
SET version_to_install=%diffcode%
) 

GOTO CONTINUE


:CONTINUE

verify >nul
CALL setup-step1.bat %your_mysql_root_password% %your_mysql_avetti_user_password%
IF %errorlevel% neq 0 exit /b %errorlevel%
CALL setup-step2.bat
IF %errorlevel% neq 0 exit /b %errorlevel%
CALL setup-step3.bat %apphostname% %version_to_install%
IF %errorlevel% neq 0 exit /b %errorlevel%
CALL setup-step4.bat %version_to_install% %avettisvnuser% %avettisvnpassword%
IF %errorlevel% neq 0 exit /b %errorlevel%
CALL setup-step5.bat %apphostname% %your_mysql_avetti_user_password% %version_to_install%
IF %errorlevel% neq 0 exit /b %errorlevel%

echo ********************************************************************************
echo *
echo *   Congratuations!!  Avetti Comerce  is now installed
echo *
echo *   To view the store run:
echo.
echo     cd \avetti\tomcat\bin\
echo	 startup.bat
echo	 (Ensure that Apache is running)
echo.
echo When the output shows a Server Started line for both the preview and ROOT (shop)
echo applications or a splash page advising that the application is loaded then you
echo can login to the preview store using:
echo.
echo https://%apphostname%/preview/login.admin
echo.
echo To Stop Tomcat run:
echo.
echo      taskkill /IM java.exe
echo.
echo *
echo *
echo ********************************************************************************
echo.

GOTO END

:USAGE
echo Avetti Commerce  Setup Script.
echo Copyright 2014 Avetti.com Corporation
echo.
echo Installs Avetti Commerce, tomcat and all software required for  a complete server setup.
echo. 
echo USAGE:  setup.bat your_mysql_root_password [your_mysql_avetti_user_password] [c8prod1.yourdomain.com]
echo. 
echo EXAMPLE:
echo. 
echo On Windows use:
echo. 
echo setup.bat  your_mysql_root_password
echo. 
echo PARAMETERS:
echo your_mysql_root_password:             your existing mysql root password or the password to set for root for new installs
echo your_mysql_avetti_user_password:      the password to set for the 'avetti' user in  mysql.  The Root password is used by default
echo c8prod1.yourdomain.com                the server domain name of your server.  default to localhost if not specified
echo. 
echo For more information read the  Avetti Commerce 8 Setup Guide pdf within this zip file.
echo Visit our forum at http://avetticommerce.com/support  or email ecommerce@avetti.com
echo. 

:END


