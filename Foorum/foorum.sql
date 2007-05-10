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

DROP TABLE IF EXISTS `board`;
CREATE TABLE `board` (
  `forum_id` int(11) default NULL,
  `page_id` int(11) default NULL,
  `squence` int(11) default NULL,
  `category_id` int(11) default NULL,
  UNIQUE KEY `forum_id` (`forum_id`)
);

DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `parent_id` int(11) default NULL,
  `level` tinyint(4) default NULL,
  PRIMARY KEY  (`id`)
);

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
);

DROP TABLE IF EXISTS `email_setting`;
CREATE TABLE `email_setting` (
  `user_id` int(11) NOT NULL,
  `object_type` enum('comment','topic') NOT NULL,
  `frequence` enum('daily','weekly','none') NOT NULL,
  PRIMARY KEY  (`user_id`,`object_type`)
);

DROP TABLE IF EXISTS `forum`;
CREATE TABLE `forum` (
  `forum_id` int(11) NOT NULL auto_increment,
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

DROP TABLE IF EXISTS `log_action`;
CREATE TABLE `log_action` (
  `user_id` int(11) default NULL,
  `action` varchar(12) default NULL,
  `object_type` varchar(12) default NULL,
  `object_id` int(11) default NULL,
  `time` int(10) default NULL
);

DROP TABLE IF EXISTS `log_path`;
CREATE TABLE `log_path` (
  `session_id` varchar(72) default NULL,
  `user_id` int(9) NOT NULL default '0',
  `path` varchar(255) NOT NULL default '',
  `get` varchar(255) default NULL,
  `post` varchar(255) default NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `loadtime` float(5,2) NOT NULL default '0.00'
);

DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `message_id` int(11) NOT NULL auto_increment,
  `from_id` int(11) default NULL,
  `to_id` int(11) default NULL,
  `title` varchar(255) NOT NULL,
  `text` text NOT NULL,
  `post_on` datetime NOT NULL,
  `post_ip` varchar(32) NOT NULL,
  from_status enum('open','deleted') NOT NULL DEFAULT 'open'  ,
  to_status enum('open','deleted') NOT NULL DEFAULT 'open'  ,
  PRIMARY KEY  (`message_id`)
);

DROP TABLE IF EXISTS `message_unread`;
CREATE TABLE `message_unread` (
  `message_id` int(11) default NULL,
  `user_id` int(11) NOT NULL
);

DROP TABLE IF EXISTS `page`;
CREATE TABLE `page` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
);

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
);

DROP TABLE IF EXISTS `poll_option`;
CREATE TABLE `poll_option` (
  `option_id` int(11) unsigned NOT NULL auto_increment,
  `poll_id` int(11) default NULL,
  `text` varchar(255) default NULL,
  `vote_no` int(6) default NULL,
  PRIMARY KEY  (`option_id`)
);

DROP TABLE IF EXISTS `poll_result`;
CREATE TABLE `poll_result` (
  `option_id` int(11) default NULL,
  `poll_id` int(11) default NULL,
  `poster_id` int(11) default NULL,
  `poster_ip` varchar(32) default NULL
);

DROP TABLE IF EXISTS `session`;
CREATE TABLE `session` (
  `id` char(72) NOT NULL,
  `session_data` text,
  `expires` int(11) default '0',
  `user_id` int(11) default NULL,
  `path` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
);

DROP TABLE IF EXISTS `star`;
CREATE TABLE `star` (
  `user_id` int(11) unsigned NOT NULL,
  `object_type` varchar(12) default NULL,
  `object_id` int(11) default NULL,
  `time` int(10) default NULL
);

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

DROP TABLE IF EXISTS `upload`;
CREATE TABLE `upload` (
  `upload_id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `forum_id` int(11) default NULL,
  `filename` varchar(36) default NULL,
  `filesize` float(6,1) default NULL,
  `filetype` varchar(4) default NULL,
  PRIMARY KEY  (`upload_id`)
);

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
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `username` (`username`)
);

CREATE TABLE user_details (
  user_id int(11)  DEFAULT '0'  ,
  qq varchar(14)    ,
  msn varchar(64)    ,
  yahoo varchar(64)    ,
  skype varchar(64)    ,
  gtalk varchar(64)    ,
  homepage varchar(255)    ,
  birthday date    ,
  PRIMARY KEY (user_id)
);

DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role` (
  `user_id` int(11) default NULL,
  `role` enum('admin','moderator','user','blocked','pending','rejected') default 'user',
  `field` varchar(32) default NULL,
  KEY user_id (user_id),
  KEY field (field)
);

DROP TABLE IF EXISTS `visit`;
CREATE TABLE `visit` (
  `user_id` int(11) unsigned NOT NULL,
  `object_type` varchar(12) default NULL,
  `object_id` int(11) default NULL,
  `time` int(10) default NULL
);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

