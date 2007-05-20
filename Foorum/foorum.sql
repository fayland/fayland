-- MySQL dump 10.10
--
-- Host: localhost    Database: foorum
-- ------------------------------------------------------
-- Server version	5.0.21-community-nt

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `board`
--

DROP TABLE IF EXISTS `board`;
CREATE TABLE `board` (
  `forum_id` int(11) default NULL,
  `page_id` int(11) default NULL,
  `squence` int(11) default NULL,
  `category_id` int(11) default NULL,
  UNIQUE KEY `forum_id` (`forum_id`)
);

--
-- Dumping data for table `board`
--


/*!40000 ALTER TABLE `board` DISABLE KEYS */;
LOCK TABLES `board` WRITE;
INSERT INTO `board` VALUES (1,1,1,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `board` ENABLE KEYS */;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `parent_id` int(11) default NULL,
  `level` tinyint(4) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `category`
--


/*!40000 ALTER TABLE `category` DISABLE KEYS */;
LOCK TABLES `category` WRITE;
INSERT INTO `category` VALUES (1,'Life',0,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `category` ENABLE KEYS */;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `comment_id` int(11) NOT NULL auto_increment,
  `reply_to` int(11) NOT NULL default '0',
  `text` text,
  `post_on` datetime default NULL,
  `update_on` datetime default NULL,
  `post_ip` varchar(32) default NULL,
  `formatter` varchar(16) default 'plain',
  `object_type` varchar(30) NOT NULL,
  `object_id` int(11) NOT NULL,
  `author_id` int(11) default NULL,
  `title` varchar(255) NOT NULL,
  `forum_id` int(11) default NULL,
  `upload_id` int(11) NOT NULL,
  PRIMARY KEY  (`comment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `comment`
--


/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
LOCK TABLES `comment` WRITE;
INSERT INTO `comment` VALUES (69,31,'sdasdsad','2006-12-24 10:45:38',NULL,'127.0.0.1','text','thread',31,11,'&lt;i&gt;sdasd&lt;/i&gt;',5,0),(57,0,'caxsc222222222222','2006-12-06 19:54:06',NULL,'222.137.241.70','text','thread',27,11,'xc2',6,0),(58,0,'33333333333333333','2006-12-06 19:54:14',NULL,'222.137.241.70','text','thread',28,11,'3',5,0),(59,0,'attachment a jpgds','2006-12-10 13:13:58','2006-12-17 09:18:57','127.0.0.1','text','thread',29,11,'attachment',5,0),(60,59,'xxxx','2006-12-10 13:52:34',NULL,'127.0.0.1','text','thread',29,11,'reply with attachment',5,3),(61,29,'xxxxxxxxxxxxx','2006-12-10 13:53:01',NULL,'127.0.0.1','text','thread',29,11,'xxxxxx',5,0),(62,29,'bbbbbbbbbbbbbbbbsdadsadsadsad','2006-12-10 14:04:44','2006-12-17 09:17:40','127.0.0.1','text','thread',29,11,'bbbbbbbasdddddddd',5,9),(63,0,'hi, all','2006-12-10 14:05:39',NULL,'127.0.0.1','text','user_profile',11,11,'hello',0,5),(64,0,'xxx','2006-12-10 14:10:20',NULL,'127.0.0.1','text','poll',1,11,'xx',6,6),(65,29,'sdaaaaaaa(with upload)4225','2006-12-16 11:46:11','2006-12-17 09:13:26','127.0.0.1','text','thread',29,11,'sdaaaaaaa(with upload)4645',5,0),(68,0,'<h1>hello</h1>','2006-12-24 10:43:46',NULL,'127.0.0.1','text','thread',31,11,'&lt;b&gt;new post&lt;/b&gt;',5,0),(70,0,'dsads','2006-12-24 10:45:58',NULL,'127.0.0.1','text','thread',32,11,'&lt;i&gt;sdasd&lt;/i&gt;',5,0),(71,0,'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx','2006-12-24 11:27:49',NULL,'127.0.0.1','text','thread',33,11,'xxxxxxxxxxxxxxx',6,0),(72,31,'xxxxxxxxxxxxxxxxxxxxx','2006-12-28 14:33:38',NULL,'222.137.238.67','text','thread',31,11,'xxxxxxxxxx',5,0),(73,0,'fdsfsddddddddddddxcxvcxcxcvvxcvxcvxcvxcvxcvxcvxcxcvvxcvxcvcx','2006-12-28 14:46:14',NULL,'222.137.238.67','text','announcement',5,11,'AAAXXXX',5,0),(74,0,' :bigsmile:  :inlove:  :sneaky2:  :Oo:  :mad:  :wow:  :sleeping: ','2006-12-30 14:26:15',NULL,'222.137.238.244','text','thread',34,11,'smile',6,0),(75,34,'xxxxxxxxxxx','2006-12-30 14:48:19',NULL,'222.137.238.244','text','thread',34,11,'xxxxxxxx',6,0),(76,0,'MMMMMMMMMMMMMMMMM :inlove:  :inlove:  :inlove: ','2007-05-07 20:04:40','2007-05-07 20:27:51','222.137.49.203','text','thread',35,11,'MMMMMMMMMMMMMMMMMM',5,10);
UNLOCK TABLES;
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;

--
-- Table structure for table `email_setting`
--

DROP TABLE IF EXISTS `email_setting`;
CREATE TABLE `email_setting` (
  `user_id` int(11) NOT NULL,
  `object_type` enum('comment','topic') NOT NULL,
  `frequence` enum('daily','weekly','none') NOT NULL,
  PRIMARY KEY  (`user_id`,`object_type`)
);

--
-- Dumping data for table `email_setting`
--


/*!40000 ALTER TABLE `email_setting` DISABLE KEYS */;
LOCK TABLES `email_setting` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `email_setting` ENABLE KEYS */;

--
-- Table structure for table `filter_word`
--

DROP TABLE IF EXISTS `filter_word`;
CREATE TABLE `filter_word` (
  `word` varchar(64) NOT NULL,
  `type` enum('username_reserved','forum_code_reserved') NOT NULL default 'username_reserved'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `filter_word`
--


/*!40000 ALTER TABLE `filter_word` DISABLE KEYS */;
LOCK TABLES `filter_word` WRITE;
INSERT INTO `filter_word` VALUES ('anonymous','username_reserved'),('guest','username_reserved'),('administrator','username_reserved'),('admin','username_reserved'),('moderator','username_reserved'),('system','username_reserved'),('members','forum_code_reserved'),('recent','forum_code_reserved');
UNLOCK TABLES;
/*!40000 ALTER TABLE `filter_word` ENABLE KEYS */;

--
-- Table structure for table `forum`
--

DROP TABLE IF EXISTS `forum`;
CREATE TABLE `forum` (
  `forum_id` int(11) NOT NULL auto_increment,
  `forum_code` varchar(25) default NULL,
  `name` varchar(100) default NULL,
  `description` varchar(100) default NULL,
  `forum_type` varchar(16) default NULL,
  `policy` enum('public','private','protected') NOT NULL default 'public',
  `total_members` int(8) unsigned NOT NULL,
  `total_topics` int(11) NOT NULL default '0',
  `total_replies` int(11) NOT NULL default '0',
  `last_post_id` int(11) default NULL,
  PRIMARY KEY  (`forum_id`)
);

--
-- Dumping data for table `forum`
--


/*!40000 ALTER TABLE `forum` DISABLE KEYS */;
LOCK TABLES `forum` WRITE;
INSERT INTO `forum` VALUES (6,'test2','xxxc','xczczxc','classical','private',3,3,1,34),(5,'forumname','fo&lt;font color=&quot;red&quot;&gt;rum&lt;/font&gt; name','descriptio&lt;a href=&quot;/&quot;&gt;n&lt;/a&gt;','classical','public',2,4,7,31),(8,'cn','China','China','country','public',0,0,0,0);
UNLOCK TABLES;
/*!40000 ALTER TABLE `forum` ENABLE KEYS */;

--
-- Table structure for table `log_action`
--

DROP TABLE IF EXISTS `log_action`;
CREATE TABLE log_action (
  user_id int(11) NOT NULL default '0',
  action varchar(24)    ,
  object_type varchar(12)    ,
  object_id int(11)    ,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,   
);

--
-- Table structure for table `log_path`
--

DROP TABLE IF EXISTS `log_path`;
CREATE TABLE `log_path` (
  `session_id` varchar(72) default NULL,
  `user_id` int(9) NOT NULL default '0',
  `path` varchar(255) NOT NULL default '',
  `get` varchar(255) default NULL,
  `post` varchar(255) default NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `loadtime` float(5,2) NOT NULL default '0.00',
  KEY `path` (`path`),
  KEY `session_id` (`session_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE log_error (
    error_id INT(11) NOT NULL AUTO_INCREMENT,
    level ENUM('info','debug','warn','error','fatal') NOT NULL DEFAULT 'debug' ,
    text TEXT NOT NULL ,
    time TIMESTAMP NOT NULL DEFAULT 'CURRENT_TIMESTAMP' , 
    PRIMARY KEY (error_id),
    KEY `level` (`level`)
);


--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `message_id` int(11) NOT NULL auto_increment,
  `from_id` int(11) default NULL,
  `to_id` int(11) default NULL,
  `title` varchar(255) NOT NULL,
  `text` text NOT NULL,
  `post_on` datetime NOT NULL,
  `post_ip` varchar(32) NOT NULL,
  `from_status` enum('open','deleted') NOT NULL default 'open',
  `to_status` enum('open','deleted') NOT NULL default 'open',
  PRIMARY KEY  (`message_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `message`
--


/*!40000 ALTER TABLE `message` DISABLE KEYS */;
LOCK TABLES `message` WRITE;
INSERT INTO `message` VALUES (1,1,2,'test','test','2006-05-23 14:16:43','10.163.81.54','open','open'),(2,1,2,'test2222222','test222222222222','2006-05-23 14:17:55','10.163.81.54','open','open'),(3,1,2,'test222222244','test2222222222224444444444','2006-05-23 14:20:55','10.163.81.54','open','open'),(4,2,2,'Re: test222222244','tesr','2006-05-29 12:50:52','169.254.232.205','open','open'),(5,2,1,'Re: test222222244','test','2006-05-29 12:53:13','169.254.232.205','open','open'),(6,1,2,'Re: Re: test222222244','åˆå£å‘¼çœ‹è§å¥½çœ‹','2006-05-29 12:53:38','169.254.232.205','open','open'),(7,4,4,'test','test','2006-08-06 03:17:13','10.163.89.142','open','open'),(8,4,2,'tttttttttt','ttttttttttttte','2006-08-06 04:38:58','10.163.89.142','open','open'),(10,11,12,'fayland','fayland','2007-04-15 13:21:54','127.0.0.1','open','open'),(11,12,11,'new','new messages.','2007-04-15 13:50:16','127.0.0.1','open','open');
UNLOCK TABLES;
/*!40000 ALTER TABLE `message` ENABLE KEYS */;

--
-- Table structure for table `message_unread`
--

DROP TABLE IF EXISTS `message_unread`;
CREATE TABLE `message_unread` (
  `message_id` int(11) default NULL,
  `user_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `message_unread`
--


/*!40000 ALTER TABLE `message_unread` DISABLE KEYS */;
LOCK TABLES `message_unread` WRITE;
INSERT INTO `message_unread` VALUES (10,12);
UNLOCK TABLES;
/*!40000 ALTER TABLE `message_unread` ENABLE KEYS */;

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
CREATE TABLE `page` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
);

--
-- Dumping data for table `page`
--


/*!40000 ALTER TABLE `page` DISABLE KEYS */;
LOCK TABLES `page` WRITE;
INSERT INTO `page` VALUES (1,'Page one');
UNLOCK TABLES;
/*!40000 ALTER TABLE `page` ENABLE KEYS */;

--
-- Table structure for table `poll`
--

DROP TABLE IF EXISTS `poll`;
CREATE TABLE `poll` (
  `poll_id` int(11) unsigned NOT NULL auto_increment,
  `forum_id` int(11) unsigned NOT NULL,
  `author_id` int(11) default NULL,
  `multi` enum('0','1') NOT NULL,
  `anonymous` enum('0','1') NOT NULL,
  `time` int(10) default NULL,
  `duration` int(10) default NULL,
  `vote_no` int(6) default NULL,
  `title` varchar(128) default NULL,
  PRIMARY KEY  (`poll_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `poll`
--


/*!40000 ALTER TABLE `poll` DISABLE KEYS */;
LOCK TABLES `poll` WRITE;
INSERT INTO `poll` VALUES (1,6,11,'0','0',1165730805,1166335605,0,'poll');
UNLOCK TABLES;
/*!40000 ALTER TABLE `poll` ENABLE KEYS */;

--
-- Table structure for table `poll_option`
--

DROP TABLE IF EXISTS `poll_option`;
CREATE TABLE `poll_option` (
  `option_id` int(11) unsigned NOT NULL auto_increment,
  `poll_id` int(11) default NULL,
  `text` varchar(255) default NULL,
  `vote_no` int(6) default NULL,
  PRIMARY KEY  (`option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `poll_option`
--


/*!40000 ALTER TABLE `poll_option` DISABLE KEYS */;
LOCK TABLES `poll_option` WRITE;
INSERT INTO `poll_option` VALUES (1,1,'2313213',0),(2,1,'231111111111',0);
UNLOCK TABLES;
/*!40000 ALTER TABLE `poll_option` ENABLE KEYS */;

--
-- Table structure for table `poll_result`
--

DROP TABLE IF EXISTS `poll_result`;
CREATE TABLE `poll_result` (
  `option_id` int(11) default NULL,
  `poll_id` int(11) default NULL,
  `poster_id` int(11) default NULL,
  `poster_ip` varchar(32) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `poll_result`
--


/*!40000 ALTER TABLE `poll_result` DISABLE KEYS */;
LOCK TABLES `poll_result` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `poll_result` ENABLE KEYS */;

--
-- Table structure for table `scheduled_email`
--

DROP TABLE IF EXISTS `scheduled_email`;
CREATE TABLE `scheduled_email` (
  `email_id` int(11) NOT NULL auto_increment,
  `email_type` varchar(24) default NULL,
  `processed` enum('Y','N') NOT NULL default 'N',
  `from_email` varchar(128) default NULL,
  `to_email` varchar(128) default NULL,
  `subject` varchar(256) default NULL,
  `plain_body` text,
  `html_body` text,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`email_id`),
  KEY `processed` (`processed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `scheduled_email`
--


/*!40000 ALTER TABLE `scheduled_email` DISABLE KEYS */;
LOCK TABLES `scheduled_email` WRITE;
INSERT INTO `scheduled_email` VALUES (1,'forget_password','N','fayland@gmail.com','testman@gmail.com','Your Password For testman In Foorum (Be Together)','Dear testman,\n\nYour new password is jYdfm6VSty\nPlease use this password to login:http://fayland:3000/register/activation/testman/\nPlease use this url to change your password:http://fayland:3000//profile/change_password\n\nThanks.\n\nBest Regards,\nYours, Foorum (Be Together)',NULL,'2007-05-19 11:35:35'),(2,'forget_password','N','fayland@gmail.com','testman@gmail.com','Your Password For testman In Foorum (Be Together)','Dear testman,\n\nYour new password is gHY87xWXEx\nPlease use this password to login:http://fayland:3000/register/activation/testman/\nPlease use this url to change your password:http://fayland:3000//profile/change_password\n\nThanks.\n\nBest Regards,\nYours, Foorum (Be Together)',NULL,'2007-05-19 12:36:46'),(3,'forget_password','N','fayland@gmail.com','testman@gmail.com','Your Password For testman In Foorum (Be Together)','Dear testman,\n\nYour new password is NQ0BGYLdSI\nPlease use this password to login:http://fayland:3000/register/activation/testman/\nPlease use this url to change your password:http://fayland:3000//profile/change_password\n\nThanks.\n\nBest Regards,\nYours, Foorum (Be Together)',NULL,'2007-05-19 12:42:49'),(4,'forget_password','N','fayland@gmail.com','testman@gmail.com','Your Password For testman In Foorum (Be Together)','Dear testman,\n\nYour new password is 4sixoWk0yp\nPlease use this password to login:http://fayland:3000/register/activation/testman/\nPlease use this url to change your password:http://fayland:3000//profile/change_password\n\nThanks.\n\nBest Regards,\nYours, Foorum (Be Together)',NULL,'2007-05-19 12:44:29'),(5,'forget_password','N','fayland@gmail.com','testman@gmail.com','Your Password For testman In Foorum (Be Together)','Dear testman,\n\nYour new password is YKGvMoeMbG\nPlease use this password to login:http://fayland:3000/register/activation/testman/\nPlease use this url to change your password:http://fayland:3000//profile/change_password\n\nThanks.\n\nBest Regards,\nYours, Foorum (Be Together)',NULL,'2007-05-19 12:44:48');
UNLOCK TABLES;
/*!40000 ALTER TABLE `scheduled_email` ENABLE KEYS */;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
CREATE TABLE `session` (
  `id` char(72) NOT NULL,
  `session_data` text,
  `expires` int(11) default '0',
  `user_id` int(11) default NULL,
  `path` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
);

--
-- Dumping data for table `session`
--


/*!40000 ALTER TABLE `session` DISABLE KEYS */;
LOCK TABLES `session` WRITE;
INSERT INTO `session` VALUES ('session:a977a525c888d9a5b91d89651e0f19d27f5ab050','BQcDAAAAAglGTm8oAAAACV9fY3JlYXRlZAlGTm8pAAAACV9fdXBkYXRlZA==\n',1180155466,NULL,'login');
UNLOCK TABLES;
/*!40000 ALTER TABLE `session` ENABLE KEYS */;

--
-- Table structure for table `star`
--

DROP TABLE IF EXISTS `star`;
CREATE TABLE `star` (
  `user_id` int(11) unsigned NOT NULL,
  `object_type` varchar(12) default NULL,
  `object_id` int(11) default NULL,
  `time` int(10) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `star`
--


/*!40000 ALTER TABLE `star` DISABLE KEYS */;
LOCK TABLES `star` WRITE;
INSERT INTO `star` VALUES (11,'topic',29,1166238862),(11,'topic',31,1167294269);
UNLOCK TABLES;
/*!40000 ALTER TABLE `star` ENABLE KEYS */;

--
-- Table structure for table `topic`
--

DROP TABLE IF EXISTS `topic`;
CREATE TABLE `topic` (
  `topic_id` int(11) NOT NULL auto_increment,
  `forum_id` int(4) default NULL,
  `title` varchar(255) default NULL,
  `closed` enum('0','1') NOT NULL default '0',
  `sticky` enum('0','1') NOT NULL default '0',
  `elite` enum('0','1') NOT NULL,
  `hit` int(11) NOT NULL default '0',
  `last_updator_id` int(11) default NULL,
  `last_update_date` datetime NOT NULL,
  `author_id` int(11) NOT NULL,
  `total_replies` int(11) NOT NULL default '0',
  PRIMARY KEY  (`topic_id`)
);

--
-- Dumping data for table `topic`
--


/*!40000 ALTER TABLE `topic` DISABLE KEYS */;
LOCK TABLES `topic` WRITE;
INSERT INTO `topic` VALUES (34,6,'smile','1','0','0',9,11,'2006-12-30 14:48:19',11,1),(35,5,'MMMMMMMMMMMMMMMMMM','0','0','0',9,11,'2007-05-07 20:04:40',11,0),(33,6,'xxxxxxxxxxxxxxx','0','0','0',3,11,'2006-12-24 11:27:49',11,0),(29,5,'attachment','0','0','1',82,11,'2006-12-16 11:46:11',11,4),(28,5,'3','1','0','0',8,11,'2006-12-06 19:54:14',11,0),(27,6,'xc2','0','0','0',2,11,'2006-12-06 19:54:06',11,0),(31,5,'<b>new post</b>','0','1','0',29,11,'2006-12-28 14:33:38',11,2),(32,5,'&lt;i&gt;sdasd&lt;/i&gt;','0','0','0',8,11,'2006-12-24 10:45:58',11,0);
UNLOCK TABLES;
/*!40000 ALTER TABLE `topic` ENABLE KEYS */;

--
-- Table structure for table `upload`
--

DROP TABLE IF EXISTS `upload`;
CREATE TABLE `upload` (
  `upload_id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `forum_id` int(11) default NULL,
  `filename` varchar(36) default NULL,
  `filesize` float(6,1) default NULL,
  `filetype` varchar(4) default NULL,
  PRIMARY KEY  (`upload_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `upload`
--


/*!40000 ALTER TABLE `upload` DISABLE KEYS */;
LOCK TABLES `upload` WRITE;
INSERT INTO `upload` VALUES (1,11,5,'_C4405AD6-D20B-4510-B9C5-A6585.jpg',50.0,'jpg'),(3,11,5,'1.txt',0.2,'txt'),(5,11,0,'wt6IlRu3TlNTinD.jpg',50.0,'jpg'),(6,11,6,'XUFMfsWPknd91FD.jpg',50.0,'jpg'),(9,11,5,'61.gif',1.6,'gif'),(10,11,7,'butsts.gif',0.5,'gif');
UNLOCK TABLES;
/*!40000 ALTER TABLE `upload` ENABLE KEYS */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id` int(11) NOT NULL auto_increment,
  `username` varchar(32) default NULL,
  `password` varchar(32) default NULL,
  `nickname` varchar(100) default NULL,
  `gender` enum('F','M','') default NULL,
  `email` varchar(255) default NULL,
  `register_on` date default NULL,
  `register_ip` varchar(32) default NULL,
  `active_code` char(10) default NULL,
  `last_login_on` datetime default NULL,
  `last_login_ip` varchar(32) default NULL,
  `has_actived` smallint(1) default NULL,
  `login_times` int(11) default '1',
  `status` varchar(16) default NULL,
  `threads` int(11) NOT NULL default '0',
  `replies` int(11) NOT NULL default '0',
  `last_post_id` int(11) default NULL,
  `lang` char(2) default 'cn',
  `country` char(2) default NULL,
  `state_id` int(11) default NULL,
  `city_id` int(11) default NULL,
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `username` (`username`)
);

--
-- Dumping data for table `user`
--


/*!40000 ALTER TABLE `user` DISABLE KEYS */;
LOCK TABLES `user` WRITE;
INSERT INTO `user` VALUES (11,'fayland','p5/AÚOóÃ\"	JðhºpÃ³‹','fayland_lam','M','fayland@gmail.com','2006-08-27','222.137.238.13','','2007-05-10 20:37:37','222.137.49.211',1,42,NULL,818,119,35,'cn','cn',NULL,NULL),(6,'testman','M±Ú²x2%Ìe”\'Äæiíö™°Î','testman',NULL,'testman@gmail.com','2006-08-18','127.0.0.1','','2006-12-24 10:54:00','127.0.0.1',1,2,NULL,0,0,NULL,'en',NULL,NULL,NULL),(7,'shelly','p5/AÚOóÃ\"	JðhºpÃ³‹','sheyll',NULL,'shellybaby@gmai.com','2006-08-18','127.0.0.1','','2006-08-18 13:21:11','127.0.0.1',1,2,NULL,0,0,NULL,'en',NULL,NULL,NULL),(12,'faylandxx','p5/AÚOóÃ\"	JðhºpÃ³‹','faylandxx',NULL,'faylandxx@gmail.com','2006-11-18','222.137.238.177',NULL,'2007-04-15 13:49:42','127.0.0.1',1,5,NULL,0,0,NULL,'en',NULL,NULL,NULL),(13,'damnyuruihua','p5/AÚOóÃ\"	JðhºpÃ³‹','hahaha',NULL,'faylandda@gmail.com','2006-12-03','127.0.0.1',NULL,NULL,NULL,1,1,NULL,0,0,NULL,'en',NULL,NULL,NULL);
UNLOCK TABLES;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;

--
-- Table structure for table `user_details`
--

DROP TABLE IF EXISTS `user_details`;
CREATE TABLE `user_details` (
  `user_id` int(11) NOT NULL default '0',
  `qq` varchar(14) default NULL,
  `msn` varchar(64) default NULL,
  `yahoo` varchar(64) default NULL,
  `skype` varchar(64) default NULL,
  `gtalk` varchar(64) default NULL,
  `homepage` varchar(255) default NULL,
  `birthday` date default NULL,
  PRIMARY KEY  (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user_details`
--


/*!40000 ALTER TABLE `user_details` DISABLE KEYS */;
LOCK TABLES `user_details` WRITE;
INSERT INTO `user_details` VALUES (11,'25933211','fayland@gmail.com','fayland_lam','fayland_lam','fayland','http://www.fayland.org','1984-02-06');
UNLOCK TABLES;
/*!40000 ALTER TABLE `user_details` ENABLE KEYS */;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role` (
  `user_id` int(11) default NULL,
  `role` enum('admin','moderator','user','blocked','pending','rejected') default 'user',
  `field` varchar(32) NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `field` (`field`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user_role`
--


/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
LOCK TABLES `user_role` WRITE;
INSERT INTO `user_role` VALUES (3,'admin','site'),(4,'admin','site'),(11,'admin','site'),(11,'admin','5'),(7,'admin','6'),(12,'moderator','6'),(6,'moderator','6'),(13,'moderator','5');
UNLOCK TABLES;
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;

--
-- Table structure for table `visit`
--

DROP TABLE IF EXISTS `visit`;
CREATE TABLE `visit` (
  `user_id` int(11) default NULL,
  `object_type` varchar(12) default NULL,
  `object_id` int(11) default NULL,
  `time` int(10) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `visit`
--


/*!40000 ALTER TABLE `visit` DISABLE KEYS */;
LOCK TABLES `visit` WRITE;
INSERT INTO `visit` VALUES (11,'thread',31,1178540684),(11,'thread',35,1178800968);
UNLOCK TABLES;
/*!40000 ALTER TABLE `visit` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

