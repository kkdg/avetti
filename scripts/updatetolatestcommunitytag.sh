#!/bin/bash

currentUser=`whoami`

if [ ${currentUser} != avetti ] && [ ${currentUser} != root ];
then	{
	echo "This must be run as 'root' or as 'avetti' user." 1>&2
	exit 1;
	}
fi

currentTag=`ls /avetti/svn | grep Commerce | grep -v core | tail -n 1`
lastTag=`svn ls --trust-server-cert --non-interactive --config-dir /home/avetti/.subversion --no-auth-cache --username=avetti-lgpl-access --password=avetti-lgpl-access https://svn.avetticommerce.com/software/avetticommerce/commerce8/tags/community | grep -v core | tail -n 1 | sed 's/\///'`

if [ $? != 0 ]
then { echo "Error Detected!!";
exit 1; }
fi

echo -e "Current installed tag:	${currentTag}\nLast tag is:	${lastTag}"

if [ -d /avetti/svn/${lastTag} ];
then {
	echo -e "There is a directory with the same name as the latest tag inside your /avetti/svn/ folder.\nThis could be because you are already running the latest tag."
	exit 1;
	}
fi

cd /avetti/svn
svn co --trust-server-cert --non-interactive --no-auth-cache --username=avetti-lgpl-access --password=avetti-lgpl-access https://svn.avetticommerce.com/software/avetticommerce/commerce8/tags/community/${lastTag}

cd /avetti/svn/${lastTag}; 
/avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup
errCode=$?
if [[ ${errCode} != 0 ]];
then    
{
        if [ ${errCode} == 2 ];
        then /avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup
        else { echo "Error Detected!!";
        exit 1; }
        fi
}
fi

chmod -R g+w /avetti/svn/${lastTag}
#chmod -R o+w /avetti/svn/${lastTag}
chown -R avetti:apache /avetti/svn/
cd $OLDPWD

if [ ${currentUser} == root ];
then {
	su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview"
	errCode=$?
	if [ ${errCode} != 0 ];
	then    {
	        if [ ${errCode} == 2 ];
	        then su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview"
		        else { echo "Error...";
		        exit 1; }
	        fi
	        }
	fi

	su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop"
	errCode=$?
	if [ ${errCode} != 0 ];
	then    {
	        if [ ${errCode} == 2 ];
	        then su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop"
	        else { echo "Error...";
		        exit 1; }
	        fi
	        }
	fi

	su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup"
	errCode=$?
	if [ ${errCode} != 0 ];
	then    {
	        if [ ${errCode} == 2 ];
	        then su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup"
	        else { echo "Error...";
	        exit 1; }
	        fi
	        }
	fi

	service tomcat stop
	su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded"
	errCode=$?
	if [ ${errCode} != 0 ];
	then    {
	        if [ ${errCode} == 2 ];
	        then su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded"
	        else { echo "Error...";
	       	exit 1; }
	        fi
	        }
	fi

	su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded"
	errCode=$?
	if [ ${errCode} != 0 ];
	then    {
	        if [ ${errCode} == 2 ];
	        then su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded"
	        else { echo "Error...";
	        exit 1; }
	        fi
	        }
	fi

	su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview"
	errCode=$?
	if [ ${errCode} != 0 ];
	then    {
	        if [ ${errCode} == 2 ];
	        then su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview"
	        else { echo "Error...";
	        exit 1; }
	        fi
	        }
	fi

	su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop"
	errCode=$?
	if [ ${errCode} != 0 ];
	then    {
	        if [ ${errCode} == 2 ];
	        then su - avetti -c "cd /avetti/svn/${lastTag}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop"
	        else { echo "Error...";
	        exit 1; }
	        fi
	        }
	fi
	service tomcat start
	}
else {
	cd /avetti/svn/${lastTag}
	/avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true avetti:module:setup
	errCode=$?
	if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true avetti:module:setup
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi

	/avetti/mvn/bin/mvn avetti:util:dbmigrator -Pupdate-db-preview
	errCode=$?
        if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn avetti:util:dbmigrator -Pupdate-db-preview
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi
	/avetti/mvn/bin/mvn avetti:util:dbmigrator -Pupdate-db-shop
	errCode=$?
        if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn avetti:util:dbmigrator -Pupdate-db-shop
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi
	/avetti/mvn/bin/mvn avetti:util:dbmigrator -Pupdate-db-backup
	errCode=$?
        if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn avetti:util:dbmigrator -Pupdate-db-backup
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi
	sudo service tomcat stop
	/avetti/mvn/bin/mvn avetti:module:deploy -Ppreview clean compile war:exploded
	errCode=$?
        if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn avetti:module:deploy -Ppreview clean compile war:exploded
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi
	/avetti/mvn/bin/mvn avetti:module:deploy -Pshop clean compile war:exploded
	errCode=$?
        if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn avetti:module:deploy -Pshop clean compile war:exploded
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi
	/avetti/mvn/bin/mvn avetti:util:lgpl -Pinstall-lgpl-on-preview
	errCode=$?
        if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn avetti:util:lgpl -Pinstall-lgpl-on-preview
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi
	/avetti/mvn/bin/mvn avetti:util:lgpl -Pinstall-lgpl-on-shop
	errCode=$?
        if [ ${errCode} != 0 ];
        then    {
                if [ ${errCode} == 2 ];
                then /avetti/mvn/bin/mvn avetti:util:lgpl -Pinstall-lgpl-on-shop
                else { echo "Error...";
                exit 1; }
                fi
                }
        fi
	sudo service tomcat start 
	}
fi


