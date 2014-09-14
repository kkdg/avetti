#!/bin/bash
# Copyright 2014 Avetti.com Corporation
# setup.sh
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as 'root'." 1>&2
   exit 1;
fi
path_to_code=commerce8.5/tags/enterprise/Commerce8.5.2-enterprise
code_to_install=`echo $path_to_code | rev | cut -d'/' -f1 | rev`
mysqlHost=localhost
mysqlPort=3306
logFile=/avetti/scripts/setup.log

## Adding error function
errorFound() {
echo -e "Errors detected.." | tee -a ${logFile}
exit 1;
}

## Adding function to install MySQL
installMysql() {
echo -e "-- Installing MySQL"  | tee -a ${logFile}
if [[ -e "/usr/bin/yum" ]] || [[ -e "/bin/yum" ]]
then
{
	echo -e "Running: yum install -y mysql-server" >>${logFile}
	yum install -y mysql-server | tee -a ${logFile}
	service mysqld start | tee -a ${logFile}
	chkconfig mysqld on | tee -a ${logFile}
}
elif [ -e "/usr/bin/apt-get" ];
then
{
	export DEBIAN_FRONTEND=noninteractive
	echo -e "Running: apt-get update" >>${logFile}
	apt-get update
	echo -e "Running: apt-get install -y -q mysql-server" >>${logFile}
	apt-get install -y -q mysql-server  | tee -a ${logFile}
	if [[ `service mysql status | grep 'running'` == '' ]];
	then
	{
		if [[ ! -e /sbin/insserv ]];
		then
		{
			ln -s /usr/lib/insserv/insserv /sbin/insserv
		}
		fi
	service mysql start | tee -a ${logFile}
	}
	fi
}
fi
}

## Adding function to install Java
installJava() {
echo -e "-- Installing Java Development Kit"  | tee -a ${logFile}
if [[ -e "/usr/bin/yum" ]] || [[ -e "/bin/yum" ]]
then
{
	echo -e "Running: yum install -y java-1.7.0-openjdk-devel" >>${logFile}
	yum install -y java-1.7.0-openjdk-devel | tee -a ${logFile}
	if  [ "${JAVA_HOME}"=="" ]
	then
	{
		export JAVA_HOME=/usr/lib/jvm/java-1.7.0
		echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0" >>/etc/profile
	}
	else
	{
		echo -e "JAVA_HOME already exist:\t${JAVA_HOME}" >>${logFile}
	}
	fi
}
elif [ -e "/usr/bin/apt-get" ];
then
{
	echo -e "Running: apt-get update" >>${logFile}
	apt-get update
	echo -e "Running: apt-get install -y -q openjdk-7-jdk" >>${logFile}
	apt-get install -y -q openjdk-7-jdk
	if  [ "${JAVA_HOME}"=="" ]
	then
	{
		if [ -e "/usr/lib/jvm/java-7-openjdk" ]
		then
		{
			export JAVA_HOME=/usr/lib/jvm/java-7-openjdk
			echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk" >>/etc/profile
		}
		elif [ -e "/usr/lib/jvm/java-7-openjdk-i386" ]
		then
		{
			export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386
			echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386" >>/etc/profile
		}
		else
		{
			export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
			echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >>/etc/profile
		}
		fi
	}
	else
	{
		echo -e "JAVA_HOME already exist:\t${JAVA_HOME}" >>${logFile}
	}       
	fi
}
fi
}

## Adding function to install apache web server
installHttpd() {
umask 002
echo "-- Installing Apache 2.2.26...  in the avetti dir" | tee -a ${logFile}
cd /avetti
tar -zxvf httpd-2.2.26.tar.gz >/dev/null
cd httpd-2.2.26
echo -e "Running: ./configure --prefix=/avetti/httpd --sbindir=/avetti/httpd/bin --enable-mods-shared=all --enable-proxy  --enable-ssl" >>${logFile}
./configure --prefix=/avetti/httpd --sbindir=/avetti/httpd/bin --enable-mods-shared=all --enable-proxy  --enable-ssl | tee -a ${logFile}
if [ $? != 0 ]
then 
{
	echo "Error compiling httpd" | tee -a ${logFile}
	exit 1;
 }
fi

make | tee -a ${logFile}
if [ $? != 0 ]
then
{
	echo "Error running \"make\".." | tee -a ${logFile}
	exit 1;
}
fi

make install | tee -a ${logFile}
if [ $? != 0 ]
then
{
	echo "Error running \"make install\""
	exit 1;
}
fi

cat >/etc/init.d/httpd <<"EOF"
#
# Startup script for the Apache Web Server
#
# chkconfig: - 85 15
# description: Apache is a World Wide Web server. It is used to serve
# HTML files and CGI.
# processname: httpd
# pidfile: /avetti/httpd/logs/httpd.pid
# config: /avetti/httpd/conf/httpd.conf
EOF
cat /avetti/httpd/bin/apachectl >>/etc/init.d/httpd
chmod +x /etc/init.d/httpd
if [ $? != 0 ]
then
{
	echo "Error creating /etc/init.d/httpd"
	exit 1;
}
fi
}

## Adding function to configure MySQL
configureMysql() {
echo -e "-- Configuring MySQL" | tee -a ${logFile}
if [[ "${addMysql}" != "nomysql" ]] && [[ "${mysqlRootPwd}" != "" ]]
then
{
	mysqladmin -uroot password ${mysqlRootPwd} | tee -a ${logFile}
}
fi
if [[ "${mysqlHost}" == "localhost" ]] && [[ "${mysqlRootPwd}" != "" ]]
then
{
	mysql -uroot -p${mysqlRootPwd} -h ${mysqlHost} -P ${mysqlPort} -e "GRANT ALL PRIVILEGES ON preview.* TO 'avetti'@'localhost' identified by '$mysqlAvettiPwd';"
	mysql -uroot -p${mysqlRootPwd} -h ${mysqlHost} -P ${mysqlPort} -e "GRANT ALL PRIVILEGES ON shop.* TO 'avetti'@'localhost' identified by '$mysqlAvettiPwd';"
	mysql -uroot -p${mysqlRootPwd} -h ${mysqlHost} -P ${mysqlPort} -e "GRANT ALL PRIVILEGES ON backup.* TO 'avetti'@'localhost' identified by '$mysqlAvettiPwd';"
}
elif [[ "${mysqlHost}" == "localhost" ]] && [[ "${mysqlRootPwd}" == "" ]]
then
{
	mysql -uroot -h ${mysqlHost} -P ${mysqlPort} -e "GRANT ALL PRIVILEGES ON preview.* TO 'avetti'@'localhost' identified by '$mysqlAvettiPwd';"
	mysql -uroot -h ${mysqlHost} -P ${mysqlPort} -e "GRANT ALL PRIVILEGES ON shop.* TO 'avetti'@'localhost' identified by '$mysqlAvettiPwd';"
	mysql -uroot -h ${mysqlHost} -P ${mysqlPort} -e "GRANT ALL PRIVILEGES ON backup.* TO 'avetti'@'localhost' identified by '$mysqlAvettiPwd';"
}
elif [[ "${mysqlHost}" != "localhost" ]] && [[ "${mysqlRootPwd}" != "" ]]
then
{
	mysql -uroot -p${mysqlRootPwd} -h${mysqlHost} -P${mysqlPort} -e "GRANT ALL PRIVILEGES ON preview.* TO 'avetti'@'%' identified by '$mysqlAvettiPwd';"
	mysql -uroot -p${mysqlRootPwd} -h${mysqlHost} -P${mysqlPort} -e "GRANT ALL PRIVILEGES ON shop.* TO 'avetti'@'%' identified by '$mysqlAvettiPwd';"
	mysql -uroot -p${mysqlRootPwd} -h${mysqlHost} -P${mysqlPort} -e "GRANT ALL PRIVILEGES ON backup.* TO 'avetti'@'%' identified by '$mysqlAvettiPwd';"
}
elif [[ "${mysqlHost}" != "localhost" ]] && [[ "${mysqlRootPwd}" == "" ]]
then
{
	mysql -uroot -h${mysqlHost} -P${mysqlPort} -e "GRANT ALL PRIVILEGES ON preview.* TO 'avetti'@'%' identified by '$mysqlAvettiPwd';"
	mysql -uroot -h${mysqlHost} -P${mysqlPort} -e "GRANT ALL PRIVILEGES ON shop.* TO 'avetti'@'%' identified by '$mysqlAvettiPwd';"
	mysql -uroot -h${mysqlHost} -P${mysqlPort} -e "GRANT ALL PRIVILEGES ON backup.* TO 'avetti'@'%' identified by '$mysqlAvettiPwd';"
}
fi
}

## Adding function to configure apache
configureHttpd() {
echo -e "-- Configuring Httpd" | tee -a ${logFile}
apacheUser=`grep 'User ' ${httpdPath}/conf/httpd.conf | grep -v '#' | cut -d' ' -f2`
apacheGroup=`grep 'Group ' ${httpdPath}/conf/httpd.conf | cut -d' ' -f2`
if [[ ${apacheUser} != "httpd" ]]
then
{
	sed -i "s/User ${apacheUser}/User httpd/g" ${httpdPath}/conf/httpd.conf
}
fi

if [[ ${apacheGroup} != "apache" ]]
then
{
	sed -i "s/User ${apacheGroup}/Group apache/g" ${httpdPath}/conf/httpd.conf
}
fi

if [[ `grep 'ssl.conf' ${httpdPath}/conf/httpd.conf | grep -v '#'` ]]
then
{
	echo -e "SSL configuration file is already loaded." | tee -a ${logFile}
}
else
{
	sed -i 's/#Include conf\/extra\/httpd-ssl.conf/Include conf\/extra\/httpd-ssl.conf/g' ${httpdPath}/conf/httpd.conf | tee -a ${logFile}
	cp  /avetti/httpd-conf/conf/*.crt ${httpdPath}/conf
	cp  /avetti/httpd-conf/conf/*.key ${httpdPath}/conf
	cp  /avetti/httpd-conf/conf/*.txt ${httpdPath}/conf
	sed -i 's/server.crt/temporary.crt/g' ${httpdPath}/conf/extra/httpd-ssl.conf | tee -a ${logFile}
	sed -i 's/server.key/temporary.nopass.key/g' ${httpdPath}/conf/extra/httpd-ssl.conf | tee -a ${logFile}
}
fi

if ! [[ `grep 'avetti.conf' ${httpdPath}/conf/httpd.conf | grep -v '#'` ]]
then
{
	echo -e "# Including Avetti configuration\nInclude conf/extra/avetti.conf" >>${httpdPath}/conf/httpd.conf | tee -a ${logFile}
	cp /avetti/httpd-conf/conf/extra/avetti.conf  ${httpdPath}/conf/extra/ | tee -a ${logFile}
}
fi
if [[ ${appHostName} != "localhost" ]] && [[ `echo ${appHostName} | cut -d'.' -f4` == "" ]]
then
{
	serverdomain=`echo "${appHostName}" | cut -d'.' -f2-3`
}
else
{
	serverdomain=${appHostName}
}
fi
sed -i "s/#ServerName www.example.com:80/ServerName ${appHostName}:80/g" ${httpdPath}/conf/httpd.conf
if [[ `grep ${appHostName} ${httpdPath}/conf/extra/httpd-vhosts.conf` ]]
then
{
	echo -e "File httpd-vhost.conf appears to be already configured.."
}
else
{
	cp /avetti/httpd-conf/conf/extra/httpd-vhosts.conf  ${httpdPath}/conf/extra/
	sed -i "s/c8prod1.yourdomain.com/${appHostName}/g" ${httpdPath}/conf/extra/httpd-vhosts.conf
	sed -i "s/yourdomain.com/${serverdomain}/g" ${httpdPath}/conf/extra/httpd-vhosts.conf
	sed -i 's/rotatelogs.exe/rotatelogs/g' ${httpdPath}/conf/extra/httpd-vhosts.conf
	httpdPath2="${httpdPath//\//\\/}"
	sed -i "s/httpdpath/${httpdPath2}/g" ${httpdPath}/conf/extra/httpd-vhosts.conf
}
fi

mkdir -p ${httpdPath}/htdocs/content/{shop,preview} | tee -a ${logFile}
chown -R httpd:apache ${httpdPath} | tee -a ${logFile}
}

## Adding function to configure tomcat
configureTomcat() {
echo -e "-- Configuring tomcat..." | tee -a ${logFile}
if [[ -e /etc/init.d/tomcat ]]
then
{
	echo -e "File /etc/init.d/tomcat already exists" | tee -a ${logFile}
}
else
{
	cp /avetti/scripts/tomcat /etc/init.d
	JAVA_HOME2="${JAVA_HOME//\//\\/}"
	sed -i "s/avetti_java_home/$JAVA_HOME2/g" /etc/init.d/tomcat
	cd /avetti/tomcat/bin/commons-daemon-*
	PWD2="${PWD//\//\\/}"
	sed -i "s/avetti_daemon_home/$PWD2/g" /etc/init.d/tomcat
	cd unix
	./configure --with-java=$JAVA_HOME
	make clean
	make
	cp jsvc /avetti/tomcat/bin
	cd $OLDPWD
	chmod 755 /etc/init.d/tomcat
}
fi
}

## Adding function to update chkconfig
updateChkconfig() {
echo "-- Updating chkconfig..." | tee -a ${logFile}
chkconfig --add httpd | tee -a ${logFile}
chkconfig --add tomcat | tee -a ${logFile}
chkconfig httpd on | tee -a ${logFile}
chkconfig tomcat on | tee -a ${logFile}
if [ $? != 0 ]
then
{
	errorFound
}
fi
}

## Adding function to compile Commerce
compileCommerce(){
echo -e "-- Compiling Commerce code.\nRunning /avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup" | tee -a ${logFile}
/avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup
errCode=$?
if [[ ${errCode} != 0 ]];
then
{
	if [[ ${errCode} == 2 ]];
	then
	{
		echo -e "Running for 2nd time: /avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup" | tee -a ${logFile}
		/avetti/mvn/bin/mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true --settings=/home/avetti/.m2/settings.xml avetti:module:setup | tee -a ${logFile}
	}
	else
	{
		echo "Error...";
		exit 1;
	}
	fi
}
else
{
	echo -e "Successfully ran avetti:module:setup" | tee -a ${logFile}
}
fi

sed -i "s/<project.svn.username>${avettisvnuser}<\/project.svn.username>/<project.svn.username><\/project.svn.username>/g" /avetti/svn/${code_to_install}/pom.xml
sed -i "s/<project.svn.password>${avettisvnpassword}<\/project.svn.password>/<project.svn.password><\/project.svn.password>/g" /avetti/svn/${code_to_install}/pom.xml

coreDir=`cat /avetti/svn/${code_to_install}/pom.xml | grep project.core | cut -d'>' -f2 | cut -d'<' -f1 | cut -d'/' -f1`
chmod +x /avetti/svn/${coreDir}/src/site/resources/database-changes/util/mysqlExport.sh
chmod +x /avetti/svn/${coreDir}/src/site/resources/database-changes/util/mysqlImport.sh 

chown -R avetti:apache /avetti/svn
chmod -R g+w /avetti/svn

if [[ `echo $allDb | grep ' preview '` ]]
then
{
	echo -e "Already exists a database named \"preview\"..\nUpdating instead of overwriting existing DB.\nRunning su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview\"" | tee -a ${logFile}
	su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview"
	errCode=$?
	if [[ ${errCode} != 0 ]];
	then
	{
		if [[ ${errCode} == 2 ]];
		then
		{
			echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview\""
			su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-preview" | tee -a ${logFile}
		}
		else
		{
			echo "Error..." | tee -a ${logFile}
			exit 1;
		}
		fi
	}
	else
	{
		echo -e "Maven avetti:util:dbmigrator -Pupdate-db-preview ran successfully" | tee -a ${logFile}
	}
	fi
}
else
{
	echo -e "Running su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-preview\"" | tee -a ${logFile}
	su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-preview"
	errCode=$?
	if [[ ${errCode} != 0 ]];
	then
	{
		if [[ ${errCode} == 2 ]];
		then
		{
			echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-preview\"" | tee -a ${logFile}
			su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-preview" | tee -a ${logFile}
		}
		else
		{
			echo "Error..." | tee -a ${logFile}
			exit 1;
		}
		fi
	}
        else
        {
                echo -e "Maven avetti:util:dbmigrator -Psetup-db-preview ran successfully" | tee -a ${logFile}
        }
	fi

	if [[ "${mysqlRootPwd}" != "" ]]
	then
	{
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "UPDATE preview.domain_alias SET domain_alias='${appHostName}' WHERE default_domain=1;"
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "UPDATE preview.domain_alias SET vendor_suffix='espanol' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "UPDATE preview.domain_alias SET domain_alias='${appHostName}' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "DELETE FROM preview.logs;"
	}
	else 
	{
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "UPDATE preview.domain_alias SET domain_alias='${appHostName}' WHERE default_domain=1;"
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "UPDATE preview.domain_alias SET vendor_suffix='espanol' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "UPDATE preview.domain_alias SET domain_alias='${appHostName}' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "DELETE FROM preview.logs;"
	}
	fi

}
fi

if [[ `echo $allDb | grep ' shop '` ]]
then
{
	echo -e "Already exists a database named \"shop\"..\nUpdating instead of overwriting existing DB.\nRunning su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop\"" | tee -a ${logFile}
	su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop"
	errCode=$?
	if [[ ${errCode} != 0 ]];
	then
	{
		if [[ ${errCode} == 2 ]];
		then
		{
			echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop\"" | tee -a ${logFile}
			su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-shop" | tee -a ${logFile}
		}
		else
		{
			echo "Error..." | tee -a ${logFile}
			exit 1;
		}
		fi
	}
        else
        {
                echo -e "Maven avetti:util:dbmigrator -Pupdate-db-shop ran successfully" | tee -a ${logFile}
        }
	fi
}
else
{
	echo -e "Running su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-shop\"" | tee -a ${logFile}
	su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-shop"
	errCode=$?
	if [[ ${errCode} != 0 ]];
	then
	{
		if [[ ${errCode} == 2 ]];
		then
		{
			echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-shop\"" | tee -a ${logFile}
			su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-shop" | tee -a ${logFile}
		}
		else
		{
			echo "Error..." | tee -a ${logFile}
			exit 1;
		}
		fi
	}
        else
        {
                echo -e "Maven avetti:util:dbmigrator -Psetup-db-shop ran successfully" | tee -a ${logFile}
        }
	fi
	if [[ "${mysqlRootPwd}" != "" ]]
	then
	{
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "UPDATE shop.domain_alias SET domain_alias='${appHostName}' WHERE default_domain=1;"
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "UPDATE shop.domain_alias SET vendor_suffix='espanol' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "UPDATE shop.domain_alias SET domain_alias='${appHostName}' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -p${mysqlAvettiPwd} -h${mysqlHost} -P${mysqlPort} -e "DELETE FROM shop.logs;"
	}
	else 
	{
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "UPDATE shop.domain_alias SET domain_alias='${appHostName}' WHERE default_domain=1;"
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "UPDATE shop.domain_alias SET vendor_suffix='espanol' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "UPDATE shop.domain_alias SET domain_alias='${appHostName}' WHERE domain_settings='tpt=desktop_es';"
		mysql -uavetti -h${mysqlHost} -P${mysqlPort} -e "DELETE FROM shop.logs;"
	}
	fi
}
fi

if [[ `echo $allDb | grep ' backup '` ]]
then
{
	echo -e "Already exists a database named \"backup\"..\nUpdating instead of overwriting existing DB.\nRunning su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup\"" | tee -a ${logFile}
	su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup"
	errCode=$?
	if [[ ${errCode} != 0 ]];
	then
	{
		if [[ ${errCode} == 2 ]];
		then
		{
			echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup\"" | tee -a ${logFile}
			su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Pupdate-db-backup" | tee -a ${logFile}
		}
		else 
		{
			echo "Error..." | tee -a ${logFile}
			exit 1;
		}
		fi
	}
        else
        {
                echo -e "Maven avetti:util:dbmigrator -Pupdate-db-backup ran successfully" | tee -a ${logFile}
        }
	fi
}
else
{
	echo -e "Running su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-backup\"" | tee -a ${logFile}
	su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-backup"
	errCode=$?
	if [[ ${errCode} != 0 ]];
	then
	{
		if [[ ${errCode} == 2 ]];
		then
		{
			echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-backup\"" | tee -a ${logFile}
			su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:dbmigrator -Psetup-db-backup" | tee -a ${logFile}
		}
		else
		{
			echo "Error..." | tee -a ${logFile}
			exit 1;
		}
		fi
	}
        else
        {
                echo -e "Maven avetti:util:dbmigrator -Psetup-db-backup ran successfully" | tee -a ${logFile}
        }
	fi
}
fi

echo -e "Running su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded\""
su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded"
errCode=$?
if [[ ${errCode} != 0 ]];
then
{
	if [[ ${errCode} == 2 ]];
	then
	{
		echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded\"" | tee -a ${logFile}
		su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Ppreview clean compile war:exploded" | tee -a ${logFile}
	}
	else
	{
		echo "Error..." | tee -a ${logFile}
		exit 1;
	}
	fi
}
else
{
        echo -e "Maven avetti:module:deploy -Ppreview clean compile war:exploded ran successfully" | tee -a ${logFile}
}
fi

echo -e " Running su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded\"" | tee -a ${logFile}
su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded"
errCode=$?
if [[ ${errCode} != 0 ]];
then
{
	if [[ ${errCode} == 2 ]];
	then
	{
		echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded\"" | tee -a ${logFile}
		su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:module:deploy -Pshop clean compile war:exploded" | tee -a ${logFile}
	}
	else
	{
		echo "Error..." | tee -a ${logFile}
		exit 1;
	}
	fi
}
else
{
        echo -e "Maven avetti:module:deploy -Pshop clean compile war:exploded ran successfully" | tee -a ${logFile}
}
fi

echo -e "Running su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview\"" | tee -a ${logFile}
su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview"
errCode=$?
if [[ ${errCode} != 0 ]];
then
{
	if [[ ${errCode} == 2 ]]
	then
	{
		echo -e "Running for 2nd time: su -  avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview\"" | tee -a ${logFile}
		su -  avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-preview" | tee -a ${logFile}
	}
	else
	{
		echo "Error..." | tee -a ${logFile}
		exit 1; 
	}
	fi
}
else
{
        echo -e "Maven avetti:util:lgpl -Pinstall-lgpl-on-preview ran successfully" | tee -a ${logFile}
}
fi

echo -e "Running su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop\"" | tee -a ${logFile}
su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop"
errCode=$?
if [[ ${errCode} != 0 ]];
then
{
	if [[ ${errCode} == 2 ]];
	then
	{
		echo -e "Running for 2nd time: su - avetti -c \"cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop\"" | tee -a ${logFile}
		su - avetti -c "cd /avetti/svn/${code_to_install}; /avetti/mvn/bin/mvn --settings=/home/avetti/.m2/settings.xml avetti:util:lgpl -Pinstall-lgpl-on-shop" | tee -a ${logFile}
	}
	else
	{
		echo "Error..." | tee -a ${logFile}
		exit 1;
	}
	fi
}
else
{
        echo -e "Maven avetti:util:lgpl -Pinstall-lgpl-on-shop ran successfully" | tee -a ${logFile}
}
fi
}

## Adding function to configure Solr 46
configureSolr46() {
echo -e "-- Configuring Solr 4.6" | tee -a ${logFile}
su - avetti -c "cp /avetti/svn/${coreDir}/src/site/resources/solr/items-core/conf/*.xml /avetti/solr46/preview-solr/items/conf/; cp /avetti/svn/${coreDir}/src/site/resources/solr/categories-core/conf/*.xml /avetti/solr46/preview-solr/categories/conf/"
su - avetti -c "cp /avetti/svn/${coreDir}/src/site/resources/solr/items-core/conf/*.xml /avetti/solr46/shop-solr/items/conf/; cp /avetti/svn/${coreDir}/src/site/resources/solr/categories-core/conf/*.xml /avetti/solr46/shop-solr/categories/conf/"
}

## Beginning of the script..
if [ `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep -i '^--help$\|^-h$'` ]
then
{
echo -e "$(tput setaf 4)Avetti Commerce Complete Installation Script\nCopyright 2014 Avetti.com Corporation$(tput sgr0)\n\nInstalls Avetti Commerce, MySQL, Java, Apache Web Server, Tomcat Application Server and all software required for a complete server setup.\n\nUSAGE:  ./setup.sh [your_mysql_root_password] [your_mysql_avetti_user_password] [c8prod1.yourdomain.com] [--nojava] [--nomysql] [--nohttpd]\n\nEXAMPLE:\n\nOn a Linux server use:\n\n./setup.sh  yourpassword  c8prod1.yourdomain.com\n\nOn your Linux pc use:\n\n./setup.sh  yourpassword\n\nPARAMETERS:\nyour_mysql_root_password\t\tyour existing mysql root password or  the\n\t\t\t\t\tpassword to set for root for new installs\n\nyour_mysql_avetti_user_password\t\tthe password to set for the 'avetti' user\n\t\t\t\t\tin mysql.  The  root  password is used by\n\t\t\t\t\tdefault\n\nc8prod1.yourdomain.com\t\t\tthe domain name of your server.  Defaults\n\t\t\t\t\tto localhost if not specified\n\n--nojava\t\t\t\tdon't yum/apt-get install openjdk7\n\n--nomysql\t\t\t\tdon't yum/apt-get install mysql\n\n--nohttpd\t\t\t\tdon't install Apache Web Server.\n\nFor more information read the  Avetti Commerce 8 Setup Guide pdf within this zip file.\nVisit our forum at http://avetticommerce.com/support or email ecommerce@avetti.com"
exit 1;
}
fi

if [[ `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep ^--` ]] && ! [[ `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep -i '^--nomysql$\|^--nojava$\|^--nohttpd$'` ]]
then
{
	cho -e "setup.sh: unrecognized option(s) '`echo -e "$1\n$2\n$3\n$4\n$5\n$6"| grep ^-- | grep -i -v 'nomysql\|nojava\|nohttpd'`'\nTry './setup.sh --help' for more information."
	exit 1;
}
elif [[ `echo -e "$1\n$2\n$3\n$4\n$5\n$6"| grep ^-` ]] && ! [[ `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep -i '^--nomysql$\|^--nojava$\|^--nohttpd$'` ]]
then
{
	echo -e "setup.sh: invalid option(s) -- '`echo -e "$1\n$2\n$3\n$4\n$5\n$6"| grep ^- | grep -i -v 'nomysql\|nojava\|nohttpd' | cut -d'-' -f2`'\nTry './setup.sh --help' for more information."
	exit 1;

}
fi

echo -e "##################################################\n# Script started at `date` #\n##################################################\n\n$0 $*\n" >>${logFile}

if [ `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep -i ^--nojava$` ]
then
{
	addJava=nojava
}
fi

if [ `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep -i ^--nomysql$` ]
then
{
	addMysql=nomysql
}
fi

if [ `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep -i ^--nohttpd$` ]
then
{
	addHttpd=nohttpd
}
fi

echo -e "$(tput setaf 4)Avetti Commerce Complete Installation Script\nCopyright 2014 Avetti.com Corporation$(tput sgr0)\n\nThis script will install Avetti Commerce Using the following parameters:\n"
echo -e "Avetti Commerce Complete Installation Script\nCopyright 2014 Avetti.com Corporation\n\nThis script will install Avetti Commerce Using the following parameters:\n" >>${logFile}

IFS=$'\n'
for g in `echo -e "$1\n$2\n$3\n$4\n$5\n$6" | grep -iv '^--nojava$\|^--nomysql$\|^--nohttpd$'`
do
	let counter1++
	param[${counter1}]=$g
done

if [[ ${param[1]} == "" ]] 
then
{
	mysqlRootPwd=
	mysqlAvettiPwd=avetti
	appHostName=localhost
}
fi

if [[ ${param[1]} != "" ]] && [[ ${param[2]} == "" ]]
then
{
	mysqlRootPwd=${param[1]}
	mysqlAvettiPwd=${mysqlRootPwd}
	appHostName=localhost
}
fi

if [[ ${param[2]} != "" ]] && [[ ${param[3]} == "" ]]
then
{
	mysqlRootPwd=${param[1]}
	mysqlAvettiPwd=${mysqlRootPwd}
	appHostName=${param[2]}
}
fi

if [[ ${param[3]} != "" ]]
then
{
	mysqlRootPwd=${param[1]}
	mysqlAvettiPwd=${param[2]}
	appHostName=${param[3]}
}
fi

echo -e "MySQL root password:\t\t\t$(tput bold)${mysqlRootPwd}$(tput sgr0)\nYour MySQL 'avetti' user's password:\t$(tput bold)${mysqlAvettiPwd}$(tput sgr0)\nHostname:\t\t\t\t$(tput bold)${appHostName}$(tput sgr0)\n"
echo -e "MySQL root password:\t\t\t${mysqlRootPwd}\nYour MySQL 'avetti' user's password:\t${mysqlAvettiPwd}\nHostname:\t\t\t\t${appHostName}\n" >>${logFile}
if [[ ${addMysql} == "nomysql" ]]
then
{
	echo -e "MySQL will $(tput bold)NOT$(tput sgr0) be installed."
	echo -e "MySQL will NOT be installed." >>${logFile}
}
fi

if [[ ${addJava} == "nojava" ]]
then
{
	echo -e "OpenJDK will $(tput bold)NOT$(tput sgr0) be installed."
	echo -e "OpenJDK will NOT be installed." >>${logFile}
}
fi

if [[ ${addHttpd} == "nohttpd" ]]
then
{
	echo -e "Apache Web Server will $(tput bold)NOT$(tput sgr0) be installed."
	echo -e "Apache Web Server will NOT be installed." >>${logFile}
}
fi

echo -e "\nDo you want to use these parameters? (Y/N)?" | tee -a ${logFile}
read answer2
echo -e "\nUser answered: $answer2" >>${logFile}
if ! [ `echo $answer2 | grep -i '^y$'` ]
then
{
	if [ `echo -e $answer2 | grep -i '^n$'` ]
	then
	{
		echo -e "\nExiting per user's request..." | tee -a ${logFile}
		exit 0;
	}
	else
	{
		echo -e "Unknown answer.. exiting.." | tee -a ${logFile}
		exit 1;
	}
	fi
}
fi

echo -ne "Checking requirements...\nChecking svn client:\t\t\t" | tee -a ${logFile}
svn --version --quiet >>${logFile} 2>&1
if [ $? != 0 ]
then
{
	echo -e "Failed\nInstalling subversion.." | tee -a ${logFile}
	if [[ -e "/usr/bin/yum" ]] || [[ -e "/bin/yum" ]]
	then
	{
		echo -e "Running: yum install -y subversion" >>${logFile}
		yum install -y subversion | tee -a ${logFile}
		if [ $? != 0 ]
		then
		{
			errorFound
		}
		fi
	}
	elif [ -e "/usr/bin/apt-get" ];
	then
	{
		echo -e "Running: apt-get update" >>${logFile}
		apt-get update | tee -a ${logFile}
		echo -e "Running: apt-get install -y subversion" >>${logFile}
		apt-get install -y subversion | tee -a ${logFile}
		if [ $? != 0 ]
		then
		{
			errorFound
		}
		fi
	}
	fi
}
else
{
	echo -e "OK" | tee -a ${logFile}
}
fi
echo -ne "Checking MySQL client:\t\t\t" | tee -a ${logFile}
if [[ "${addMysql}" == "nomysql" ]]
then
{
	mysql --version >> ${logFile} 2>&1
	if [ $? != 0 ]
	then
	{
		echo -e "Failed\nInstalling MySQL client.." | tee -a ${logFile}
		if [[ -e "/usr/bin/yum" ]] || [[ -e "/bin/yum" ]]
		then
		{
			echo -e "Running: yum install -y mysql" >>${logFile}
			yum install -y mysql | tee -a ${logFile}
			if [ $? != 0 ]
			then
			{
				errorFound
			}
			fi
		}
		elif [ -e "/usr/bin/apt-get" ];
		then
		{
			echo -e "Running: apt-get update" >>${logFile}
			apt-get update
			echo -e "Running: apt-get install -y mysql-client" >>${logFile}
			apt-get install -y mysql-client | tee -a ${logFile}
			if [ $? != 0 ]
			then
			{
				errorFound
			}
			fi
		}
		fi
	}
	else
	{
		echo -e "OK"  | tee -a ${logFile}
	}
	fi
}
else
{
	echo -e "N/A"  | tee -a ${logFile}
}
fi

if [[ "${addJava}" == "nojava" ]]
then
{
	echo -ne "Checking JAVA_HOME variable:\t\t" | tee -a ${logFile}
	$JAVA_HOME/bin/javac -version >>${logFile} 2>&1
	if [ $? != 0 ]
	then
	{
		echo -e "Failed" | tee -a ${logFile}
		echo -e "JAVA_HOME: $JAVA_HOME" >>${logFile}
		errorFound
	}
	else
	{
		echo -e "OK" | tee -a ${logFile}
		javaVer=`$JAVA_HOME/bin/javac -version 2>&1 | cut -d' ' -f2`
	}
	fi
}
else
{
	echo "OK" | tee -a ${logFile}
}
fi

echo -ne "Checking netcat installation:\t\t" | tee -a ${logFile}
which nc >/dev/null 2>&1
if [[ $? != 0 ]]
then
{
	if [[ -e "/usr/bin/yum" ]] || [[ -e "/bin/yum" ]]
	then
	{
		yum install -y nc | tee -a ${logFile}
	}
	elif [[ -e "/usr/bin/apt-get" ]]
	then
	{
		apt-get update
		apt-get install -y nc | tee -a ${logFile}
	}
	fi
}
else
{
	echo "OK" | tee -a ${logFile}
}
fi

if [[ "${addMysql}" == "nomysql" ]]
then
{
	echo -e "\nPlease enter IP address (or FQDN) of the MySQL server [localhost]: " | tee -a ${logFile}
	read mysqlHost2
	echo -e "User answered: ${mysqlHost2} for mysqlHost" >>${logFile}
	if [[ ${myqlHost2} -ne "" ]]
	then
	{
		mysqlHost=${mysqlHost2}
	}
	else
	{
		mysqlHost=localhost
		echo -e "Assuming mysqlHost=localhost" >>${logFile}
	}
	fi
	echo -e "Testing connection to MySQL server.." | tee -a ${logFile}
	nc -z ${mysqlHost} 3306 >>${logFile} 2>&1
	if [ $? != 0 ]
	then
	{
		echo -e "${mysqlHost} is unreachable on port 3306. This could be due to the server or MySQL being offline or it's listening on another port.\nPlease enter the port where MySQL is listening on [3306]:" | tee -a ${logFile}
		read mysqlPort2
		echo -e "User answered: ${mysqlPort2} for mysqlPort" >>${logFile}
		if [[ ${mysqlPort2} -ne "" ]]
		then
		{
			mysqlPort=${mysqlPort2}
		}
		else
		{
			echo -e "Assuming mysqlPort=3306" >>${logFile}
			mysqlPort=3306
		}
		fi
	}
	fi
	if [[ ${mysqlRootPwd} == "" ]]
	then
	{
		mysql -uroot -h ${mysqlHost} -P ${mysqlPort} -e "show databases;" >>${logFile} 2>&1
		mysqlErr=$?
		allDb=`mysql -uroot -h ${mysqlHost} -P ${mysqlPort} -e "show databases;" 2>&1`
	}
	else
	{
		mysql -uroot -p${mysqlRootPwd} -h ${mysqlHost} -P ${mysqlPort} -e "show databases;" >>${logFile} 2>&1
		mysqlErr=$?
		allDb=`mysql -uroot -p${mysqlRootPwd} -h ${mysqlHost} -P ${mysqlPort} -e "show databases;" 2>&1`
	}
	fi
	if [[ `echo ${allDb} | grep denied` ]] && [[ ${mysqlErr} == "1" ]]
	then
	{
		echo -e "Access denied to MySQL server.. Please verify your password for root user."
		errorFound
	}
	fi
	if [[ `echo ${allDb} | grep connect | tee -a ${logFile}` ]] && [[ ${mysqlErr} == "1" ]]
	then
	{
		echo -e "Can't connect to MySQL server.. Please make sure MySQL service is running and port is accessible."
		errorFound
	}
	fi
	
}
fi

if [[ ${addHttpd} == "nohttpd" ]]
then
{
	echo -e "Please enter the full path your Apache Web Server installation, so it can be configured for Avetti Commerce:" | tee -a ${logFile}
	read answer4
	echo -e "User answered: $answer4 for httpdPath" >>${logFile}
	echo -en "\nVerifying path..." | tee -a ${logFile}
	if [ -x $answer4/bin/httpd ]
	then
	{
		echo -e "\tOK\nDetecting httpd version...\t"  | tee -a ${logFile}
		httpdPath=${answer4}
		echo -e "Setting httpdPath=${answer4}" >>${logFile}
		$answer4/bin/httpd -v >>${logFile}
		httpdVer=`$answer4/bin/httpd -v | grep version | cut -d'/' -f2 | cut -d' ' -f1`
	}
	else
	{
		echo -e "The path specified ${answer4} is not valid, as ${answer4}/bin/httpd does not exist or is not executable."  | tee -a ${logFile}
		errorFound
	}
	fi
}
else
{
	httpdPath=/avetti/httpd
}
fi

echo -e "\nThe following script will install Avetti Commerce code from ${path_to_code}\nDo you want to continue installing this ${code_to_install} version? (Y/N)?" | tee -a ${logFile}
read answer2
echo -e "User answered: ${answer2}" >>${logFile}
if ! [ `echo -e "$answer2" | grep -i '^y$'` ]
then
{
	if ! [ `echo -e "$answer2" | grep -i '^n$'` ]
	then
	{
		echo "Unknown answer, exiting..." | tee -a ${logFile}
		exit 0;
	}	
	else
	{
		echo -e "\nPlease enter the desired code path to install (relative path):" | tee -a ${logFile}
		read answer3
		echo -e "User answered: $answer3 for path_to_code" >>${logFile}
		echo -e "\nVerifying path...\n\nPlease enter your SVN user:" | tee -a ${logFile}
		read avettisvnuser
		echo -e "User answered: $avettisvnuser for SVN user" >>${logFile}
		read -s -p "Enter your SVN password: " avettisvnpassword
		if [[ `echo ${answer3} | cut -d'/' -f1` == "" ]]
		then
		{
			path_to_code=`echo ${answer3} | cut -d'/' -f2-`
		}
		else
		{
			path_to_code=${answer3}
		}
		fi
		echo -e "Using path_to_code=${path_to_code}" >>${logFile}
		svn info --no-auth-cache --trust-server-cert --non-interactive --username=${avettisvnuser} --password=${avettisvnpassword} https://svn.avetticommerce.com/software/avetticommerce/${path_to_code} >>${logFile} 2>&1
		if [ $? != 0 ]
		then
		{
			echo -e "ERROR: requested path https://svn.avetticommerce.com/software/avetticommerce/${path_to_code} does not exist or you are not authorized to download that version.\nPlease check your input and run the setup.sh script again." | tee -a ${logFile}
			exit 1;
		}
		else
		{
			code_to_install=`echo $path_to_code | rev | cut -d'/' -f1 | rev`
			if [[ ${code_to_install} == "" ]]
			then
			{
				code_to_install=`echo $path_to_code | rev | cut -d'/' -f2 | rev`
			}
			fi
		}
		fi
	}
	fi
}
else
{
	echo -e "\nPlease enter your SVN user:"  | tee -a ${logFile}
	read avettisvnuser
	echo -e "User answered: $avettisvnuser for SVN user" >>${logFile}
	read -s -p "Enter your SVN password: " avettisvnpassword
	echo -e "\nVerifying svn credentials..." | tee -a ${logFile}
	svn info --no-auth-cache --trust-server-cert --non-interactive --username=${avettisvnuser} --password=${avettisvnpassword} https://svn.avetticommerce.com/software/avetticommerce/${path_to_code} >>${logFile} 2>&1
	if [ $? != 0 ]
	then
	{
		echo -e "ERROR: You are not authorized to download https://svn.avetticommerce.com/software/avetticommerce/${path_to_code} version.\nPlease check your input and run the setup.sh script again." | tee -a ${logFile}
		exit 1;
	}
	fi
}
fi

echo -e "Installing additional requirements.." | tee -a ${logFile}

if [[ -e "/usr/bin/yum" ]] || [[ -e "/bin/yum" ]]
then
{
	echo -e "Running: yum install -y openssl openssl-devel zlib zlib-devel chkconfig gcc glibc make less vi dos2unix cmake wget ncurses-devel gcc-c++ bind-utils" >>${logFile}
	yum install -y openssl openssl-devel zlib zlib-devel chkconfig gcc glibc make less vi dos2unix cmake wget ncurses-devel gcc-c++ bind-utils | tee -a ${logFile}
}
elif [ -e "/usr/bin/apt-get" ];
then
{
	export DEBIAN_FRONTEND=noninteractive
	echo -e "Running: apt-get update" >>${logFile}
	apt-get update
	echo -e "Running: apt-get install -y -q zlibc openssl libssl-dev zlib-bin libjzlib-java gcc glibc-* make vim dos2unix libncurses5-dev build-essential zlib1g zlib1g-dev dnsutils" >>${logFile}
	apt-get install -y -q zlibc openssl libssl-dev zlib-bin libjzlib-java gcc glibc-* make vim dos2unix libncurses5-dev build-essential zlib1g zlib1g-dev dnsutils | tee -a ${logFile}
}
fi

echo -e "Creating \"apache\" group.." | tee -a ${logFile}
if [[ `grep ^apache: /etc/group` ]]
then
{
	echo -e "Group \"apache\" already exists." | tee -a ${logFile}
}
else
{
	groupadd apache | tee -a ${logFile}
	if [ $? == 0 ]
	then
	{
		echo -e "Group \"apache\" was successfully created." | tee -a ${logFile}
	}
	else
	{
		errorFound
	}
	fi
}
fi

echo "Adding \"tomcat\" user.."
if [[ `grep tomcat: /etc/passwd` ]]
then
{
	echo -e "User \"tomcat\" already exists."
	usermod -g apache tomcat
}
else
{
	useradd -r -s /sbin/nologin -g apache  tomcat
	if [ $? == 0 ]
	then
	{
		echo -e "User \"tomcat\" was successfully created." | tee -a ${logFile}
	}
	else
	{
		errorFound
	}
	fi
}
fi

echo "Adding \"httpd\" user.."
if [[ `grep httpd: /etc/passwd` ]]
then
{
	echo -e "User \"httpd\" already exists."
	usermod -g apache httpd
}
else
{
	useradd -r -s /sbin/nologin -g apache  httpd
	if [ $? == 0 ]
	then
	{
		echo -e "User \"httpd\" was successfully created." | tee -a ${logFile}
	}
	else
	{
		errorFound
	}
	fi
}
fi

echo "Adding \"avetti\" user.."
if [[ `grep avetti: /etc/passwd` ]]
then
{
	echo -e "User \"avetti\" already exists."
	usermod -g apache avetti
}
else
{
	useradd -m -s /bin/bash -g apache  avetti
	if [ $? == 0 ]
	then
	{
		echo -e "User \"avetti\" was successfully created." | tee -a ${logFile}
	}
	else
	{
		errorFound
	}
	fi
}
fi

if [[ -d /etc/sysconfig ]]
then
{
	if ! [[ `grep ${appHostName} /etc/sysconfig/network` ]]
	then
	{
		mv /etc/sysconfig/network /etc/sysconfig/old-network
		echo "NETWORKING=yes" >/etc/sysconfig/network
		echo "HOSTNAME=${appHostName}" >>/etc/sysconfig/network
	}
	fi
}
elif [[ -e /etc/hostname ]]
then
{
	if [[ `cat /etc/hostname` !=  ${appHostName} ]]
	then
	{
		mv /etc/hostname /etc/old-hostname
		echo -e ${appHostName} >/etc/hostname
	}
	fi
}
fi
hostname ${appHostName}

if ! [[ `dig +short ${appHostName}` ]]
then
{
	if ! [[ `grep ${appHostName} /etc/hosts` ]]
	then
	{
		sed -i "/^127.0.0.1/ s/$/ ${appHostName}/" /etc/hosts
	}
	fi
}
fi

sed -i 's/C:\//\//g' /avetti/tomcat/conf/Catalina/localhost/solr-*.xml
echo "Updating sudoers..." | tee -a ${logFile}
if ! [[ `grep avetti /etc/sudoers | grep service` ]]
then
{
	if [ -e "/sbin/service" ];
	then
	{
		echo "avetti ALL= NOPASSWD: /sbin/service, /bin/chown, /bin/chmod, /avetti/httpd/bin/apachectl" >> /etc/sudoers
	}
	elif [ -e "/usr/sbin/service" ];
	then
	{
		echo "avetti ALL= NOPASSWD: /usr/sbin/service, /bin/chown, /bin/chmod, /avetti/httpd/bin/apachectl" >> /etc/sudoers
	}
	fi
}
else
{
	echo -e "File /etc/sudoers seems to have been already updated." | tee -a ${logFile}
	grep avetti /etc/sudoers | grep service >>${logFile}
}
fi

if [[ -e "/usr/bin/apt-get" ]] && [[ ! -e /sbin/insserv ]]
then
{
	ln -s /usr/lib/insserv/insserv /sbin/insserv
}
fi

if [[ ${addMysql} != "nomysql" ]]
then
{
	installMysql
}
fi

if [[ ${addJava} != "nojava" ]]
then
{
	installJava
}
fi

if [[ ${addHttpd} != "nohttpd" ]]
then
{
	installHttpd
}
fi

configureMysql
configureHttpd
configureTomcat
updateChkconfig

echo "Changing /avetti file permissions.." | tee -a ${logFile}
chmod -R g+w /avetti | tee -a ${logFile}

echo "changing ownership inside /avetti.."  | tee -a ${logFile}
chown -R avetti:apache /avetti | tee -a ${logFile}
echo "changing ownership inside /avetti/httpd.." | tee -a ${logFile}
chown -R httpd:apache /avetti/httpd | tee -a ${logFile}
echo "changing ownership of Tomcat files.." | tee -a ${logFile}
chown -R tomcat:apache /avetti/tomcat | tee -a ${logFile}
chown -R tomcat:apache /avetti/solr46 | tee -a ${logFile}

if ! [[ `grep apache /etc/profile` ]]
then
{
	echo -e 'if [ "`id -gn`" = "apache" ];\nthen umask 002\nfi' >>/etc/profile
}
fi

echo "Downloading Avetti Commerce" | tee -a ${logFile}
echo "Version to install: $code_to_install" | tee -a ${logFile}
if [[ -d /avetti/svn/${code_to_install} ]]
then
{
	echo -e "Code ${code_to_install} was already checked out."
}
else
{
	su - avetti -c "cd /avetti/svn; svn checkout --config-dir /home/avetti/.subversion --no-auth-cache --non-interactive --trust-server-cert --username=${avettisvnuser} --password=${avettisvnpassword} https://svn.avetticommerce.com/software/avetticommerce/${path_to_code}" | tee -a ${logFile}
	su - avetti -c "cd /avetti/svn; svn checkout --config-dir /home/avetti/.subversion --no-auth-cache --non-interactive --trust-server-cert --username avetti-lgpl-access --password avetti-lgpl-access https://svn.avetticommerce.com/software/LGPL-software" | tee -a ${logFile}
	if [[ $? == 0 ]]
	then
	{
		sed -i "s/<project.svn.username><\/project.svn.username>/<project.svn.username>${avettisvnuser}<\/project.svn.username>/g" /avetti/svn/${code_to_install}/pom.xml
		sed -i "s/<project.svn.password><\/project.svn.password>/<project.svn.password>${avettisvnpassword}<\/project.svn.password>/g" /avetti/svn/${code_to_install}/pom.xml
	}
	fi
}
fi

if [[ -e /home/avetti/.m2/settings.xml ]]
then
{
	echo -e "setting.xml already exists."
}
else
{
	su - avetti -c "mkdir ~/.m2; cp /avetti/svn/settings-original.xml ~/.m2/settings.xml"
	su - avetti -c "cp -rf /avetti/svn/repository ~/.m2/"
	sed -i 's/C:\//\//g' /home/avetti/.m2/settings.xml
	sed -i "s/mysql.password/${mysqlAvettiPwd}/g" /home/avetti/.m2/settings.xml
	sed -i "s/c8prod1.yourdomain.com/${appHostName}/g" /home/avetti/.m2/settings.xml
	su - avetti -c "dos2unix /home/avetti/.m2/settings.xml"
	if [[ ${addMysql} == "nomysql" ]]
	then
	{
		if [[ ${mysqlPort} == "3306" ]]
		then
		{
			sed -i "s/<db.host>localhost/<db.host>${mysqlHost}/g" /home/avetti/.m2/settings.xml
		}
		else
		{
			sed -i "s/<db.host>localhost/<db.host>${mysqlHost}:${mysqlPort}/g" /home/avetti/.m2/settings.xml
		}
		fi
	}
	fi

}
fi

chmod +x /avetti/mvn/bin/mvn
chmod +x /avetti/tomcat/bin/*.sh
chown -R avetti:apache /avetti
chown -R avetti:apache /avetti/svn
chown -R httpd:apache /avetti/httpd
chown -R tomcat:apache /avetti/tomcat

if ! [[ `grep MAVEN_OPTS /etc/profile` ]]
then
{
	echo -e 'export MAVEN_OPTS="-Xms512m -Xmx700m -XX:PermSize=256M -XX:MaxPermSize=700M"\nexport M2_HOME=/avetti/mvn\nexport M2=$M2_HOME/bin\nexport PATH=$M2:$PATH' >>/etc/profile
	. /etc/profile
}
fi

chmod -R g+r /avetti/tomcat/webapps
chmod -R g+w /avetti/tomcat/webapps
chmod -R o+r /avetti/tomcat/webapps
chmod -R g+w /avetti/svn

cd /avetti/svn/${code_to_install}
compileCommerce

configureSolr46

find /avetti/tomcat/webapps -name '*.sh' -exec  chmod +x '{}' \;

if ! [[ `crontab -l | grep catalina-cron` ]]
then
{
	cat >/etc/logrotate.d/tomcat <<"EOF"
/avetti/tomcat/logs/catalina.out {
copytruncate
rotate 6
compress
missingok
size 200M
}
EOF
	crontab -l >cron.tmp
	echo -e "* * * * 0\t/usr/sbin/logrotate /etc/logrotate.conf >>/avetti/tomcat/logs/catalina-cron.log 2>&1" >>cron.tmp
	crontab <cron.tmp
	rm -f cron.tmp
}
fi

sed -i "s/mysql.password/${mysqlAvettiPwd}/g" /avetti/tomcat/conf/Catalina/localhost/preview.xml
sed -i "s/mysql.password/${mysqlAvettiPwd}/g" /avetti/tomcat/conf/Catalina/localhost/ROOT.xml

if [[ ${addMysql} == "nomysql" ]]
then
{
	sed -i "s/localhost/${mysqlHost}/g" /avetti/tomcat/conf/Catalina/localhost/preview.xml
	sed -i "s/localhost/${mysqlHost}/g" /avetti/tomcat/conf/Catalina/localhost/ROOT.xml
	if [[ ${mysqlPort} != "3306" ]]
	then
	{
		sed -i "s/3306/${mysqlPort}/g" /avetti/tomcat/conf/Catalina/localhost/preview.xml
		sed -i "s/3306/${mysqlPort}/g" /avetti/tomcat/conf/Catalina/localhost/ROOT.xml
	}
	fi
}
fi

cp /avetti/tomcat/conf/Catalina/localhost/preview.xml /avetti/tomcat/webapps/preview/META-INF/context.xml
cp /avetti/tomcat/conf/Catalina/localhost/ROOT.xml /avetti/tomcat/webapps/ROOT/META-INF/context.xml

ln -s /avetti/tomcat/webapps/preview/store /avetti/httpd/htdocs/content/preview/
ln -s /avetti/tomcat/webapps/ROOT/store /avetti/httpd/htdocs/content/shop/

chmod -R g+w /avetti

if [[ -e /avetti/tomcat/webapps/preview/WEB-INF/classes ]];
then
	echo -e "********************************************************************************\n*\n*   Congratuations!!  Avetti Comerce ${code_to_install} is now installed\n*\n*   To view the store run:\n\n     service httpd start\n     service mysqld start\nthen run:\n     /avetti/scripts/tomcat.sh start [pflogs]\n\nWhen the output shows a Server Started line for both the preview and ROOT (shop)\napplications or a splash page advising that the application is loaded then you\ncan login to the preview store using:\n\nhttps://${appHostName}/preview/login.admin\n\nNote you can also Control-C the output of tomcat.sh start at any time and get\nthe output again by running\n     tail -f /avetti/tomcat/logs/catalina.out or pflogs.log\n\nTo Stop Tomcat, Apache and Mysql run:\n\n     /avetti/scripts/tomcat.sh stop\n     service httpd stop\n     service mysqld stop\n\nNote that you may also wish to tail -f /avetti/tomcat/logs/pflogs.log to view\nthe performance log. The first parameter is the # of milliseconds to serve the\npage.\n\n*\n*\n********************************************************************************"
	echo -e "Script finished successfully" >>${logFile}
else
{
	echo -e "An error occurred, please check the output above for more details." | tee -a ${logFile}
	exit 1;
}
fi
