@echo off
REM Copyright 2014 Avetti.com Corporation
REM setup-step3.bat
echo  Avetti Commerce Installation Script (Step 3 of 6)
echo  Configuring Apache Web server...
echo.
IF "%1"=="" GOTO USAGE
verify >nul
SET driveLetter=%cd:~0,1%
SET oldpwd=%CD%
SET servername=%1
SET httpdpath=

FOR /F "tokens=1,2,3 delims=." %%a in ("%servername%") do SET serverdomain=%%b.%%c

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

\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#ServerName %servername%:80" --replace "ServerName %servername%:80"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#LoadModule proxy_module modules/mod_proxy.so" --replace "LoadModule proxy_module modules/mod_proxy.so"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#LoadModule proxy_http_module modules/mod_proxy_http.so" --replace "LoadModule proxy_http_module modules/mod_proxy_http.so"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#LoadModule proxy_ajp_module modules/mod_proxy_ajp.so" --replace "LoadModule proxy_ajp_module modules/mod_proxy_ajp.so"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#LoadModule proxy_connect_module modules/mod_proxy_connect.so" --replace "LoadModule proxy_connect_module modules/mod_proxy_connect.so"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#LoadModule proxy_balancer_module modules/mod_proxy_balancer.so" --replace "LoadModule proxy_balancer_module modules/mod_proxy_balancer.so"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#LoadModule rewrite_module modules/mod_rewrite.so" --replace "LoadModule rewrite_module modules/mod_rewrite.so"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#LoadModule ssl_module modules/mod_ssl.so" --replace "LoadModule ssl_module modules/mod_ssl.so"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf" --fileMask "httpd.conf" --caseSensitive --find "#Include conf/extra/httpd-ssl.conf" --replace "Include conf/extra/httpd-ssl.conf"
echo Include conf/extra/avetti.conf >> httpd.conf

cd extra
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf\extra" --fileMask "httpd-ssl.conf" --caseSensitive --find "server.crt" --replace "temporary.crt"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf\extra" --fileMask "httpd-ssl.conf" --caseSensitive --find "server.key" --replace "temporary.nopass.key"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf\extra" --fileMask "httpd-ssl.conf" --caseSensitive --find "shmcb:C:/Program Files (x86)/Apache Software Foundation/Apache2.2/logs/ssl_scache(512000)" --replace "shmcb:%driveLetter%:/avetti/httpd-conf/ssl_scache(512000)"

IF NOT %driveLetter% == C (
\avetti\scripts\fnr.exe --cl --dir "%driveLetter%\avetti\tomcat\conf\Catalina\localhost" --fileMask "solr-*.xml" --caseSensitive --find "C:/avetti" --replace "%driveLetter%:/avetti"
)

\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf\extra" --fileMask "httpd-vhosts.conf" --caseSensitive --find "c8prod1.yourdomain.com" --replace "%servername%"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf\extra" --fileMask "httpd-vhosts.conf" --caseSensitive --find "yourdomain.com" --replace "%serverdomain%"
\avetti\scripts\fnr.exe --cl --dir "%httpdpath%\conf\extra" --fileMask "httpd-vhosts.conf" --caseSensitive --find "httpdpath" --replace "%httpdpath%"

cd %oldpwd%
IF %errorlevel% neq 0 exit /b %errorlevel%
echo "Step 3 Complete"

GOTO END

:USAGE

echo  USAGE: Enter the hostname of this server.
echo   For example:
echo    setup-step3.bat c8prod1.yourdomain.com
exit /B 1
:END

