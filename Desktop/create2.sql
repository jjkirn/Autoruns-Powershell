CREATE TABLE ar_data (
fname VARCHAR(64) NULL,
mydate DATE,
mytime TIME,
id_hash VARCHAR(64),
ar_entryloc VARCHAR(256),
ar_entry VARCHAR(128),
ar_enabled VARCHAR(32),
ar_category VARCHAR(64),
ar_profile VARCHAR(32),
ar_desc VARCHAR(512),
ar_signer VARCHAR(256),
ar_company VARCHAR(64),
ar_ipath VARCHAR(256),
ar_ver VARCHAR(32),
ar_lstr VARCHAR(256),
ar_hash VARCHAR(256),
PRIMARY KEY (id_hash)
);

