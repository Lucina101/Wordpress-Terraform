#!/bin/bash

database_name = ${database_name}
database_user = ${database_user}
database_pass = ${database_pass}
database_host = ${database_host}

admin_user = ${admin_user}
admin_pass = ${admin_pass}

ACCESS_KEY = ${ACCESS_KEY}
SECRET_KEY = ${SECRET_KEY}

bucket_name = ${bucket_name}

sudo mkdir my_dir
sudo apt update -y
sudo apt install -y apache2 mariadb-server 
sudo apt install -y php php-mysql

sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp


sudo mkdir -p /srv/www
sudo chown www-data: /srv/www

curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

sudo bash -c 'cat <<EOT >> /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
     ServerAdmin admin@example.com
     DocumentRoot /srv/www/wordpress
     ServerName sitename.com
     ServerAlias www.sitename.com
     <Directory /srv/www/wordpress/>
          Options FollowSymlinks
          AllowOverride All
          Require all granted
     </Directory>

     ErrorLog /var/log//wordpress_error.log
     CustomLog /var/log//wordpress_access.log combined
</VirtualHost>
EOT'

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo systemctl reload apache2
sudo a2dissite 000-default
sudo systemctl reload apache2

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i s/database_name_here/${database_name}/ /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i s/username_here/${database_user}/ /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i s/password_here/${database_pass}/ /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i s/localhost/${database_host}/ /srv/www/wordpress/wp-config.php

perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /srv/www/wordpress/wp-config.php


cat <<EOT >> credfile.txt

define( 'AS3CF_SETTINGS', serialize( array (

    'provider' => 'aws',

    'access-key-id' => '${ACCESS_KEY}',

    'secret-access-key' => '${SECRET_KEY}',

    'bucket' => '${bucket_name}',

    'copy-to-s3' => true,
    
    'serve-from-s3' => true,
) ) );

EOT

sudo sed -i "/define( 'WP_DEBUG', false );/r credfile.txt" /srv/www/wordpress/wp-config.php
sudo rm -r credfile.txt


cd /srv/www/wordpress
sudo wp --allow-root core install --url=http://${site_url} --title=test --admin_user=${admin_user} --admin_password=${admin_pass} --admin_email=test@cmail.com
sudo wp --allow-root plugin install amazon-s3-and-cloudfront
sudo wp --allow-root plugin activate amazon-s3-and-cloudfront




