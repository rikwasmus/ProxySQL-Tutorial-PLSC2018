CREATE DATABASE perconalive;
USE perconalive;
CREATE TABLE customer (id tinyint unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY, sensitive_number char(12));
CREATE TABLE audit (id tinyint unsigned  NOT NULL AUTO_INCREMENT PRIMARY KEY, table_name varchar(25), user_name varchar(255), insert_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);

# INSERT INTO customer VALUES (NULL, '123-45-6321');