#!/bin/bash
echo "Avetti Commerce Tomcat Restart Script"
echo "Copyright 2014 Avetti.com Corporation"
echo " "
echo "stopping tomcat..."
sudo service tomcat stop
echo "deleting solr46 lock files.."
find /avetti/solr46 -name "*.lock" -exec rm {} \;
echo "starting tomcat..."
sudo service tomcat start
echo "restarting nginx, memcache, varnish...."
sudo service nginx stop; sudo service memcached stop; sudo service varnish stop; sudo service memcached start; sudo service varnish start; sudo service nginx start;
echo "tailing catalina.out.  press control c to stop viewing logs."
tail -f  /avetti/tomcat/logs/catalina.out
