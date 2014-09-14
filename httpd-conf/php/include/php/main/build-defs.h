/*                                                                -*- C -*-
   +----------------------------------------------------------------------+
   | PHP Version 5                                                        |
   +----------------------------------------------------------------------+
   | Copyright (c) 1997-2007 The PHP Group                                |
   +----------------------------------------------------------------------+
   | This source file is subject to version 3.01 of the PHP license,      |
   | that is bundled with this package in the file LICENSE, and is        |
   | available through the world-wide-web at the following url:           |
   | http://www.php.net/license/3_01.txt                                  |
   | If you did not receive a copy of the PHP license and are unable to   |
   | obtain it through the world-wide-web, please send a note to          |
   | license@php.net so we can mail you a copy immediately.               |
   +----------------------------------------------------------------------+
   | Author: Stig Sæther Bakken <ssb@php.net>                             |
   +----------------------------------------------------------------------+
*/

/* $Id: build-defs.h.in 292156 2009-12-15 11:17:47Z jani $ */

#define CONFIGURE_COMMAND " './configure'  '--prefix=/avetti/httpd/php' '--with-apxs2=/avetti/httpd/bin/apxs' '--with-mysql=/avetti/mysql' '--enable-mbstring' '--with-config-file-path=/avetti/httpd/php' '--with-config-file-scan-dir=/avetti/httpd/php/php.d' '--enable-bcmath=shared' '--with-bz2' '--enable-calendar' '--with-curl' '--enable-dba=shared' '--enable-exif' '--enable-ftp' '--with-gettext' '--with-mhash' '--with-mysqli' '--with-openssl-dir=/usr' '--with-openssl' '--enable-pcntl' '--with-readline' '--enable-shmop' '--enable-soap=shared' '--enable-sockets' '--enable-sysvmsg' '--enable-sysvsem' '--enable-sysvshm' '--enable-wddx' '--enable-zip' '--with-zlib' '--with-mcrypt' '--with-pdo_mysql=/avetti/mysql' '--with-pdo_sqlite' '--with-libxml-dir=/avetti/httpd/php'"
#define PHP_ADA_INCLUDE		""
#define PHP_ADA_LFLAGS		""
#define PHP_ADA_LIBS		""
#define PHP_APACHE_INCLUDE	""
#define PHP_APACHE_TARGET	""
#define PHP_FHTTPD_INCLUDE      ""
#define PHP_FHTTPD_LIB          ""
#define PHP_FHTTPD_TARGET       ""
#define PHP_CFLAGS		"$(CFLAGS_CLEAN) "
#define PHP_DBASE_LIB		""
#define PHP_BUILD_DEBUG		""
#define PHP_GDBM_INCLUDE	""
#define PHP_IBASE_INCLUDE	""
#define PHP_IBASE_LFLAGS	""
#define PHP_IBASE_LIBS		""
#define PHP_IFX_INCLUDE		""
#define PHP_IFX_LFLAGS		""
#define PHP_IFX_LIBS		""
#define PHP_INSTALL_IT		"$(mkinstalldirs) '$(INSTALL_ROOT)/avetti/httpd/modules' &&                 $(mkinstalldirs) '$(INSTALL_ROOT)/avetti/httpd/conf' &&                  /avetti/httpd/bin/apxs -S LIBEXECDIR='$(INSTALL_ROOT)/avetti/httpd/modules'                        -S SYSCONFDIR='$(INSTALL_ROOT)/avetti/httpd/conf'                        -i -a -n php5 libphp5.la"
#define PHP_IODBC_INCLUDE	""
#define PHP_IODBC_LFLAGS	""
#define PHP_IODBC_LIBS		""
#define PHP_MSQL_INCLUDE	""
#define PHP_MSQL_LFLAGS		""
#define PHP_MSQL_LIBS		""
#define PHP_MYSQL_INCLUDE	"-I/avetti/mysql/include"
#define PHP_MYSQL_LIBS		"-L/avetti/mysql/lib -lmysqlclient "
#define PHP_MYSQL_TYPE		"external"
#define PHP_ODBC_INCLUDE	""
#define PHP_ODBC_LFLAGS		""
#define PHP_ODBC_LIBS		""
#define PHP_ODBC_TYPE		""
#define PHP_OCI8_SHARED_LIBADD 	""
#define PHP_OCI8_DIR			""
#define PHP_OCI8_ORACLE_VERSION		""
#define PHP_ORACLE_SHARED_LIBADD 	"@ORACLE_SHARED_LIBADD@"
#define PHP_ORACLE_DIR				"@ORACLE_DIR@"
#define PHP_ORACLE_VERSION			"@ORACLE_VERSION@"
#define PHP_PGSQL_INCLUDE	""
#define PHP_PGSQL_LFLAGS	""
#define PHP_PGSQL_LIBS		""
#define PHP_PROG_SENDMAIL	"/usr/sbin/sendmail"
#define PHP_SOLID_INCLUDE	""
#define PHP_SOLID_LIBS		""
#define PHP_EMPRESS_INCLUDE	""
#define PHP_EMPRESS_LIBS	""
#define PHP_SYBASE_INCLUDE	""
#define PHP_SYBASE_LFLAGS	""
#define PHP_SYBASE_LIBS		""
#define PHP_DBM_TYPE		""
#define PHP_DBM_LIB		""
#define PHP_LDAP_LFLAGS		""
#define PHP_LDAP_INCLUDE	""
#define PHP_LDAP_LIBS		""
#define PHP_BIRDSTEP_INCLUDE     ""
#define PHP_BIRDSTEP_LIBS        ""
#define PEAR_INSTALLDIR         "/avetti/httpd/php/lib/php"
#define PHP_INCLUDE_PATH	".:/avetti/httpd/php/lib/php"
#define PHP_EXTENSION_DIR       "/avetti/httpd/php/lib/php/extensions/no-debug-non-zts-20090626"
#define PHP_PREFIX              "/avetti/httpd/php"
#define PHP_BINDIR              "/avetti/httpd/php/bin"
#define PHP_SBINDIR             "/avetti/httpd/php/sbin"
#define PHP_LIBDIR              "/avetti/httpd/php/lib/php"
#define PHP_DATADIR             "/avetti/httpd/php/share/php"
#define PHP_SYSCONFDIR          "/avetti/httpd/php/etc"
#define PHP_LOCALSTATEDIR       "/avetti/httpd/php/var"
#define PHP_CONFIG_FILE_PATH    "/avetti/httpd/php"
#define PHP_CONFIG_FILE_SCAN_DIR    "/avetti/httpd/php/php.d"
#define PHP_SHLIB_SUFFIX        "so"
