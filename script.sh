#!/bin/bash
# Based on: https://linuxconfig.org/install-wordpress-on-redhat-8

clear

echo "###############################################################################"
echo "# WordPress Auto Installation Script for CentOS 8 by Daniele Lolli (UncleDan) #"
echo "###############################################################################"
echo "#"
echo "###############################################################################"
echo "# Editado por kmilo0327 para el uso multi sitio y automatizacion de tareas    #"
echo "###############################################################################"
echo .
echo -n "¿Nombre de la pagina?: "
read WPC8_SITE_NAME

echo -n "¿Dominio de la pagina? ex(.com .org)(add dot):  "
read WPC8_SITE_DOMAIN

# Setting parameters
WPC8_MYSQL_WORDPRESS_DATABASE="${WPC8_SITE_NAME}_database"
WPC8_MYSQL_WORDPRESS_USER="${WPC8_SITE_NAME}_user"
WPC8_MYSQL_WORDPRESS_PASSWORD=`date |md5sum |cut -c '1-12'`
WPC8_MYSQL_ROOT_PASSWORD=`date |md5sum |cut -c '1-12'`
#WPC8_SITE_NAME="wordpress"
WPC8_SITE_FOLDER="/var/www/${WPC8_SITE_NAME}"
WPC8_SITE_SALT1="111111111111111111111111111111SaLt111111111111111111111111111111"
WPC8_SITE_SALT2="222222222222222222222222222222SaLt222222222222222222222222222222"
WPC8_SITE_SALT3="333333333333333333333333333333SaLt333333333333333333333333333333"
WPC8_SITE_SALT4="444444444444444444444444444444SaLt444444444444444444444444444444"
WPC8_SITE_SALT5="555555555555555555555555555555SaLt555555555555555555555555555555"
WPC8_SITE_SALT6="666666666666666666666666666666SaLt666666666666666666666666666666"
WPC8_SITE_SALT7="777777777777777777777777777777SaLt777777777777777777777777777777"
WPC8_SITE_SALT8="888888888888888888888888888888SaLt888888888888888888888888888888"
WPC8_DATABASE_TABLES_PREFIX="wp_${WPC8_SITE_NAME}"

echo -e "\n\n*** Actualizando el sistema..."
yum update -y && yum upgrade -y

echo -e "\n\n*** START Installing all prerequisites..."
dnf install httpd mariadb-server php-bcmath php-curl php-fpm php-gd php-intl php-json php-mbstring php-mysqlnd php-soap php-xml php-xmlrpc php-zip unzip -y
# dnf install git rsync tar wget zip -y


echo "*** DONE Installing all prerequisites."
echo -e "\n\n*** START Opening HTTP and optionally HTTPS port 80 and 443 on your firewall..."
firewall-cmd --permanent --zone=public --add-service=http 
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
echo "*** DONE Opening HTTP and optionally HTTPS port 80 and 443 on your firewall."
echo -e "\n\n*** START Starting Apache webserver and the MariaDB services..."
systemctl start mariadb
systemctl start httpd
echo "*** DONE starting Apache webserver and the MariaDB services."
echo -e "\n\n*** START Configuring both the Apache webserver and the MariaDB services to start after reboot..."
systemctl enable mariadb
systemctl enable httpd
echo "*** DONE Configuring both the Apache webserver and the MariaDB services to start after reboot."
echo -e "\n\n*** START Creating a new database for WordPress and a new user with password with all privileges on it..."
echo "CREATE DATABASE $WPC8_MYSQL_WORDPRESS_DATABASE;
CREATE USER \`$WPC8_MYSQL_WORDPRESS_USER\`@\`localhost\` IDENTIFIED BY '$WPC8_MYSQL_WORDPRESS_PASSWORD';
GRANT ALL ON $WPC8_MYSQL_WORDPRESS_DATABASE.* TO \`$WPC8_MYSQL_WORDPRESS_USER\`@\`localhost\`;
FLUSH PRIVILEGES;
EXIT" > __TEMP__.sql
mysql -u root < __TEMP__.sql
rm -f __TEMP__.sql


echo "*** DONE Creating a new database for WordPress and a new user with password with all privileges on it."
echo -e "\n\n*** START Securing your MariaDB installation and set root password..."
# Hint from: https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script
echo "UPDATE mysql.user SET Password=PASSWORD('$WPC8_MYSQL_ROOT_PASSWORD') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE db='test' OR db='test\\_%';
FLUSH PRIVILEGES;
EXIT" > __TEMP__.sql
mysql -u root < __TEMP__.sql
rm -f __TEMP__.sql


echo "*** DONE Securing your MariaDB installation and set root password."
echo -e "\n\n*** START Stopping Apache and PHP services, or it will fail because the site folder does not exist yet..."
systemctl stop httpd
systemctl stop php-fpm

echo "*** DONE Stopping Apache and PHP services, or it will fail because the site folder does not exist yet."
echo -e "\n\n*** START Adjusting new httpd.conf with custom folder and and rewrite enabled..."
sed -i "122 s|/var/www/html|"$WPC8_SITE_FOLDER"|g ;
        134 s|/var/www/html|"$WPC8_SITE_FOLDER"|g ;
        154 s|AllowOverride None|AllowOverride All|g" /etc/httpd/conf/httpd.conf
		
		
echo "*** DONE Adjusting new httpd.conf with custom folder and and rewrite enabled."
echo -e "\n\n*** START Downloading and extracting WordPress..."
curl https://cl.wordpress.org/latest-es_CL.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip

echo "*** DONE Downloading and extracting WordPress..."
echo -e "\n\n*** START Creating files and folders to avoid permission issues..."
touch wordpress/.htaccess
mkdir -p wordpress/wp-content/uploads
mkdir -p wordpress/wp-content/upgrade
echo "*** DONE Creating files and folders to avoid permission issues."
echo -e "\n\n*** START Creating WordPress config file..."
cp $WPC8_SITE_NAME/wp-config-sample.php $WPC8_SITE_NAME/wp-config.php
sed -i "s|^define('DB_NAME',.*|define('DB_NAME', '"$WPC8_MYSQL_WORDPRESS_DATABASE"');|g ; 
        s|^define('DB_USER',.*|define('DB_USER', '"$WPC8_MYSQL_WORDPRESS_USER"');|g ; 
        s|^define('DB_PASSWORD',.*|define('DB_PASSWORD', '"$WPC8_MYSQL_WORDPRESS_PASSWORD"');|g ; 
        s|^define('AUTH_KEY',.*|define('AUTH_KEY',         '"$WPC8_SITE_SALT1"');|g ; 
        s|^define('SECURE_AUTH_KEY',.*|define('SECURE_AUTH_KEY',  '"$WPC8_SITE_SALT2"');|g ; 
        s|^define('LOGGED_IN_KEY',.*|define('LOGGED_IN_KEY',    '"$WPC8_SITE_SALT3"');|g ; 
        s|^define('NONCE_KEY',.*);|define('NONCE_KEY',        '"$WPC8_SITE_SALT4"');|g ; 
        s|^define('AUTH_SALT',.*|define('AUTH_SALT',        '"$WPC8_SITE_SALT5"');|g ; 
        s|^define('SECURE_AUTH_SALT',.*;|define('SECURE_AUTH_SALT', '"$WPC8_SITE_SALT6"');|g ; 
        s|^define('LOGGED_IN_SALT',.*|define('LOGGED_IN_SALT',   '"$WPC8_SITE_SALT7"');|g ; 
        s|^define('NONCE_SALT',.*|define('NONCE_SALT',       '"$WPC8_SITE_SALT8"');|g ;
		s|^\$table_prefix =.*|\$table_prefix = '"$WPC8_DATABASE_TABLES_PREFIX"';|g" $WPC8_SITE_NAME/wp-config.php
		
		
# echo "*** DONE Creating WordPress config file."
# echo -e "\n\n*** START Removing useless themes and plugins and installing useful ones..."
# rm -f wordpress/wp-content/plugins/hello.php
# rm -rf wordpress/wp-content/plugins/akismet/
# curl https://downloads.wordpress.org/plugin/akismet.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f akismet/ wordpress/wp-content/plugins/
# curl https://downloads.wordpress.org/plugin/elementor.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f elementor/ wordpress/wp-content/plugins/
# curl https://downloads.wordpress.org/plugin/updraftplus.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f updraftplus/ wordpress/wp-content/plugins/
# curl https://downloads.wordpress.org/plugin/static-html-output-plugin.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f static-html-output-plugin/ wordpress/wp-content/plugins/
# curl https://downloads.wordpress.org/plugin/minimal-coming-soon-maintenance-mode.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f minimal-coming-soon-maintenance-mode/ wordpress/wp-content/plugins/
# curl https://downloads.wordpress.org/plugin/wp-file-manager.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f wp-file-manager/ wordpress/wp-content/plugins/
# rm -rf wordpress/wp-content/themes/twentyseventeen/
# rm -rf wordpress/wp-content/themes/twentynineteen/
# curl https://downloads.wordpress.org/theme/hello-elementor.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f hello-elementor/ wordpress/wp-content/themes/
# curl https://downloads.wordpress.org/theme/astra.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f astra/ wordpress/wp-content/themes/
# curl https://downloads.wordpress.org/theme/generatepress.latest-stable.zip --output __TEMP__.zip && unzip -o __TEMP__.zip && rm -f __TEMP__.zip
# mv -f generatepress/ wordpress/wp-content/themes/

echo "*** DONE Removing useless themes and plugins and installing useful ones."
echo -e "\n\n*** START Moving the extracted WordPress directory into the /var/www/ folder..."
mv -f wordpress $WPC8_SITE_FOLDER


echo "*** DONE Moving the extracted WordPress directory into the /var/www/ folder."
echo -e "\n\n*** START Adjusting permissions and change file SELinux security context..."
chown -R apache:apache $WPC8_SITE_FOLDER/
chcon -t httpd_sys_rw_content_t $WPC8_SITE_FOLDER/ -R
find $WPC8_SITE_FOLDER/ -type d -exec chmod 750 {} \;
find $WPC8_SITE_FOLDER/ -type f -exec chmod 640 {} \;


echo "*** DONE Adjusting permissions and change file SELinux security context."
echo -e "\n\n*** START Setting SElinux to allow outgoing connections (or plugins and themes won't install!)..."
setsebool -P httpd_can_network_connect on
echo "*** DONE Setting SElinux to allow outgoing connections (or plugins and themes won't install!)."
echo -e "\n\n*** START Adjusting PHP parameters for file uploads, memory usage and time limits for WordPress..."
echo "; Adjust PHP parameters for file uploads, memory usage and time limits for WordPress
upload_max_filesize = 256M
post_max_size = 256M
memory_limit = 512M
max_execution_time = 180" > /etc/php.d/99-wordpress.ini 


echo "*** DONE Adjusting PHP parameters for file uploads, memory usage and time limits for WordPress."

echo -e "\n\n*** Creando archivo Virtual Host."

touch /etc/httpd/conf.d/${WPC8_SITE_NAME}.conf
mkdir /var/log/httpd/${WPC8_SITE_NAME}/

echo "<VirtualHost *:80>
  ServerName ${WPC8_SITE_NAME}${WPC8_SITE_DOMAIN}
  ServerAlias www.${WPC8_SITE_NAME}${WPC8_SITE_DOMAIN}
  DocumentRoot /var/www/${WPC8_SITE_NAME}
  <Directory /var/www/${WPC8_SITE_NAME}>
      Options -Indexes +FollowSymLinks
      AllowOverride All
  </Directory>
  ErrorLog /var/log/httpd/${WPC8_SITE_NAME}/${WPC8_SITE_NAME}-error.log
  CustomLog /var/log/httpd/${WPC8_SITE_NAME}/${WPC8_SITE_NAME}-access.log combined
</VirtualHost>" >> /etc/httpd/conf.d/${WPC8_SITE_NAME}.conf


echo -e "\n\n*** START Enabling PHP execution tu use Duplicator plugin..."
setsebool -P httpd_execmem 1


echo "*** DONE Enabling PHP execution tu use Duplicator plugin."
echo -e "\n\n*** START Restarting PHP and Apache services..."
systemctl restart php-fpm

echo -e "\n\n*** DONE Restarting Apache service."
systemctl restart httpd

echo -e "\n\n*** START Erasing dependencies now unnecessary..."
dnf erase unzip  -y
echo -e "\n\n*** DONE Erasing dependencies now unnecessary."
echo -e "\n\n*** FINISH: you can now access WordPress installation wizard and perform the"
echo "    actual WordPress installation. Navigate your browser to"
echo "    http://SERVER-IP-ADDRESS/ or http://SERVER-HOST-NAME/"
echo "    and follow the instructions."
echo -e "\n\n    Remember that you can use 'nmtui' ti change network properties.\n\n"

# Echo "
# WPC8_MYSQL_WORDPRESS_DATABASE="${WPC8_SITE_NAME}_database"
# WPC8_MYSQL_WORDPRESS_USER="${WPC8_SITE_NAME}_user"
# WPC8_MYSQL_WORDPRESS_PASSWORD=`date |md5sum |cut -c '1-12'`
# WPC8_MYSQL_ROOT_PASSWORD=`date |md5sum |cut -c '1-12'`
# #WPC8_SITE_NAME="wordpress"
# WPC8_SITE_FOLDER="/var/www/"$WPC8_SITE_NAME
# "

echo "Nombre base de datos: $WPC8_MYSQL_WORDPRESS_DATABASE "
echo "Nombre usuario Mysql: $WPC8_MYSQL_WORDPRESS_USER "
echo "Contraseña Mysql: $WPC8_MYSQL_WORDPRESS_PASSWORD "
echo "Contraseña ROOT Mysql: $WPC8_MYSQL_ROOT_PASSWORD "
echo "Ruta WordPress: $WPC8_SITE_FOLDER "
echo "Prefijo: $WPC8_DATABASE_TABLES_PREFIX"

test