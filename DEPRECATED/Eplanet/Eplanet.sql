use Eplanet;

CREATE TABLE category (
 cat_id int(3) NOT NULL auto_increment,
 cat_name varchar(20) NOT NULL default '',
 PRIMARY KEY  (cat_id)
);

INSERT INTO category VALUES (1, 'Basic');
INSERT INTO category VALUES (2, 'InstallNote');
INSERT INTO category VALUES (3, 'Miscellaneous');
INSERT INTO category VALUES (4, 'Translation');
INSERT INTO category VALUES (5, 'Modules');
INSERT INTO category VALUES (6, 'Script');
INSERT INTO category VALUES (7, 'Diary');

CREATE TABLE cms (
 cms_id int(11) NOT NULL auto_increment,
 cms_file varchar(25) NOT NULL default '',
 cms_cat_id int(4) NOT NULL default '0',
 cms_title varchar(80) NOT NULL default '',
 cms_describe text NOT NULL,
 cms_text text NOT NULL,
 cms_cre_data datetime NOT NULL default '0000-00-00 00:00:00',
 cms_mod_data datetime default NULL,
 cms_keywords varchar(50) NOT NULL default '',
 cms_subdir varchar(40) NOT NULL default 'journal',
 cms_formatter varchar(20) default NULL,
 PRIMARY KEY  (cms_id),
 UNIQUE KEY cms_file (cms_file)
);