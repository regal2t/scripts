#!bin/bash

echo "updating device "
sudo apt-get update
echo "update done !"

echo "installing all dependencies"
sudo apt-get install nginx mysql-server php-fpm php-mysql php-xml php-mbstring wget curl zip unzip -y
echo " installation complete"

echo "download wordpress"
wget https://wordpress.org/latest.tar.gz
echo "done"

echo "unzip "
tar xzvf latest.tar.gz
echo "done"

echo "move to the workdir"
WP_DIR='/var/www/'
sudo mv wordpress $WP_DIR
echo "done"

echo "Setting up WordPress directory..."
sudo mv /tmp/wordpress $WP_DIR
sudo chown -R www-data:www-data $WP_DIR
sudo chmod -R 755 $WP_DIR
echo " wordpress done !!!"

DB_NAME='wordpress_db'
DB_USER='wordpress_user'
DB_PASS='password123'
DB_HOST='localhost'

echo " install mysql database and user with all  permission"

sudo mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
echo " database(name: $DB_NAME) created sucessfully"

sudo mysql -e "CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';"
echo " user (name: $DB_USER) created sucessfully"

sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';"
sudo mysql -e "FLUSH PRIVILEGES;"
echo " user permission done !!"

echo " database  done !!!"


echo " configure  nginx server"


sudo bash -c 'cat <<EOF > /etc/nginx/sites-available/wordpress
server {
    listen 80;
    server_name example.com; # Change this to your domain or IP address
    root /var/www/wordpress;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock; # Update PHP version if necessary
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF'

echo "setting up and restarting nginx"
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

echo "WordPress installation is complete!"
echo "you can check using url  http://localhost/ , http://localhost/wp_admin "

echo "if not working then first find php version  And then change here fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
on path /etc/nginx/sites-available/wordpress  . change according to the version you use "





