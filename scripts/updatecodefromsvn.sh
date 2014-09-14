#!/bin/bash
# Copyright 2013 Avetti.com Corporation


user=`whoami`

if [ ${user} != "avetti" ]; then
   echo "This must be run as 'avetti' user." 1>&2
   exit 1;
fi
echo "Code and Database Update ..."

code_to_install=`tail -n 1 /avetti/svn/deploy.log | awk '{print $2}' | cut -d',' -f1 |cut -d'/' -f4`

echo -e "Running in this server: $code_to_install"

echo -e "Do you want to continue to update this version? (Y/N)?\a"

read answer2
if [ "$answer2" != "Y" ] && [ "$answer2" != "y" ];
then
{
        if [ "$answer2" != "N" ] && [ "$answer2" != "n" ];
        then
        {
                echo "Unknown answer, exiting..."
                exit 1;
        }
        else
        {
  		echo -e "USAGE:  Enter the Avetti Commerce code to install \nFor example: trunkwithmodules"
		read code_to_install 
	}
	fi
}
fi


if [ $? != 0 ]
then { echo "Error...";
exit 1; }
fi



cd /avetti/svn/${code_to_install}

errCode=$?

if [[ ${errCode} != 0 ]];
then { echo "That code has not been checkout...";
exit 1; }
fi



/avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then /avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup
        else { echo "Error...";
        exit 1; }
        fi
        }
fi


cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview
        else { echo "Error...";
        exit 1; }
        fi
        }
fi


cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop
        else { echo "Error...";
        exit 1; }
        fi
        }
fi

cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup
        else { echo "Error...";
        exit 1; }
        fi
        }
fi


cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded
        else { echo "Error...";
        exit 1; }
        fi
        }
fi

cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded
        else { echo "Error...";
        exit 1; }
        fi
        }
fi


cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview
        else { echo "Error...";
        exit 1; }
        fi
        }
fi

cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop
        else { echo "Error...";
        exit 1; }
        fi
        }
fi

