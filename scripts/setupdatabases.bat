@echo off
REM Copyright 2014 Avetti.com Corporation
REM setupdatabases.bat

SET drive=%cd:~0,3%

echo Avetti Commerce Complete Installation Script
echo Copyright 2014 Avetti.com Corporation
echo .
echo The following script will Setup Preview/Shop/Backup Databases
SET /P ANSWER=Do you want to continue? [Y/N]? 

IF /i {%ANSWER%}=={y} (GOTO :COMPILE)
IF /i {%ANSWER%}=={Y} (GOTO :COMPILE)
IF /i {%ANSWER%}=={n} (GOTO :END)
IF /i {%ANSWER%}=={N} (GOTO :END)
) ELSE ( ECHO Unknown answer, exiting...
exit /b 1
)


:COMPILE

for /f "tokens=2 delims= " %%a in (%drive%avetti\svn\deploy.log) do (
set version_to_install=%%a
)
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

SET codeNum=%codeNum:~0,-1%


echo Running in this server: %codeNum%
SET /P ANSWERcode=Do you want to continue? [Y/N]?


IF /i {%ANSWER%}=={y} (GOTO :COMPILING)
IF /i {%ANSWER%}=={Y} (GOTO :COMPILING)
IF /i {%ANSWER%}=={n} (GOTO :GETCODE)
IF /i {%ANSWER%}=={N} (GOTO :GETCODE)
) ELSE ( ECHO Unknown answer, exiting...
exit /b 1
)


:GETCODE

SET /P codeNum=USAGE:  Enter the Avetti Commerce code to install (for example: trunkwithmodules):
GOTO COMPILING


:COMPILING

cd \avetti\svn
cd %codeNum%

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


:END

