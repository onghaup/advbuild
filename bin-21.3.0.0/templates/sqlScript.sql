-- phpMyAdmin SQL Dump
-- version 2.9.0.2
-- http://www.phpmyadmin.net
-- 
-- Database: `test`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `user`
-- 

CREATE TABLE `user` (
  `user_id` int(10) unsigned NOT NULL auto_increment,
  `group_id` int(10) unsigned NOT NULL default '0',
  `user_login` varchar(100) NOT NULL default '',
  `user_email` varchar(255) NOT NULL default '',
  `user_fname` varchar(255) NOT NULL default '',
  `user_lname` varchar(255) NOT NULL default '',
  `user_phone` varchar(15) NOT NULL default '',
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `user_login` (`user_login`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='User Table' AUTO_INCREMENT=6 ;
