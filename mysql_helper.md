## Killing MySQL in safe mode

sudo mysqladmin shutdown


## Completely remove MySQL

sudo apt-get remove --purge mysql*
sudo apt-get purge mysql*
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get remove dbconfig-mysql
sudo apt-get dist-upgrade

sudo apt-get purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
sudo rm -rf /etc/mysql /var/lib/mysql


## Install fresh MySQL

sudo apt-get update
sudo apt-get install mysql-server

If the secure installation utility does not launch automatically after 
the installation completes, enter the following command:

sudo mysql_secure_installation utility


## Launch MySQL under root

sudo mysql -u root -p


## Add new database

CREATE DATABASE <name_of_database>;
SHOW DATABASES;


## Add new user on localhost

CREATE USER 'demouser'@'localhost' IDENTIFIED BY 'newpassword';
FLUSH PRIVELEGES;
SELECT User, Host FROM mysql.user;


## Add new user on Ipv6

www.icanhazip.com

CREATE USER 'newuser'@'<ip_adress>' IDENTIFIED BY 'newpassword';
FLUSH PRIVILEGES;


## Give new user read-only permissions

GRANT SELECT ON `demodb`.* TO 'demouser'@'localhost';
FLUSH PRIVILEGES;


## Allow remote access from Ipv6

sudo ufw enable
sudo ufw allow mysql

sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
bind-address = *

mysql -h <ip_address> -u newuser -p


## Create table

CREATE TABLE newtable(
	column1 VARCHAR(20) PRIMARY KEY, 
	column2 DATE, 
	column3 TIMESTAMP
);


## Populate table from csv

cd /
sudo mkdir /sqlfiles
sudo chown mysql:mysql /sqlfiles

In /etc/mysql/mysql.conf.d/mysql.cnf
at the end of [mysqld] section add line
secure-file-priv = /sqlfiles

In /etc/apparmor.d/local/usr.sbin.mysqld 
add these lines:
/sqlfiles/ r,
/sqlfiles/** rwk,

sudo service apparmor restart


sudo cp -i <from> <to>

LOAD DATA INFILE '/sqlfiles/production_reports.csv' INTO TABLE prod_rep FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;


## Add and remove primary key

ALTER TABLE prod_rep DROP PRIMARY KEY;
ALTER TABLE prod_rep MODIFY date_time DATETIME NOT NULL PRIMARY KEY AUTO_INCREMENT;










