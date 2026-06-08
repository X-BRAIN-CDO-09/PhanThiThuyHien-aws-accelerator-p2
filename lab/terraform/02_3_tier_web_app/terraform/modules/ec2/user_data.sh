#!/bin/bash

yum update -y
yum install -y httpd git unzip mysql

amazon-linux-extras enable php8.2
yum clean metadata
yum install -y php php-cli php-mbstring php-xml php-bcmath php-curl php-mysqlnd php-zip php-gd

export HOME=/root
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

systemctl start httpd
systemctl enable httpd

cd /var/www
git clone https://github.com/coconerd/iBeleaf.git ibeleaf
cd ibeleaf

cat > .env <<EOF
APP_NAME=iBeleaf
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=${db_host}
DB_PORT=3306
DB_DATABASE=${db_name}
DB_USERNAME=${db_user}
DB_PASSWORD=${db_password}
EOF

composer install --no-dev --optimize-autoloader
php artisan key:generate --force

npm install
npm run build

mysql -h ${db_host} -u ${db_user} -p${db_password} ${db_name} < plant_paradise_final.sql

chown -R apache:apache /var/www/ibeleaf
chmod -R 775 storage bootstrap/cache

cat > /etc/httpd/conf.d/ibeleaf.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/ibeleaf/public

    <Directory /var/www/ibeleaf/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/ibeleaf-error.log
    CustomLog /var/log/httpd/ibeleaf-access.log combined
</VirtualHost>
EOF

sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

systemctl restart httpd