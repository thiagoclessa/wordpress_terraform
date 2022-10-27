sudo -i
apt get install epel-release apt get-utils wget -y
apt get install php php-mysql -y
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp -r wordpress/* /var/www/html/
chown -R apache:apache /var/www/html
service restart httpdd