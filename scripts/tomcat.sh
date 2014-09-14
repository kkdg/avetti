#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This must be run as 'root'." 1>&2
   exit 1;
fi
if  [ $# -lt 1 ]
  then { echo -e "USAGE: Enter start or stop depending if you want to either start or stop tomcat service.\nIf you want to start it and \nFor example:  ./tomcat.sh start";  exit 1; }
fi

if [[ `echo -e "$1\n$2" | grep -i ^stop$` ]]
then
{
	service tomcat stop
}
elif  [ `echo -e "$1\n$2" | grep -i ^start$` ] && [ `echo -e "$1\n$2" | grep -i ^pflogs$` ]
then
{
	service tomcat start
	echo "Tomcat started, tailing pflogs.log.."
	tail -f /avetti/tomcat/logs/pflogs.log
}
elif [[ `echo -e "$1\n$2" | grep -i ^start$` ]]
then
{
	service tomcat start
	echo "Tomcat started, tailing catalina.out.."
	tail -f /avetti/tomcat/logs/catalina.out
}
fi
