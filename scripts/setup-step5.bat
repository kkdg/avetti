@echo off
REM Copyright 2014 Avetti.com Corporation
REM setLocal EnableDelayedExpansion
REM setup-step5.bat
echo  Avetti Commerce Installation Script (step 5 of 6)
echo  "Install Databases and Avetti Commerce..."
echo.

IF "%1"=="" GOTO USAGE
verify >nul
SET drive=%cd:~0,3%
SET oldpwd=%CD%
SET servername=%1
SET your_mysql_user_password=%2
SET version_to_install=%3
SET codeNum=%version_to_install%

echo "This step will take up to 10 minutes... please wait"
echo .


:LOOP
For /f "tokens=1* delims=/" %%a in ("%codeNum%") do (
SET codeNum=%%a
SET comp=%%b
)
IF NOT "%comp%" == "" ( 
set codeNum=%comp%
GOTO LOOP
)

for /F "tokens=1,2,3 delims=." %%a in ("%hostname%") do SET serverdomain=%%b.%%c


cd \avetti\svn
if exist settings.xml del settings.xml
copy settings-original.xml settings.xml
\avetti\scripts\fnr.exe --cl --dir "%drive%avetti\svn" --fileMask "settings.xml" --caseSensitive --find "mysql.password" --replace "%your_mysql_user_password%"
\avetti\scripts\fnr.exe --cl --dir "%drive%avetti\svn" --fileMask "settings.xml" --caseSensitive --find "c8prod1.yourdomain.com" --replace "%servername%"


cd %codeNum%
IF %errorlevel% neq 0 exit /B %errorlevel%

if not exist %homepath%\.m2 mkdir %homepath%\.m2
if not exist %homepath%\.m2\repository mkdir %homepath%\.m2\repository
xcopy  /s /c /q /y \avetti\svn\repository %homepath%\.m2\repository

verify >nul
CALL \avetti\mvn\bin\mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -s \avetti\svn\settings.xml avetti:module:setup
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -s \avetti\svn\settings.xml avetti:module:setup
	) ELSE (
	exit /B %errorlevel%
	)	
)

verify >nul
CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:dbmigrator -Psetup-db-preview
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:dbmigrator -Psetup-db-preview
	) ELSE (
	exit /B %errorlevel%
	)	
)

verify >nul
CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:dbmigrator -Psetup-db-shop
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:dbmigrator -Psetup-db-shop
	) ELSE (
	exit /B %errorlevel%
	)	
)

verify >nul
CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:dbmigrator -Psetup-db-backup
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:dbmigrator -Psetup-db-backup
	) ELSE (
	exit /B %errorlevel%
	)	
)

verify >nul
CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:module:deploy -Ppreview clean compile war:exploded
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:module:deploy -Ppreview clean compile war:exploded
	) ELSE (
	exit /B %errorlevel%
	)	
)

verify >nul
CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:module:deploy -Pshop clean compile war:exploded
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:module:deploy -Pshop clean compile war:exploded
	) ELSE (
	exit /B %errorlevel%
	)	
)

verify >nul
CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview
	) ELSE (
	exit /B %errorlevel%
	)	
)

verify >nul
CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop
IF %errorlevel% neq 0 (
	IF %errorlevel% equ 2 (
		CALL \avetti\mvn\bin\mvn -s \avetti\svn\settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop
	) ELSE (
	exit /B %errorlevel%
	)	
)

for /f "delims=/" %%A in ('findstr project.core \avetti\svn\%codeNum%\pom.xml') do ( set var=%%A
set "codeCore=%var:*>=%" )

copy \avetti\svn\%codeCore%\src\site\resources\solr\items-core\conf\*.xml \avetti\solr46\preview-solr\items\conf\
copy \avetti\svn\%codeCore%\src\site\resources\solr\categories-core\conf\*.xml \avetti\solr46\preview-solr\categories\conf\
copy \avetti\svn\%codeCore%\src\site\resources\solr\items-core\conf\*.xml \avetti\solr46\shop-solr\items\conf\
copy \avetti\svn\%codeCore%\src\site\resources\solr\categories-core\conf\*.xml \avetti\solr46\shop-solr\categories\conf\

verify >nul
\avetti\scripts\fnr.exe --cl --dir "%drive%avetti\tomcat\conf\Catalina\localhost" --fileMask "*.xml" --caseSensitive --find "mysql.password" --replace "%your_mysql_user_password%"

copy \avetti\tomcat\conf\Catalina\localhost\preview.xml \avetti\tomcat\webapps\preview\META-INF\context.xml
copy \avetti\tomcat\conf\Catalina\localhost\ROOT.xml \avetti\tomcat\webapps\ROOT\META-INF\context.xml

mysql -uavetti -p%your_mysql_user_password% -e "UPDATE preview.domain_alias SET domain_alias='%servername%' WHERE default_domain=1;"
mysql -uavetti -p%your_mysql_user_password% -e "UPDATE preview.domain_alias SET vendor_suffix='espanol' WHERE domain_settings='tpt=desktop_es';"
mysql -uavetti -p%your_mysql_user_password% -e "UPDATE preview.domain_alias SET domain_alias='%servername%' WHERE domain_settings='tpt=desktop_es';"
mysql -uavetti -p%your_mysql_user_password% -e "DELETE FROM preview.logs;"

mysql -uavetti -p%your_mysql_user_password% -e "UPDATE shop.domain_alias SET domain_alias='%servername%' WHERE default_domain=1;"
mysql -uavetti -p%your_mysql_user_password% -e "UPDATE shop.domain_alias SET vendor_suffix='espanol' WHERE domain_settings='tpt=desktop_es';"
mysql -uavetti -p%your_mysql_user_password% -e "UPDATE shop.domain_alias SET domain_alias='%servername%' WHERE domain_settings='tpt=desktop_es';"
mysql -uavetti -p%your_mysql_user_password% -e "DELETE FROM shop.logs;"

IF %errorlevel% neq 0 exit /B %errorlevel%
echo "Step 5 Complete"
cd %oldpwd%

set CATALINA_HOME=%drive%avetti\tomcat
set CATALINA_BASE=%drive%avetti\tomcat
IF NOT "%CATALINA_HOME%" == "C:\avetti\tomcat" (
\avetti\scripts\fnr.exe --cl --dir "%drive%avetti\tomcat\bin" --fileMask "startup.bat" --caseSensitive --find "CATALINA_HOME=C:\avetti\tomcat" --replace "CATALINA_HOME=%CATALINA_HOME%"
)
net stop apache2.2
net start apache2.2

GOTO END
:USAGE
echo  USAGE: Enter the full domain of this server, your mysql user password and the
echo  latest version # of Avetti Commerce to install.
echo.
echo   For example:
echo    setup-step5.bat c8prod1.yourdomain.com your_mysql_user_password 8.3.8
exit /B 1

:END
