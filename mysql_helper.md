## Install and configure MySQL guide

Killing MySQL in safe mode.

```shell
sudo mysqladmin shutdown
```

Completely remove MySQL

```shell
sudo apt-get remove --purge mysql*
sudo apt-get purge mysql*
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get remove dbconfig-mysql
sudo apt-get dist-upgrade

sudo apt-get purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
sudo rm -rf /etc/mysql /var/lib/mysql
```

Install fresh MySQL

```shell
sudo apt-get update
sudo apt-get install mysql-server
```

If the secure installation utility does not launch automatically after 
the installation completes, enter the following command:

```shell
sudo mysql_secure_installation utility
```

Launch MySQL under root

```shell
sudo mysql -u root -p
```

Add new database

```sql
CREATE DATABASE <name_of_database>;
SHOW DATABASES;
```

Add new user on localhost

```sql
CREATE USER 'demouser'@'localhost' IDENTIFIED BY 'newpassword';
FLUSH PRIVELEGES;
SELECT User, Host FROM mysql.user;
```

To add new user on Ipv6 start from checking the Ipv6 on both the client and
the server side. Visit [www.icanhazip.com](https:://www.icanhazip.com)

```sql
CREATE USER 'newuser'@'<ip_adress>' IDENTIFIED BY 'newpassword';
FLUSH PRIVILEGES;
```

Give new user read-only permissions on specific data base

```sql
GRANT SELECT ON `demodb`.* TO 'demouser'@'localhost';
FLUSH PRIVILEGES;
```

Allow remote access from Ipv6

```shell
sudo ufw enable
sudo ufw allow mysql

sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
bind-address = *

mysql -h <ip_address> -u newuser -p
```

Create new table

```sql
CREATE TABLE newtable(
	column1 VARCHAR(20) PRIMARY KEY, 
	column2 DATE, 
	column3 TIMESTAMP
);
```

Populate table from csv could be a bit tricky in `Ubuntu`. The OS protects the
folders from being accessed by `MySQL`. There is a walk around by creating the
folder in the root.

```shell
cd /
sudo mkdir /sqlfiles
sudo chown mysql:mysql /sqlfiles
```

In `/etc/mysql/mysql.conf.d/mysql.cnf` at the end of [mysqld] section add line
`secure-file-priv = /sqlfiles`. In `/etc/apparmor.d/local/usr.sbin.mysqld` add 
these lines: `/sqlfiles/ r`, `/sqlfiles/** rwk`, `sudo service apparmor restart`,

Move files to new folder by executing `sudo cp -i <from> <to>`

Load raw data into the data base table. Ignore the first row if it contains 
headers.

```sql
LOAD DATA INFILE '<root folder>' 
INTO TABLE <name_of_table> 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;
```

Add and remove primary key

```sql
ALTER TABLE prod_rep DROP PRIMARY KEY;
ALTER TABLE prod_rep MODIFY date_time DATETIME NOT NULL PRIMARY KEY AUTO_INCREMENT;
```