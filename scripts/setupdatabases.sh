Copyright 2013 Avetti.com Corporation


user=`whoami`

if [ ${user} != "avetti" ]; then
   echo "This must be run as 'avetti' user." 1>&2
   exit 1;
fi
echo "Database setup ..."

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


cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-preview
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-preview
        else { echo "Error...";
        exit 1; }
        fi
        }
fi


cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-shop
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-shop
        else { echo "Error...";
        exit 1; }
        fi
        }
fi

cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-backup
errCode=$?
if [[ ${errCode} != 0 ]];
then    {
        if [[ ${errCode} == 2 ]];
        then cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-backup
        else { echo "Error...";
        exit 1; }
        fi
        }
fi

