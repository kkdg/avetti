====================================
DEX tweak 2
====================================
Avetti Commerce 8 Setup

If you are reading this file then you have downloaded avetti.zip

wget http://opensource.avetti.ca/avetti.zip

Make sure you unzipped in the root directory of your server (on your C drive if MS Windows)



Notes about the Setup:

Requirements

the linux setup.sh script will setup openjdk7 via yum or apt-get install or you can use the Sun JDK.
On Windows use the Sun (Oracle) JDK 6 or 7. 

Read the Avetti Commerce 8 Setup Guidev6.pdf for the setup process.

Note the setup.sh / setup.bat script if run without parameters will give you info on what parameters are needed.

For Linux you basically just unzip avetti.zip to root then run setup.sh.

For Windows you need to install Java, Mysql (you dont need any graphical admin tools for mysql), Apache 2.2 (not 2.4) a command line svn such as SlikSVN  and configure your environment variables. See the SSetup Guide for details.

 
For Windows after you need have installed and configured Java Development Kit make sure the Java's bin directory is in your PATH environmental variable. Also make sure you already have JAVA_HOME environmental variable setup, pointing to the base directory of your installed JDK.

Remember you need the JDK not the JRE.

On an MS Windows environment it is also necessary to have MySQL, Apache Web Server 2.2.x (httpd) already installed and configured.

Setup scripts (setup.sh and setup.bat) can be found inside the /avetti/scripts directory as described in the Setup Guide.

If you have any problems ask questions on our support portal - see avetticommerce.com/support or email ecommerce@avetti.com



