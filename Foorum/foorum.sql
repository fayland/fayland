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
-- Table structure for table `banned_ip`
--

DROP TABLE IF EXISTS `banned_ip`;
CREATE TABLE banned_ip (
  ip_id int(11)    auto_increment,
  cidr_ip varchar(20)  DEFAULT ''  ,
  time int(11)    ,
  PRIMARY KEY (ip_id)
);

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
) DEFAULT CHARSET=utf8;

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
  `formatter` varchar(16) default 'ubb',
  `object_type` varchar(30) NOT NULL,
  `object_id` int(11) NOT NULL,
  `author_id` int(11) default NULL,
  `title` varchar(255) NOT NULL,
  `forum_id` int(11) default NULL,
  `upload_id` int(11) NOT NULL,
  PRIMARY KEY  (`comment_id`)
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `comment`
--


/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
LOCK TABLES `comment` WRITE;
INSERT INTO `comment` VALUES (69,31,'sdasdsad','2006-12-24 10:45:38',NULL,'127.0.0.1','ubb','thread',31,11,'&lt;i&gt;sdasd&lt;/i&gt;',5,0),(57,0,'caxsc222222222222','2006-12-06 19:54:06',NULL,'222.137.241.70','ubb','thread',27,11,'xc2',6,0),(59,0,'attachment a jpgds','2006-12-10 13:13:58','2006-12-17 09:18:57','127.0.0.1','ubb','thread',29,11,'attachment',5,0),(60,59,'xxxx','2006-12-10 13:52:34',NULL,'127.0.0.1','ubb','thread',29,11,'reply with attachment',5,3),(61,29,'xxxxxxxxxxxxx','2006-12-10 13:53:01',NULL,'127.0.0.1','ubb','thread',29,11,'xxxxxx',5,0),(62,29,'bbbbbbbbbbbbbbbbsdadsadsadsad','2006-12-10 14:04:44','2006-12-17 09:17:40','127.0.0.1','ubb','thread',29,11,'bbbbbbbasdddddddd',5,9),(63,0,'hi, all','2006-12-10 14:05:39',NULL,'127.0.0.1','ubb','user_profile',11,11,'hello',0,5),(64,0,'xxx','2006-12-10 14:10:20',NULL,'127.0.0.1','ubb','poll',1,11,'xx',6,6),(65,29,'sdaaaaaaa(with upload)4225','2006-12-16 11:46:11','2006-12-17 09:13:26','127.0.0.1','ubb','thread',29,11,'sdaaaaaaa(with upload)4645',5,0),(68,0,'<h1>hello</h1>','2006-12-24 10:43:46',NULL,'127.0.0.1','ubb','thread',31,11,'&lt;b&gt;new post&lt;/b&gt;',5,0),(70,0,'dsads','2006-12-24 10:45:58',NULL,'127.0.0.1','ubb','thread',32,11,'&lt;i&gt;sdasd&lt;/i&gt;',5,0),(71,0,'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx','2006-12-24 11:27:49',NULL,'127.0.0.1','ubb','thread',33,11,'xxxxxxxxxxxxxxx',6,0),(72,31,'xxxxxxxxxxxxxxxxxxxxx','2006-12-28 14:33:38',NULL,'222.137.238.67','ubb','thread',31,11,'xxxxxxxxxx',5,0),(73,0,'fdsfsddddddddddddxcxvcxcxcvvxcvxcvxcvxcvxcvxcvxcxcvvxcvxcvcx','2006-12-28 14:46:14',NULL,'222.137.238.67','ubb','announcement',5,11,'AAAXXXX',5,0),(74,0,' :bigsmile:  :inlove:  :sneaky2:  :Oo:  :mad:  :wow:  :sleeping: ','2006-12-30 14:26:15',NULL,'222.137.238.244','ubb','thread',34,11,'smile',6,0),(75,34,'xxxxxxxxxxx','2006-12-30 14:48:19',NULL,'222.137.238.244','ubb','thread',34,11,'xxxxxxxx',6,0),(76,0,'MMMMMMMMMMMMMMMMM :inlove:  :inlove:  :inlove: ','2007-05-07 20:04:40','2007-05-07 20:27:51','222.137.49.203','ubb','thread',35,11,'MMMMMMMMMMMMMMMMMM',5,10),(77,0,'test text.','2007-05-19 14:47:07',NULL,'127.0.0.1','ubb','user_profile',11,11,'test title',0,0),(78,0,'we have 2 ways to call. and 4 params.\r\n\r\nexamples:\r\n\r\n$c->detach(\'/print_message\', [ \'Error\' ] );\r\n\r\n\r\n# this way, fresh_time is the seconds to wait to reload\r\n$c->detach(\'/print_message\', [ { msg => \'Error\', url => $url, refresh_time => 10 } ]);\r\n\r\n\r\n# if we have stay_in_page, we don\'t reload the page automatically.\r\n$c->detach(\'/print_message\', [ { msg => \'Error\', url => $url, stay_in_page => 1 } ] );\r\n\r\n\r\nenjoy!\r\n\r\n:inlove:\r\n','2007-05-19 15:40:44',NULL,'127.0.0.1','ubb','thread',36,11,'print_message calling',10,0),(79,36,'print_error ways:\r\n\r\n$c->detach(\'/print_error\', [ \'Error\' ] );\r\n\r\n$c->detach(\'/print_error\', [ { msg => $msg } ]);','2007-05-19 15:52:11',NULL,'127.0.0.1','ubb','thread',36,11,'print_error',10,0),(80,0,'Scalable is the most important thing for Foorum.\r\n\r\nwe are planning to use some amazing technology to develop Foorum:\r\n\r\n* Memcached for backend caching \r\n* MogileFS  for uploaded images\r\n* Perlbal for load balance\r\n* Gearman for cron scripts\r\n\r\nyup, all technologies from grat LiveJournal.','2007-05-19 16:00:42','2007-05-19 16:01:05','127.0.0.1','ubb','thread',37,11,'our aim of Foorum',11,0),(81,37,'L18N, standard .po file\r\n\r\ncountry/$countryname Forum\r\ncountry/$countryname/state/$statename\r\ncountry/$countryname/state/$statename/city/$cityname\r\n\r\nword/$word\r\npeople/$people\r\n\r\nwell, somehow it\'s a bit complex.','2007-05-19 16:03:32',NULL,'127.0.0.1','ubb','thread',37,11,'the functions of Foorum in plan',11,0),(82,0,'ubb [b]ubb[/b]\r\n[url=http://fayland.org]fayland.org[/url]','2007-05-26 07:37:42',NULL,'222.137.49.203','ubb','thread',38,11,'ubb',5,0),(83,0,'hey baby, that\'s a new topic.\r\n\r\n\r\n :dozingoff:  :inlove:  :tounge: \r\n\r\n[b]haha[/b]','2007-05-26 13:22:33','2007-05-26 13:27:48','127.0.0.1','text','thread',39,11,'new topic',5,11),(84,83,'fuck you!  :inlove: ','2007-05-26 13:33:51',NULL,'127.0.0.1','ubb','thread',39,11,'boy, fuck you',5,0),(85,39,'FLG','2007-05-26 13:34:21',NULL,'127.0.0.1','ubb','thread',39,11,'FLG',5,0),(86,0,'hey','2007-05-26 13:51:15',NULL,'127.0.0.1','ubb','user_profile',7,11,'hello kitty',0,0),(87,37,'the functions are changed now.\r\n\r\nwe are not going to develop country/* stuff and word/$word and people/$people any more.','2007-05-26 13:58:14',NULL,'127.0.0.1','ubb','thread',37,11,'mmm',11,0);
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
  `type` enum('username_reserved','forum_code_reserved','bad_email_domain','offensive_word','bad_word') default 'username_reserved'
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `filter_word`
--


/*!40000 ALTER TABLE `filter_word` DISABLE KEYS */;
LOCK TABLES `filter_word` WRITE;
INSERT INTO `filter_word` VALUES ('anonymous','username_reserved'),('guest','username_reserved'),('administrator','username_reserved'),('admin','username_reserved'),('moderator','username_reserved'),('system','username_reserved'),('members','forum_code_reserved'),('recent','forum_code_reserved'),('elite','forum_code_reserved'),('fuck','offensive_word'),('asshole','offensive_word'),('foorum','username_reserved'),('FLG','bad_word');
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
  status enum('healthy','banned','deleted')  DEFAULT 'healthy'  ,
  PRIMARY KEY  (`forum_id`)
);

--
-- Dumping data for table `forum`
--


/*!40000 ALTER TABLE `forum` DISABLE KEYS */;
LOCK TABLES `forum` WRITE;
INSERT INTO `forum` VALUES (6,'FoorumPrivate','Foorum Private Foorum Testing','It\'s a Private Forum.','classical','private',3,3,1,34),(5,'FoorumTest','Foorum Testing','Foorum Testing Forum.','classical','public',2,5,9,39),(8,'cn','China','China','country','public',0,0,0,0),(11,'FoorumDiscussion','Foorum Discussion','discuss all about Foorum','classical','public',1,1,2,37),(10,'FoorumSupport','Foorum Support','plugins, code explaination','classical','public',1,1,1,36),(12,'Stock','Stock Duscussion','damn it','word','public',0,0,0,0);
UNLOCK TABLES;
/*!40000 ALTER TABLE `forum` ENABLE KEYS */;

--
-- Table structure for table `log_action`
--

DROP TABLE IF EXISTS `log_action`;
CREATE TABLE `log_action` (
  `user_id` int(11) NOT NULL default '0',
  `action` varchar(24) default NULL,
  `object_type` varchar(12) default NULL,
  `object_id` int(11) default NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `text` text,
  `forum_id` int(11) NOT NULL,
  KEY `user_id` (`user_id`),
  KEY `forum_id` (`forum_id`)
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `log_action`
--


/*!40000 ALTER TABLE `log_action` DISABLE KEYS */;
LOCK TABLES `log_action` WRITE;
INSERT INTO `log_action` VALUES (11,'lock','topic',35,'2007-05-19 05:21:46',NULL,0),(11,'top','topic',37,'2007-06-03 01:14:25',NULL,0),(11,'lock','topic',37,'2007-06-03 01:36:05',NULL,0),(11,'elite','topic',37,'2007-06-03 01:36:14',NULL,0),(11,'unsticky','topic',37,'2007-06-03 01:36:30',NULL,0),(11,'sticky','topic',37,'2007-06-03 01:36:38',NULL,0),(11,'elite','topic',39,'2007-06-03 06:50:23',NULL,5),(11,'lock','topic',38,'2007-06-03 06:50:32',NULL,5),(11,'unelite','topic',39,'2007-06-03 07:03:59',NULL,5),(11,'unlock','topic',38,'2007-06-03 07:04:07',NULL,5),(11,'delete','topic',28,'2007-06-03 07:04:41',NULL,5),(11,'elite','topic',39,'2007-06-03 07:05:06','new topic',5),(11,'lock','topic',38,'2007-06-03 07:05:14','ubb',5),(11,'delete','topic',40,'2007-06-03 07:05:35','tesd',5);
UNLOCK TABLES;
/*!40000 ALTER TABLE `log_action` ENABLE KEYS */;

--
-- Table structure for table `log_error`
--

DROP TABLE IF EXISTS `log_error`;
CREATE TABLE `log_error` (
  `error_id` int(11) NOT NULL auto_increment,
  `level` enum('info','debug','warn','error','fatal') NOT NULL default 'debug',
  `text` text NOT NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`error_id`),
  KEY `level` (`level`)
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `log_error`
--


/*!40000 ALTER TABLE `log_error` DISABLE KEYS */;
LOCK TABLES `log_error` WRITE;
INSERT INTO `log_error` VALUES (1,'info','remove_session_dbic.pl - status: 1 @ Sun May 20 19:57:31 2007\n','2007-05-20 11:57:31'),(2,'info','remove_db_old_data.pl - status: visit - 1, log_path - 1 @ Sun May 20 21:47:30 2007\n','2007-05-20 13:47:30'),(3,'info','cron\\remove_db_old_data.pl - status: visit - 1, log_path - 1 @ Sun May 20 21:51:06 2007\n','2007-05-20 13:51:06'),(4,'info','cron\\remove_db_old_data.pl - status:\n visit - 1\n log_path - 1\n log_error - 1 @ Sun May 20 21:55:03 2007\n','2007-05-20 13:55:03'),(5,'info','cron\\remove_db_old_data.pl - status:\n    visit - 1\n    log_path - 1\n    log_error - 1\n','2007-05-20 13:59:25'),(6,'info','cron\\remove_db_old_data.pl - status:\n    visit - 1\n    log_path - 1\n    log_error - 1\n','2007-05-20 14:02:57'),(7,'info','cron\\remove_db_old_data.pl - status:\n    visit - 1\n    log_path - 1\n    log_error - 1\n','2007-05-20 14:06:19');
UNLOCK TABLES;
/*!40000 ALTER TABLE `log_error` ENABLE KEYS */;

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
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `log_path`
--


/*!40000 ALTER TABLE `log_path` DISABLE KEYS */;
LOCK TABLES `log_path` WRITE;
INSERT INTO `log_path` VALUES ('34',33,'32313','2323','23','2007-05-20 13:49:10',231.00),('7dc0244087dd919a2cea2985f78625bfce20c758',0,'index',NULL,'','2007-05-22 00:50:48',5.65),('28421a13484ab87ca492e2222b6d60211a532417',0,'index',NULL,'','2007-05-22 00:56:41',2.39),('142adcde8cf5bea4b1aa3ccad25aae9a6839f5cf',0,'index',NULL,'','2007-05-25 09:48:22',2.87),('1dc58c8725f8df3b066d8737346cde8608f9d863',11,'forum/forumname/38',NULL,'','2007-05-26 01:04:39',2.03),('5022610fb4f2c6c0d5f01edfbe3073c12009c4f4',0,'index',NULL,'','2007-06-03 01:01:09',2.65);
UNLOCK TABLES;
/*!40000 ALTER TABLE `log_path` ENABLE KEYS */;

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
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `message`
--


/*!40000 ALTER TABLE `message` DISABLE KEYS */;
LOCK TABLES `message` WRITE;
INSERT INTO `message` VALUES (1,1,2,'test','test','2006-05-23 14:16:43','10.163.81.54','open','open'),(2,1,2,'test2222222','test222222222222','2006-05-23 14:17:55','10.163.81.54','open','open'),(3,1,2,'test222222244','test2222222222224444444444','2006-05-23 14:20:55','10.163.81.54','open','open'),(4,2,2,'Re: test222222244','tesr','2006-05-29 12:50:52','169.254.232.205','open','open'),(5,2,1,'Re: test222222244','test','2006-05-29 12:53:13','169.254.232.205','open','open'),(6,1,2,'Re: Re: test222222244','åˆå£å‘¼çœ‹è§å¥½çœ‹','2006-05-29 12:53:38','169.254.232.205','open','open'),(7,4,4,'test','test','2006-08-06 03:17:13','10.163.89.142','open','open'),(8,4,2,'tttttttttt','ttttttttttttte','2006-08-06 04:38:58','10.163.89.142','open','open'),(10,11,12,'fayland','fayland','2007-04-15 13:21:54','127.0.0.1','deleted','open'),(11,12,11,'new','new messages.','2007-04-15 13:50:16','127.0.0.1','open','open');
UNLOCK TABLES;
/*!40000 ALTER TABLE `message` ENABLE KEYS */;

--
-- Table structure for table `message_unread`
--

DROP TABLE IF EXISTS `message_unread`;
CREATE TABLE `message_unread` (
  `message_id` int(11) default NULL,
  `user_id` int(11) NOT NULL
) DEFAULT CHARSET=utf8;

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
) DEFAULT CHARSET=utf8;

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
) DEFAULT CHARSET=utf8;

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
) DEFAULT CHARSET=utf8;

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
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `scheduled_email`
--


/*!40000 ALTER TABLE `scheduled_email` DISABLE KEYS */;
LOCK TABLES `scheduled_email` WRITE;
INSERT INTO `scheduled_email` VALUES (1,'activation','N','fayland@gmail.com','fayland+62@gmail.com','Your Activation Code In Foorum (Be Together)','file error - cn/email/activation.html: not found',NULL,'2007-06-02 13:02:38'),(2,'activation','N','fayland@gmail.com','fayland+63@gmail.com','Your Activation Code In Foorum (Be Together)','file error - cn/email/activation.html: not found',NULL,'2007-06-02 13:03:58');
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
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`)
);

--
-- Dumping data for table `session`
--


/*!40000 ALTER TABLE `session` DISABLE KEYS */;
LOCK TABLES `session` WRITE;
INSERT INTO `session` VALUES ('session:9a91a8e7de4b6476ac8badfd97aa859b7c2454b5','BQcDAAAAAglGV3NdAAAACV9fY3JlYXRlZAlGV3NdAAAACV9fdXBkYXRlZA==\n',1180741197,NULL,'forum/forumname/38'),('session:1dc58c8725f8df3b066d8737346cde8608f9d863','BQcDAAAABAoHZGVmYXVsdAAAAAxfX3VzZXJfc3RvcmUKB2ZheWxhbmQAAAAGX191c2VyCUZXcG8A\nAAAJX19jcmVhdGVkCUZXcyIAAAAJX191cGRhdGVk\n',1180768615,11,'test'),('session:28421a13484ab87ca492e2222b6d60211a532417','BQcDAAAAAglGUj/HAAAACV9fY3JlYXRlZAlGUj/JAAAACV9fdXBkYXRlZA==\n',1180400608,NULL,'forum'),('session:142adcde8cf5bea4b1aa3ccad25aae9a6839f5cf','BQcDAAAABAoHZGVmYXVsdAAAAAxfX3VzZXJfc3RvcmUKB2ZheWxhbmQAAAAGX191c2VyCUZWsOUA\nAAAJX19jcmVhdGVkCUZWsQ0AAAAJX191cGRhdGVk\n',1180693183,11,'ajax/new_message'),('session:7dc0244087dd919a2cea2985f78625bfce20c758','BQcDAAAAAglGUj5mAAAACV9fY3JlYXRlZAlGUj5oAAAACV9fdXBkYXRlZA==\n',1180399846,NULL,NULL),('session:1f79b0ce9d10c2ca8c2321dad29ddceb76d1601a','BQcDAAAABAoHZGVmYXVsdAAAAAxfX3VzZXJfc3RvcmUKB2ZheWxhbmQAAAAGX191c2VyCUZQOvwA\nAAAJX19jcmVhdGVkCUZQSNYAAAAJX191cGRhdGVk\n',1180274423,11,'ajax/new_message'),('session:b65c93a81f4382ac44ea0ca0673fcce3e8350752','BQcDAAAABAoHZGVmYXVsdAAAAAxfX3VzZXJfc3RvcmUKB2ZheWxhbmQAAAAGX191c2VyCUZOnXIA\nAAAJX19jcmVhdGVkCUZOnYsAAAAJX191cGRhdGVk\n',1180176879,11,'ajax/new_message'),('session:22d53a8706a6972b1e1914741bddb3a223f72b92','BQcDAAAABAoHZGVmYXVsdAAAAAxfX3VzZXJfc3RvcmUKB2ZheWxhbmQAAAAGX191c2VyCUZhY1AA\nAAAJX19jcmVhdGVkCUZhbbgAAAAJX191cGRhdGVk\n',1181396137,11,'forum'),('session:5022610fb4f2c6c0d5f01edfbe3073c12009c4f4','BQcDAAAABAoHZGVmYXVsdAAAAAxfX3VzZXJfc3RvcmUKB2ZheWxhbmQAAAAGX191c2VyCUZiEtQA\nAAAJX19jcmVhdGVkCUZiEuMAAAAJX191cGRhdGVk\n',1181459390,11,'forum');
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
) DEFAULT CHARSET=utf8;

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
  status enum('healthy','banned','deleted')  DEFAULT 'healthy'  ,
  PRIMARY KEY  (`topic_id`)
);

--
-- Dumping data for table `topic`
--


/*!40000 ALTER TABLE `topic` DISABLE KEYS */;
LOCK TABLES `topic` WRITE;
INSERT INTO `topic` VALUES (34,6,'smile','1','0','0',9,11,'2006-12-30 14:48:19',11,1),(35,5,'MMMMMMMMMMMMMMMMMM','1','0','0',11,11,'2007-05-07 20:04:40',11,0),(39,5,'new topic','0','0','1',9,11,'2007-05-26 13:34:21',11,2),(38,5,'ubb','1','0','0',6,11,'2007-05-26 07:37:42',11,0),(37,11,'our aim of Foorum','1','1','1',9,11,'2007-05-26 13:58:15',11,2),(36,10,'print_message calling','0','0','0',10,11,'2007-05-19 15:52:11',11,1),(33,6,'xxxxxxxxxxxxxxx','0','0','0',5,11,'2006-12-24 11:27:49',11,0),(29,5,'attachment','0','0','1',89,11,'2006-12-16 11:46:11',11,4),(27,6,'xc2','0','0','0',2,11,'2006-12-06 19:54:06',11,0),(31,5,'<b>new post</b>','0','1','0',36,11,'2006-12-28 14:33:38',11,2),(32,5,'&lt;i&gt;sdasd&lt;/i&gt;','0','0','0',13,11,'2006-12-24 10:45:58',11,0);
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
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `upload`
--


/*!40000 ALTER TABLE `upload` DISABLE KEYS */;
LOCK TABLES `upload` WRITE;
INSERT INTO `upload` VALUES (1,11,5,'_C4405AD6-D20B-4510-B9C5-A6585.jpg',50.0,'jpg'),(3,11,5,'1.txt',0.2,'txt'),(5,11,0,'wt6IlRu3TlNTinD.jpg',50.0,'jpg'),(6,11,6,'XUFMfsWPknd91FD.jpg',50.0,'jpg'),(9,11,5,'61.gif',1.6,'gif'),(10,11,7,'butsts.gif',0.5,'gif'),(11,11,5,'ab_testing.jpg',70.5,'jpg');
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
  `email` varchar(255) NOT NULL,
  `register_on` date default NULL,
  `register_ip` varchar(32) default NULL,
  `last_login_on` datetime default NULL,
  `last_login_ip` varchar(32) default NULL,
  `login_times` int(11) default '1',
  `status` varchar(16) default NULL,
  `threads` int(11) NOT NULL default '0',
  `replies` int(11) NOT NULL default '0',
  `last_post_id` int(11) default NULL,
  `lang` char(2) default 'cn',
  `country` char(2) default NULL,
  `state_id` int(11) default NULL,
  `city_id` int(11) default NULL,
  `primary_photo` varchar(64) default NULL,
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`)
);

--
-- Dumping data for table `user`
--


/*!40000 ALTER TABLE `user` DISABLE KEYS */;
LOCK TABLES `user` WRITE;
INSERT INTO `user` VALUES (11,'fayland','p5/AÚOóÃ\"	JðhºpÃ³‹','fayland_lam','M','fayland@gmail.com','2006-08-27','222.137.238.13','2007-06-03 09:01:23','127.0.0.1',51,NULL,823,124,40,'cn','cn',NULL,NULL),(6,'testman','M±Ú²x2%Ìe”\'Äæiíö™°Î','testman',NULL,'testman@gmail.com','2006-08-18','127.0.0.1','2006-12-24 10:54:00','127.0.0.1',2,NULL,0,0,NULL,'en',NULL,NULL,NULL),(7,'shelly','p5/AÚOóÃ\"	JðhºpÃ³‹','sheyll',NULL,'shellybaby@gmai.com','2006-08-18','127.0.0.1','2006-08-18 13:21:11','127.0.0.1',2,NULL,0,0,NULL,'en',NULL,NULL,NULL),(12,'faylandxx','p5/AÚOóÃ\"	JðhºpÃ³‹','faylandxx',NULL,'faylandxx@gmail.com','2006-11-18','222.137.238.177','2007-04-15 13:49:42','127.0.0.1',5,NULL,0,0,NULL,'en',NULL,NULL,NULL),(13,'damnyuruihua','p5/AÚOóÃ\"	JðhºpÃ³‹','hahaha',NULL,'faylandda@gmail.com','2006-12-03','127.0.0.1',NULL,NULL,1,NULL,0,0,NULL,'en',NULL,NULL,NULL),(14,'fayland61','p5/AÚOóÃ\"	JðhºpÃ³‹','fayland 61',NULL,'fayland+61@gmail.com','2007-06-02','127.0.0.1',NULL,NULL,1,'unauthorized',0,0,NULL,'cn',NULL,NULL,NULL),(15,'fayland62','p5/AÚOóÃ\"	JðhºpÃ³‹','fayland 62',NULL,'fayland+62@gmail.com','2007-06-02','127.0.0.1',NULL,NULL,1,'unauthorized',0,0,NULL,'cn',NULL,NULL,NULL),(16,'fayland63','p5/AÚOóÃ\"	JðhºpÃ³‹','fayland 63',NULL,'fayland+63@gmail.com','2007-06-02','127.0.0.1',NULL,NULL,1,'authorized',0,0,NULL,'cn',NULL,NULL,NULL);
UNLOCK TABLES;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;

--
-- Table structure for table `user_activation`
--

DROP TABLE IF EXISTS `user_activation`;
CREATE TABLE `user_activation` (
  `user_id` int(11) NOT NULL,
  `activation_code` varchar(12) default NULL,
  `new_email` varchar(255) default NULL,
  PRIMARY KEY  (`user_id`)
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user_activation`
--


/*!40000 ALTER TABLE `user_activation` DISABLE KEYS */;
LOCK TABLES `user_activation` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `user_activation` ENABLE KEYS */;

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
) DEFAULT CHARSET=utf8;

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
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user_role`
--


/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
LOCK TABLES `user_role` WRITE;
INSERT INTO `user_role` VALUES (3,'admin','site'),(4,'admin','site'),(11,'admin','site'),(11,'admin','5'),(7,'admin','6'),(11,'admin','10'),(11,'admin','11'),(13,'moderator','5'),(12,'moderator','6'),(6,'moderator','6');
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
) DEFAULT CHARSET=utf8;

--
-- Dumping data for table `visit`
--


/*!40000 ALTER TABLE `visit` DISABLE KEYS */;
LOCK TABLES `visit` WRITE;
INSERT INTO `visit` VALUES (11,'thread',31,1180833522),(11,'thread',35,1179571211),(11,'thread',32,1179561959),(11,'thread',33,1179564301),(11,'thread',29,1180087087),(11,'thread',36,1180832757),(11,'thread',37,1180834584),(11,'thread',38,1180142873),(11,'thread',39,1180854260),(11,'thread',28,1180854278),(11,'thread',40,1180854332);
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

