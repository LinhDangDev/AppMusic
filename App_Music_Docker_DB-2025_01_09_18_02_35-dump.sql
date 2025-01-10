-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: app_music
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Artists`
--

DROP TABLE IF EXISTS `Artists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Artists` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `bio` text,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  FULLTEXT KEY `idx_artist_search` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Artists`
--

LOCK TABLES `Artists` WRITE;
/*!40000 ALTER TABLE `Artists` DISABLE KEYS */;
INSERT INTO `Artists` VALUES (1,'Morgan Wallen',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(2,'ROSÉ & Bruno Mars',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(3,'Lady Gaga & Bruno Mars',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(4,'Teddy Swims',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(5,'Hozier',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(6,'Billie Eilish',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(7,'Jelly Roll',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(8,'Benson Boone',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(9,'Shaboozey',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(10,'Ella Langley & Riley Green',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(11,'Cynthia Erivo',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(12,'Myles Smith',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(13,'Chappell Roan',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(14,'Disturbed',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(15,'Cody Johnson & Carrie Underwood',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(16,'Max McNown',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(17,'The Lumineers',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(18,'Thomas Rhett',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(19,'Zach Top',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(20,'Bad Bunny',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(21,'Lainey Wilson',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(22,'Kendrick Lamar & SZA',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(23,'Brandon Lake',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(24,'Ariana Grande',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(25,'Tim McGraw',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(26,'Luke Combs',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(27,'Megan Woods',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(28,'Peter, Paul & Mary',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(29,'Sabrina Carpenter',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(30,'Marshmello & Kane Brown',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(31,'Sam Barber',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(32,'Derik Fein',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(33,'Blake Shelton',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(34,'Lady Gaga',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(35,'4 Non Blondes',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(36,'Hank Williams, Jr.',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(37,'League of Legends Music & TEYA',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(38,'Ariana Grande & Cynthia Erivo',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(39,'The Red Clay Strays',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(40,'George Michael',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(41,'Kayhin',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(42,'CeCe Winans',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(43,'Dean Lewis',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(44,'The Judds',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(45,'Gigi Perez',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(46,'Christina Perri',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(47,'Dolly Parton & Kenny Rogers',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(48,'Paul Simon',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(49,'Ella Langley',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(50,'Phil Collins',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(51,'Kiss',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(52,'BSS',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(53,'Jelly Roll & mgk',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(54,'Papa Roach & Carrie Underwood',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(55,'Chris Stapleton',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(56,'Kane Brown',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(57,'Brenton Wood',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(58,'The Killers',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(59,'Jonathan Bailey',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(60,'Journey',NULL,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29');
/*!40000 ALTER TABLE `Artists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Audio_Quality`
--

DROP TABLE IF EXISTS `Audio_Quality`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Audio_Quality` (
  `id` int NOT NULL AUTO_INCREMENT,
  `music_id` int NOT NULL,
  `quality` varchar(20) NOT NULL,
  `format` varchar(20) NOT NULL,
  `bitrate` int DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audio_quality_music` (`music_id`),
  CONSTRAINT `Audio_Quality_ibfk_1` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Audio_Quality`
--

LOCK TABLES `Audio_Quality` WRITE;
/*!40000 ALTER TABLE `Audio_Quality` DISABLE KEYS */;
/*!40000 ALTER TABLE `Audio_Quality` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Favorites`
--

DROP TABLE IF EXISTS `Favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Favorites` (
  `user_id` int NOT NULL,
  `music_id` int NOT NULL,
  `artist_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`music_id`,`artist_id`),
  KEY `music_id` (`music_id`),
  KEY `artist_id` (`artist_id`),
  CONSTRAINT `Favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `Favorites_ibfk_2` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE,
  CONSTRAINT `Favorites_ibfk_3` FOREIGN KEY (`artist_id`) REFERENCES `Artists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Favorites`
--

LOCK TABLES `Favorites` WRITE;
/*!40000 ALTER TABLE `Favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `Favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Genres`
--

DROP TABLE IF EXISTS `Genres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Genres` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Genres`
--

LOCK TABLES `Genres` WRITE;
/*!40000 ALTER TABLE `Genres` DISABLE KEYS */;
/*!40000 ALTER TABLE `Genres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Music`
--

DROP TABLE IF EXISTS `Music`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Music` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `artist_id` int DEFAULT NULL,
  `album` varchar(255) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `release_date` date DEFAULT NULL,
  `youtube_url` varchar(255) DEFAULT NULL,
  `youtube_id` varchar(50) DEFAULT NULL,
  `youtube_thumbnail` varchar(255) DEFAULT NULL,
  `image_url` text,
  `preview_url` text,
  `source` enum('youtube','itunes','local') DEFAULT 'itunes',
  `source_id` varchar(255) DEFAULT NULL,
  `play_count` int DEFAULT '0',
  `lyrics` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_music_artist` (`artist_id`),
  KEY `idx_music_source` (`source`,`source_id`),
  FULLTEXT KEY `idx_music_search` (`title`),
  CONSTRAINT `Music_ibfk_1` FOREIGN KEY (`artist_id`) REFERENCES `Artists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Music`
--

LOCK TABLES `Music` WRITE;
/*!40000 ALTER TABLE `Music` DISABLE KEYS */;
INSERT INTO `Music` VALUES (1,'Smile',1,NULL,NULL,NULL,'https://www.youtube.com/watch?v=F7KdQ8CTe5E',NULL,'https://i.ytimg.com/vi/F7KdQ8CTe5E/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/d0/e8/b0/d0e8b0d6-b410-75e7-6bda-76e1a9ad4d15/24UM1IM35199.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/60/36/0f/60360fdc-6dff-d189-47b3-aacc61a2a6a8/mzaf_15062344014432241573.plus.aac.p.m4a','itunes','1785714732',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:30'),(2,'APT.',2,NULL,NULL,NULL,'https://www.youtube.com/watch?v=8Ebqe2Dbzls',NULL,'https://i.ytimg.com/vi/8Ebqe2Dbzls/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/2d/1a/7d/2d1a7d91-587e-0ceb-d434-327bd66d9e86/075679628312.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/22/8a/a1/228aa1a0-cbfd-ac14-ae99-09ca59bcc80b/mzaf_12121445588963961343.plus.aac.p.m4a','itunes','1773452221',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:32'),(3,'Die With A Smile',3,NULL,NULL,NULL,'https://www.youtube.com/watch?v=kPa7bsKwL-c',NULL,'https://i.ytimg.com/vi/kPa7bsKwL-c/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/11/ae/f2/11aef294-f57c-bab9-c9fc-529162984e62/24UMGIM85348.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/e9/d1/46/e9d14699-9505-493e-cd27-a501095c81ff/mzaf_7283388936457278756.plus.aac.p.m4a','itunes','1762656732',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:33'),(4,'Lose Control',4,NULL,NULL,NULL,'https://www.youtube.com/watch?v=FkOpwodhROI',NULL,'https://i.ytimg.com/vi/FkOpwodhROI/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/36/19/66/36196640-1561-dc5e-c6bc-1e5f4befa583/093624856771.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/1a/4d/cc/1a4dccfd-ab4a-35ac-6477-45e33074f303/mzaf_17951172482135259186.plus.aac.p.m4a','itunes','1691699836',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:35'),(5,'Love Somebody',1,NULL,NULL,NULL,'https://www.youtube.com/watch?v=zxMo0CZZzyg',NULL,'https://i.ytimg.com/vi/zxMo0CZZzyg/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/0e/6d/e1/0e6de152-3ff5-84a3-7ce7-7dfbdcb2c3e1/24UMGIM96374.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/10/ac/ea/10aceac1-00d1-2e14-fe80-a8fe91cdc297/mzaf_693780229277886478.plus.aac.p.m4a','itunes','1773342229',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:36'),(6,'Too Sweet',5,NULL,NULL,NULL,'https://www.youtube.com/watch?v=NTpbbQUBbuo',NULL,'https://i.ytimg.com/vi/NTpbbQUBbuo/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/98/80/95/98809581-4a0e-68a6-04de-b72492e35939/196871908191.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/7d/89/47/7d89470a-0a88-7096-f714-c0bf13545666/mzaf_4104862839845738954.plus.aac.p.m4a','itunes','1735414394',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:38'),(7,'BIRDS OF A FEATHER',6,NULL,NULL,NULL,'https://www.youtube.com/watch?v=d5gf9dXbPi0',NULL,'https://i.ytimg.com/vi/d5gf9dXbPi0/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/92/9f/69/929f69f1-9977-3a44-d674-11f70c852d1b/24UMGIM36186.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/06/ff/37/06ff37b5-02b3-af0c-2a75-8d8bb11ce3fc/mzaf_1694141409109287793.plus.aac.p.m4a','itunes','1739659142',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:39'),(8,'The Door',4,NULL,NULL,NULL,'https://www.youtube.com/watch?v=VSXT4a2kRHA',NULL,'https://i.ytimg.com/vi/VSXT4a2kRHA/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/36/19/66/36196640-1561-dc5e-c6bc-1e5f4befa583/093624856771.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/87/fc/44/87fc44b1-1721-3874-343b-4480f6191b2c/mzaf_3494542487124814715.plus.aac.p.m4a','itunes','1691699849',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:41'),(9,'I Am Not Okay',7,NULL,NULL,NULL,'https://www.youtube.com/watch?v=Qop5XLgwkNc',NULL,'https://i.ytimg.com/vi/Qop5XLgwkNc/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/95/b9/ca/95b9ca00-29cb-8edc-1ecb-5bda742f3177/24UMGIM62166.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/21/60/6e/21606ee6-338d-3814-2846-21031d80951e/mzaf_7718041890569439467.plus.aac.p.m4a','itunes','1750427181',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:43'),(10,'Beautiful Things',8,NULL,NULL,NULL,'https://www.youtube.com/watch?v=Oa_RSwwpPaA',NULL,'https://i.ytimg.com/vi/Oa_RSwwpPaA/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/54/f4/92/54f49210-e260-b519-ebbd-f4f40ee710cd/054391342751.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/d5/22/60/d5226046-d24b-00e2-685b-25f75fca012e/mzaf_11823776316685108152.plus.aac.p.m4a','itunes','1724488124',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:44'),(11,'Good News',9,NULL,NULL,NULL,'https://www.youtube.com/watch?v=WBDpb7SwSgU',NULL,'https://i.ytimg.com/vi/WBDpb7SwSgU/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/23/f2/d9/23f2d96d-b842-5f8b-1a09-bcc9a5cf7032/197342797344_cover.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/44/68/b3/4468b3ac-e689-9040-44a0-2eb0bd95d091/mzaf_17577048524469785487.plus.aac.p.m4a','itunes','1775307497',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:46'),(12,'you look like you love me',10,NULL,NULL,NULL,'https://www.youtube.com/watch?v=Dm2TSMerGPQ',NULL,'https://i.ytimg.com/vi/Dm2TSMerGPQ/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/62/33/40/62334080-6129-4d0c-086b-921cc956cb7a/196872090895.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/6b/f9/a6/6bf9a6ff-6293-1f0f-b5e1-add97d668f1c/mzaf_13058955996297446518.plus.aac.p.m4a','itunes','1749121123',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:47'),(13,'Defying Gravity (feat. Ariana Grande)',11,NULL,NULL,NULL,'https://www.youtube.com/watch?v=HxkLt1GXVsw',NULL,'https://i.ytimg.com/vi/HxkLt1GXVsw/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/3b/c3/80/3bc38021-d755-d689-43d2-775c6071b226/24UM1IM07582.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/ce/83/30/ce8330b1-e136-1a4f-323d-ebbbe1ef4eda/mzaf_9997798288676052156.plus.aac.p.m4a','itunes','1772364795',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:49'),(14,'Stargazing',12,NULL,NULL,NULL,'https://www.youtube.com/watch?v=tKml80alH3Y',NULL,'https://i.ytimg.com/vi/tKml80alH3Y/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/bf/c3/a5/bfc3a56d-a51b-69cb-cdfc-26ee63631cb8/196872051872.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/67/5f/f0/675ff01f-e8b3-4d77-2c0f-ac8bc8624e7c/mzaf_2883101666414234865.plus.aac.p.m4a','itunes','1742275653',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:50'),(15,'Bad Dreams',4,NULL,NULL,NULL,'https://www.youtube.com/watch?v=Qh8QwVYOSVU',NULL,'https://i.ytimg.com/vi/Qh8QwVYOSVU/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/cd/5d/64/cd5d64c2-338b-00c9-52d6-578a0f19d826/054391245908.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/04/a2/de/04a2de0b-7281-8500-0c73-4a21d13b769c/mzaf_15479703213960413524.plus.aac.p.m4a','itunes','1765799904',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:52'),(16,'Pink Pony Club',13,NULL,NULL,NULL,'https://www.youtube.com/watch?v=GR3Liudev18',NULL,'https://i.ytimg.com/vi/GR3Liudev18/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/fb/65/cb/fb65cb0f-4260-d740-d6f5-bb80c9c27c1b/23UMGIM84225.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/cd/b5/57/cdb5571e-fde6-a075-9d88-18dcc8691a52/mzaf_1732025204656200729.plus.aac.p.m4a','itunes','1698723327',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:54'),(17,'The Sound of Silence',14,NULL,NULL,NULL,'https://www.youtube.com/watch?v=u9Dg-g7t2l4',NULL,'https://i.ytimg.com/vi/u9Dg-g7t2l4/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/32/2b/12/322b1228-a133-3317-8d05-742669b700ec/093624926245.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/a5/0b/8a/a50b8a9b-be1d-c43c-9236-e10ce4038db5/mzaf_6738321194496105228.plus.aac.p.m4a','itunes','1006937459',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:55'),(18,'I\'m Gonna Love You',15,NULL,NULL,NULL,'https://www.youtube.com/watch?v=yy9PuYMU29g',NULL,'https://i.ytimg.com/vi/yy9PuYMU29g/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/98/88/4b/98884ba1-fe25-76b8-211f-ebfb3d000fd5/093624838982.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/cd/52/86/cd52869d-387e-af7a-f03a-268a4bd6fdce/mzaf_18315647017554649766.plus.aac.p.m4a','itunes','1769025576',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:57'),(19,'Better Me For You',16,NULL,NULL,NULL,'https://www.youtube.com/watch?v=JNR6VML8kBQ',NULL,'https://i.ytimg.com/vi/JNR6VML8kBQ/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/e1/f6/d3/e1f6d3fc-f678-9dca-1940-58132936e7f8/850064541380.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/5d/d0/88/5dd08819-f21f-4d1e-5781-5d81f1e9c2f1/mzaf_8426330088654948568.plus.aac.p.m4a','itunes','1778759151',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:58'),(20,'Same Old Song',17,NULL,NULL,NULL,'https://www.youtube.com/watch?v=WcS6MA9fu-I',NULL,'https://i.ytimg.com/vi/WcS6MA9fu-I/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/80/f0/25/80f02523-c64e-f37f-2a30-ac726b2447a8/25892.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/16/08/30/160830c6-dfe3-10fa-79ae-4f4d91ed97d2/mzaf_14527960081008951655.plus.aac.p.m4a','itunes','1779371652',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:00'),(21,'Liar',7,NULL,NULL,NULL,'https://www.youtube.com/watch?v=QQrbQHL9xsQ',NULL,'https://i.ytimg.com/vi/QQrbQHL9xsQ/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/a0/e3/e0/a0e3e0d3-f6c8-8a1c-bcf1-17c49154b986/24UM1IM08555.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/1d/bb/94/1dbb9458-e22f-4010-eb50-9c8e0442cf4e/mzaf_2505596371140054051.plus.aac.p.m4a','itunes','1772965606',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:02'),(22,'Somethin\' \'Bout A Woman (feat. Teddy Swims)',18,NULL,NULL,NULL,'https://www.youtube.com/watch?v=65aNPjAwGnw',NULL,'https://i.ytimg.com/vi/65aNPjAwGnw/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/4d/8e/50/4d8e50fc-d22c-eef3-d489-67a40627c6bb/24BMR0006043.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/16/23/e1/1623e166-51ef-a348-f47f-784655faa955/mzaf_9505236667488732202.plus.aac.p.m4a','itunes','1778591358',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:03'),(23,'I Never Lie',19,NULL,NULL,NULL,'https://www.youtube.com/watch?v=P6LeMSLYhko',NULL,'https://i.ytimg.com/vi/P6LeMSLYhko/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/05/00/8f/05008f0a-c5ab-668c-2aae-6934f26d1d6d/8721056563135.png/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/25/33/61/253361ce-80cf-455e-c8d6-0fd3cf79327e/mzaf_3341617974044232238.plus.aac.p.m4a','itunes','1728077717',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:05'),(24,'NUEVAYoL',20,NULL,NULL,NULL,'https://www.youtube.com/watch?v=zAfrPjTvSNs',NULL,'https://i.ytimg.com/vi/zAfrPjTvSNs/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/90/5e/7e/905e7ed5-a8fa-a8f3-cd06-0028fdf3afaa/199066342442.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/e7/1e/17/e71e17d8-4a5c-7254-3551-62580aa77516/mzaf_9417781865839967440.plus.aac.p.m4a','itunes','1787022572',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:06'),(25,'4x4xU',21,NULL,NULL,NULL,'https://www.youtube.com/watch?v=wWNmSwYzfb8',NULL,'https://i.ytimg.com/vi/wWNmSwYzfb8/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/36/b8/fa/36b8fa72-ad38-9527-bdb0-d9c2f6fb1184/4099964053951.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/2a/52/03/2a520362-9217-20be-cb7d-86b77fcae66a/mzaf_9134488578647597937.plus.aac.p.m4a','itunes','1744255566',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:08'),(26,'The Sound of Silence (CYRIL Remix)',14,NULL,NULL,NULL,'https://www.youtube.com/watch?v=uIBJJ3M76Mg',NULL,'https://i.ytimg.com/vi/uIBJJ3M76Mg/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/94/70/8a/94708ae0-6c8b-a56c-23c9-02b7c84798df/054391308696.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/5b/29/cd/5b29cdf6-aee7-96b7-184a-d78c65d1c76f/mzaf_14890125608805514906.plus.aac.p.m4a','itunes','1728548345',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:09'),(27,'luther',22,NULL,NULL,NULL,'https://www.youtube.com/watch?v=0vPdpUiVWi8',NULL,'https://i.ytimg.com/vi/0vPdpUiVWi8/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/50/c2/cc/50c2cc95-3658-9417-0d4b-831abde44ba1/24UM1IM28978.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/17/c5/2a/17c52a60-2867-4bc2-bbd3-5598f465ec15/mzaf_1780590825750947644.plus.aac.p.m4a','itunes','1781270323',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:11'),(28,'Hard Fought Hallelujah',23,NULL,NULL,NULL,'https://www.youtube.com/watch?v=KcIMnHf3HyM',NULL,'https://i.ytimg.com/vi/KcIMnHf3HyM/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/a5/82/ee/a582eeb1-4b8a-e196-a60d-ca5aecbc5303/196872603842.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/44/fa/05/44fa0529-389e-dbb2-d359-72f5f1526367/mzaf_11842748505997874792.plus.aac.p.m4a','itunes','1777118806',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:13'),(29,'Popular',24,NULL,NULL,NULL,'https://www.youtube.com/watch?v=4H6qwPJT9W0',NULL,'https://i.ytimg.com/vi/4H6qwPJT9W0/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/3b/c3/80/3bc38021-d755-d689-43d2-775c6071b226/24UM1IM07582.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/e8/e3/87/e8e38770-aa0d-730d-a7b4-4c7f39680ac1/mzaf_6702258382868230583.plus.aac.p.m4a','itunes','1772364643',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:14'),(30,'Live Like You Were Dying',25,NULL,NULL,NULL,'https://www.youtube.com/watch?v=Wzruh76X5a0',NULL,'https://i.ytimg.com/vi/Wzruh76X5a0/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/0c/2c/50/0c2c5073-4d60-142a-5a79-c63477afd9ae/s06.uuzymric.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/e2/f3/22/e2f32280-f5b8-477c-a4fa-1b21fcea36ac/mzaf_11542786014713397431.plus.aac.p.m4a','itunes','68891680',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:16'),(31,'Ain\'t No Love In Oklahoma',26,NULL,NULL,NULL,'https://www.youtube.com/watch?v=J6YlaeACE4E',NULL,'https://i.ytimg.com/vi/J6YlaeACE4E/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/d1/a0/62/d1a062f2-df00-7975-ec2c-d5eacbc0741c/075679646439.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/09/a8/66/09a86669-723f-fc57-d8a4-67ec08c36c56/mzaf_8181752603267537802.plus.aac.p.m4a','itunes','1746560129',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:18'),(32,'The Truth',27,NULL,NULL,NULL,'https://www.youtube.com/watch?v=5fSVWVYkh2A',NULL,'https://i.ytimg.com/vi/5fSVWVYkh2A/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/2b/f1/e2/2bf1e2ec-08cf-233b-9ba5-537736d4dbaf/196872073270.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/6a/8e/58/6a8e5861-704f-0618-d98b-ad406c9e9888/mzaf_7395156930204720431.plus.aac.p.m4a','itunes','1747003927',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:19'),(33,'Puff, the Magic Dragon',28,NULL,NULL,NULL,'https://www.youtube.com/watch?v=_1G9wO9-54c',NULL,'https://i.ytimg.com/vi/_1G9wO9-54c/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/ae/92/2b/ae922b24-7d22-eb75-0f2c-a48b49e43ee7/dj.uhhbdbuq.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/d7/35/30/d73530b8-1067-dae3-fe57-f35a5bc09906/mzaf_7020850356619996051.plus.aac.p.m4a','itunes','79029898',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:21'),(34,'Taste',29,NULL,NULL,NULL,'https://www.youtube.com/watch?v=KEG7b851Ric',NULL,'https://i.ytimg.com/vi/KEG7b851Ric/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/f6/15/d0/f615d0ab-e0c4-575d-907e-1cc084642357/24UMGIM61704.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/1d/d5/6a/1dd56a50-0eaa-6eaf-6bf8-6a1d864aa2e7/mzaf_1020321601181850941.plus.aac.p.m4a','itunes','1750307079',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:22'),(35,'Good Luck, Babe!',13,NULL,NULL,NULL,'https://www.youtube.com/watch?v=1RKqOmSkGgM',NULL,'https://i.ytimg.com/vi/1RKqOmSkGgM/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/29/a7/c4/29a7c478-351d-25eb-a116-3e68118cdab8/24UMGIM31246.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/ae/57/5d/ae575db4-68db-508a-c012-421ee79bfa62/mzaf_5112451481032254728.plus.aac.p.m4a','itunes','1737497080',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:24'),(36,'Miles On It',30,NULL,NULL,NULL,'https://www.youtube.com/watch?v=RMmoyP_cpEg',NULL,'https://i.ytimg.com/vi/RMmoyP_cpEg/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/16/5e/2d/165e2ddb-c596-8565-d86a-6231b4a911a6/196872075496.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/71/e0/c7/71e0c7d0-2123-77bd-2322-e9a8d11333e5/mzaf_12415459325798775890.plus.aac.p.m4a','itunes','1743575321',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:25'),(37,'Indigo (feat. Avery Anna)',31,NULL,NULL,NULL,'https://www.youtube.com/watch?v=0iMPhRWExTo',NULL,'https://i.ytimg.com/vi/0iMPhRWExTo/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/74/52/77/745277cf-4917-193f-829a-876ab625f01b/075679629432.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/16/ce/d4/16ced4e1-16c2-9aef-3e3c-15671d945330/mzaf_797864817807071134.plus.aac.p.m4a','itunes','1772722911',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:27'),(38,'Sun',32,NULL,NULL,NULL,'https://www.youtube.com/watch?v=vGPtQicI3IE',NULL,'https://i.ytimg.com/vi/vGPtQicI3IE/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/98/62/0a/98620a7e-a838-e92b-a45b-2d57e74ec917/859794678045_cover.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/a2/92/49/a2924961-4866-d7cd-7080-ee583ed49be7/mzaf_10695795266039970705.plus.aac.p.m4a','itunes','1770071178',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:29'),(39,'Texas',33,NULL,NULL,NULL,'https://www.youtube.com/watch?v=0lyXl2Rfsj4',NULL,'https://i.ytimg.com/vi/0lyXl2Rfsj4/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/a9/53/f5/a953f5ec-0392-9dbb-f038-3ab3f309fffb/4099964134193.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/56/7c/28/567c2836-d375-e42f-11d7-3de522b395ee/mzaf_1570798982557853705.plus.aac.p.m4a','itunes','1776662929',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:30'),(40,'HOT TO GO!',13,NULL,NULL,NULL,'https://www.youtube.com/watch?v=xaPNR-_Cfn0',NULL,'https://i.ytimg.com/vi/xaPNR-_Cfn0/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/fb/65/cb/fb65cb0f-4260-d740-d6f5-bb80c9c27c1b/23UMGIM84225.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/9f/f6/39/9ff6396d-79fa-c881-ec9e-e3e257406b50/mzaf_8937339939672562689.plus.aac.p.m4a','itunes','1698723221',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:32'),(41,'Blowin\' In the Wind',28,NULL,NULL,NULL,'https://www.youtube.com/watch?v=1Hhi0i0UDS0',NULL,'https://i.ytimg.com/vi/1Hhi0i0UDS0/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/ae/92/2b/ae922b24-7d22-eb75-0f2c-a48b49e43ee7/dj.uhhbdbuq.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/27/26/ec/2726ec06-afe1-1d1e-db57-b07e79847ec5/mzaf_17552829917766450224.plus.aac.p.m4a','itunes','79029905',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:34'),(42,'Leaving On a Jet Plane',28,NULL,NULL,NULL,'https://www.youtube.com/watch?v=F2m--R3J6f4',NULL,'https://i.ytimg.com/vi/F2m--R3J6f4/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/ae/92/2b/ae922b24-7d22-eb75-0f2c-a48b49e43ee7/dj.uhhbdbuq.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/d5/c8/4f/d5c84f91-7855-6eff-79c4-663759ce2e6a/mzaf_11294640048623273140.plus.aac.p.m4a','itunes','79029925',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:35'),(43,'Always Remember Us This Way',34,NULL,NULL,NULL,'https://www.youtube.com/watch?v=5vheNbQlsyU',NULL,'https://i.ytimg.com/vi/5vheNbQlsyU/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/b1/9f/ef/b19fef51-79de-a940-e8ab-9e4e07b04d96/18UMGIM53752.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/f8/4f/8d/f84f8d88-63de-6780-980d-f3cc19c9828b/mzaf_13908126467051407847.plus.aac.p.m4a','itunes','1434372043',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:37'),(44,'What\'s Up?',35,NULL,NULL,NULL,'https://www.youtube.com/watch?v=6NXnxTNIWkc',NULL,'https://i.ytimg.com/vi/6NXnxTNIWkc/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/d2/aa/44/d2aa4418-7e74-7e6d-4247-9b9c1cba9e64/06UMGIM01654.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/8d/55/94/8d559478-b6e2-0519-d541-e2162e2107f8/mzaf_15636775327146859731.plus.aac.p.m4a','itunes','1440902348',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:38'),(45,'A Country Boy Can Survive',36,NULL,NULL,NULL,'https://www.youtube.com/watch?v=oMdlApv4-ys',NULL,'https://i.ytimg.com/vi/oMdlApv4-ys/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/9b/18/2d/9b182db4-b54b-97cc-42df-b618e037d36d/715187763821.png/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/e2/47/75/e2477544-be4c-56c3-a084-9ba20bcdde78/mzaf_6997026490045481960.plus.aac.p.m4a','itunes','71580629',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:40'),(46,'A Lot More Free',16,NULL,NULL,NULL,'https://www.youtube.com/watch?v=YDAGyiJQ3qk',NULL,'https://i.ytimg.com/vi/YDAGyiJQ3qk/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/b7/ac/8f/b7ac8f98-f880-4a6b-c842-1292d312661e/851636005460.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/27/ef/eb/27efebc9-c955-ae12-b618-de14409b665b/mzaf_4985068904445925355.plus.aac.p.m4a','itunes','1702216786',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:42'),(47,'Bite Marks',37,NULL,NULL,NULL,'https://www.youtube.com/watch?v=7Eghi9byvOw',NULL,'https://i.ytimg.com/vi/7Eghi9byvOw/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/aa/f7/de/aaf7dea3-776b-d9a2-6acd-ce893dce44a3/8721253448488.png/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/83/90/b8/8390b827-d488-6839-8fcb-198ab856a352/mzaf_9163916628224162038.plus.aac.p.m4a','itunes','1788974485',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:43'),(48,'What Is This Feeling?',38,NULL,NULL,NULL,'https://www.youtube.com/watch?v=DAvOfEweyJo',NULL,'https://i.ytimg.com/vi/DAvOfEweyJo/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/3b/c3/80/3bc38021-d755-d689-43d2-775c6071b226/24UM1IM07582.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/e2/84/c4/e284c4a9-e970-861c-a830-36cd3ab39e77/mzaf_15269153443231426616.plus.aac.p.m4a','itunes','1772364620',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:45'),(49,'Wondering Why',39,NULL,NULL,NULL,'https://www.youtube.com/watch?v=JbxfFKvoAU4',NULL,'https://i.ytimg.com/vi/JbxfFKvoAU4/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/9d/1b/c0/9d1bc061-4161-87bc-3cec-49e5951df334/197190214994.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/b4/09/f8/b409f86c-4f3f-9482-216e-1d241cc3b103/mzaf_11530609709397448019.plus.aac.p.m4a','itunes','1725170119',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:47'),(50,'DtMF',20,NULL,NULL,NULL,'https://www.youtube.com/watch?v=v9T_MGfzq7I',NULL,'https://i.ytimg.com/vi/v9T_MGfzq7I/hqdefault.jpg','https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/90/5e/7e/905e7ed5-a8fa-a8f3-cd06-0028fdf3afaa/199066342442.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/18/08/dd/1808dd28-e6c1-7396-ba29-36362d3a2255/mzaf_4772680730951823595.plus.aac.p.m4a','itunes','1787023936',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:42:48'),(51,'Father Figure',40,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/87/29/d2/8729d243-f06f-e588-3ddf-ffa87a2ce17e/mzi.yupygcca.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/68/eb/8d/68eb8d2d-bcbf-bc59-3b5f-5da3c4761912/mzaf_8137585745891374038.plus.aac.p.m4a','itunes','395918959',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(52,'Erika (Marimba)',41,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/a2/2a/5b/a22a5baa-3a2f-2919-14a6-a73407b254e3/859799986657_cover.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/13/c7/28/13c7285f-0345-7637-d4ae-38cf1c26792e/mzaf_17668909308035084465.plus.aac.p.m4a','itunes','1788905353',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(53,'Goodness of God (Live)',42,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/d7/7d/63/d77d63d8-44f7-9f75-b4c7-19cc20239120/886449027057.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/82/e2/a8/82e2a854-b281-b9ca-ed3b-ac3530d60585/mzaf_12574273604456188072.plus.aac.p.m4a','itunes','1550189769',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(54,'How Do I Say Goodbye',43,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/7d/bb/07/7dbb0721-85ea-5b8a-293d-d4be41970058/22UMGIM59967.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/50/1b/52/501b5241-6e9c-57be-d0d6-6c6876c4359e/mzaf_5649932294053374078.plus.aac.p.m4a','itunes','1636891299',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(55,'Save Me',7,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/4d/11/96/4d119607-97d8-c6be-38ea-efc21b902d0d/850015145735_Cover.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/dc/b4/62/dcb46220-de4a-22d7-6ba9-251ce43ddf16/mzaf_10401107287540475630.plus.aac.p.m4a','itunes','1520495045',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(56,'Grandpa (Tell Me \'Bout the Good Old Days)',44,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/53/af/7b/53af7b43-c7fb-01c3-45e2-5aa2dfa87ced/715187796522.png/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/73/3b/8c/733b8c9d-807a-380d-a4f0-3a2c7145e02f/mzaf_4095722342724028109.plus.aac.p.m4a','itunes','68876131',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(57,'Sailor Song',45,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/25/d4/96/25d49699-acc0-401f-a7cc-d7697339a474/24UM1IM03751.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/c2/89/a7/c289a754-3456-a4fb-64aa-b379ac693a1f/mzaf_2750713964913630450.plus.aac.p.m4a','itunes','1770187510',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(58,'A Thousand Years',46,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/f5/2e/83/f52e8357-9cf4-e644-c365-3c21839f85ac/mzi.staekbjw.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/a6/40/cf/a640cf5a-88f2-31ce-9293-01fdc91507d7/mzaf_7926314707202104323.plus.aac.p.m4a','itunes','467980724',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(59,'Islands In the Stream',47,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music/37/fa/d1/mzi.ecmonpil.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/1b/1e/36/1b1e36d6-c2fe-c442-1c1f-8048ad016e3a/mzaf_4014302009250642730.plus.aac.p.m4a','itunes','282883594',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(60,'50 Ways to Leave Your Lover',48,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/5e/c9/a5/5ec9a59c-13b6-3a55-5511-9e3da438551a/dj.ojewaxgt.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/61/f6/59/61f659db-4ffb-01e4-4edf-cd67b9f4e078/mzaf_12108552449966516426.plus.aac.p.m4a','itunes','380625663',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(61,'weren\'t for the wind',49,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/ef/f1/65/eff16551-2b83-202a-f923-a655a57c61b8/196872452563.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/6f/f0/0a/6ff00a13-3c41-a500-8681-5217975582bd/mzaf_9336240805402006086.plus.aac.p.m4a','itunes','1770160814',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(62,'In the Air Tonight',50,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/e2/64/d1/e264d18c-2b20-051d-3fc3-68b3424f8cde/603497880249.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/aa/64/8c/aa648c0e-a166-0c26-f491-65d6ec769f78/mzaf_11832742059273415828.plus.aac.p.m4a','itunes','1076779225',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(63,'I Was Made for Lovin\' You',51,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/88/37/72/88377246-d96d-3b9d-4373-06fbabd704db/06UMGIM15802.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/70/2b/91/702b910f-5276-81cf-0f9e-d4ead7454fe6/mzaf_8795932846314408189.plus.aac.p.m4a','itunes','1440658917',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(64,'CBZ (Prime time)',52,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/83/b1/bc/83b1bc17-962e-4cc2-2605-328c1f638b5c/198704273926_Cover.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/9a/77/6a/9a776ac4-224d-f9ad-8b1c-1e0bc6339b21/mzaf_12880263193655490275.plus.aac.p.m4a','itunes','1786412500',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(65,'Lonely Road',53,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/a0/e3/e0/a0e3e0d3-f6c8-8a1c-bcf1-17c49154b986/24UM1IM08555.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/52/85/0b/52850b52-b6a8-74de-46d2-61ad8de6b55a/mzaf_14294341056883197009.plus.aac.p.m4a','itunes','1772965981',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(66,'Hammer to the Heart',4,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/5c/c4/6e/5cc46e64-1746-114a-fd8f-1e5490946c52/093624840947.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/9b/a7/16/9ba7166e-94e3-6274-1195-fefc98741368/mzaf_4284985388268465856.plus.aac.p.m4a','itunes','1771020966',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(67,'Bed Chem',29,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/f6/15/d0/f615d0ab-e0c4-575d-907e-1cc084642357/24UMGIM61704.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/6c/12/78/6c127808-433e-112d-0b30-4999234a6dc1/mzaf_11024588707927805966.plus.aac.p.m4a','itunes','1750307088',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(68,'Leave a Light On (Talk Away The Dark)',54,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/19/28/62/192862e5-ef0e-5e63-6aa7-17dc2614d03a/5021732356093.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/35/ad/16/35ad161c-30e0-d687-c2d9-9d91a8bb8220/mzaf_12443192831568043481.plus.aac.p.m4a','itunes','1759649514',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(69,'Lies Lies Lies',1,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/e2/53/2f/e2532f80-b877-c273-938d-85565456cba4/24UMGIM69835.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/1a/ba/8f/1aba8f84-d6d7-ba3f-222a-1bab26cee4c6/mzaf_7418060965643085123.plus.aac.p.m4a','itunes','1754189283',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(70,'Tennessee Whiskey',55,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/e2/4b/60/e24b6016-8278-bb18-cf5d-d44bf68371da/00602547223838.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/e3/7e/a3/e37ea341-37f0-9dcb-4d6a-e3f0a2c1ae26/mzaf_2775390428315622059.plus.aac.p.m4a','itunes','1440827492',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(71,'Backseat Driver',56,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/ae/36/1a/ae361a2e-cea6-d47f-166b-1c015726846b/196872381474.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/20/24/69/20246905-64ed-bdce-099a-5edb3db008b8/mzaf_7748626299913537915.plus.aac.p.m4a','itunes','1771767810',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(72,'Oogum Boogum Song',57,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/ce/6e/be/ce6ebe5e-e644-d30d-e0c2-6b659311a192/00850058005102.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/e0/84/f6/e084f6d7-b4ab-2b62-548c-a301b318026b/mzaf_12926797804976401419.plus.aac.p.m4a','itunes','1440935012',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(73,'Mr. Brightside',58,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/07/1a/5a/071a5aee-6e42-060c-35b9-6a6e45b9ea59/06UMGIM10441.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/f2/66/f8/f266f86f-8873-db7e-f401-db7d474f03ed/mzaf_1909991961324960374.plus.aac.p.m4a','itunes','1526194192',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(74,'Run It',7,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/82/b5/77/82b5771a-4b02-da62-6fc4-d630abd2b060/24UM1IM28846.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/75/2b/ec/752bec8b-d707-0923-6316-f0aca2154119/mzaf_11505474488177043091.plus.aac.p.m4a','itunes','1779847694',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(75,'Dancing Through Life (feat. Ariana Grande, Ethan Slater, Marissa Bode & Cynthia Erivo)',59,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/3b/c3/80/3bc38021-d755-d689-43d2-775c6071b226/24UM1IM07582.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/d5/d3/96/d5d39655-9590-2ab2-d532-ee456d8a93d1/mzaf_10916667277057722768.plus.aac.p.m4a','itunes','1772364626',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(76,'Don\'t Stop Believin\' (2024 Remaster)',60,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/71/2d/61/712d617d-f4a4-5904-1b11-d4b4b45c47c5/828768588925.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/5c/72/97/5c72974f-6022-f760-ad82-35964fb636b5/mzaf_12752096049347330756.plus.aac.p.m4a','itunes','169003415',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(77,'Think I\'m In Love With You',55,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/f1/2a/d7/f12ad765-1d90-3959-c872-35cc34c8359a/23UMGIM80471.rgb.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/a8/97/7d/a8977d80-f92a-0362-8a84-c62780d5eedc/mzaf_3503319012355084120.plus.aac.p.m4a','itunes','1697401278',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29'),(78,'Funeral',4,NULL,NULL,NULL,NULL,NULL,NULL,'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/5c/c4/6e/5cc46e64-1746-114a-fd8f-1e5490946c52/093624840947.jpg/170x170bb.png','https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/5b/56/8c/5b568ccd-df30-35b7-d23d-b388288d92de/mzaf_9901294153590557402.plus.aac.p.m4a','itunes','1771020854',0,NULL,'2025-01-09 09:41:29','2025-01-09 09:41:29');
/*!40000 ALTER TABLE `Music` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `update_popularity_score` AFTER UPDATE ON `Music` FOR EACH ROW BEGIN
    IF NEW.play_count != OLD.play_count THEN
        INSERT INTO Music_Updates (music_id, update_type, old_value, new_value)
        VALUES (
            NEW.id,
            'PLAY_COUNT',
            JSON_OBJECT('play_count', OLD.play_count),
            JSON_OBJECT('play_count', NEW.play_count)
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `clear_stream_cache` AFTER UPDATE ON `Music` FOR EACH ROW BEGIN
    IF NEW.source != OLD.source OR NEW.source_id != OLD.source_id THEN
        DELETE FROM Stream_Cache WHERE music_id = NEW.id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Music_Genres`
--

DROP TABLE IF EXISTS `Music_Genres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Music_Genres` (
  `music_id` int NOT NULL,
  `genre_id` int NOT NULL,
  PRIMARY KEY (`music_id`,`genre_id`),
  KEY `idx_music_genres` (`genre_id`),
  CONSTRAINT `Music_Genres_ibfk_1` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE,
  CONSTRAINT `Music_Genres_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `Genres` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Music_Genres`
--

LOCK TABLES `Music_Genres` WRITE;
/*!40000 ALTER TABLE `Music_Genres` DISABLE KEYS */;
/*!40000 ALTER TABLE `Music_Genres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Music_Updates`
--

DROP TABLE IF EXISTS `Music_Updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Music_Updates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `music_id` int NOT NULL,
  `update_type` enum('PLAY_COUNT','POPULARITY','METADATA') NOT NULL,
  `old_value` json DEFAULT NULL,
  `new_value` json DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `music_id` (`music_id`),
  CONSTRAINT `Music_Updates_ibfk_1` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Music_Updates`
--

LOCK TABLES `Music_Updates` WRITE;
/*!40000 ALTER TABLE `Music_Updates` DISABLE KEYS */;
/*!40000 ALTER TABLE `Music_Updates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Offline_Songs`
--

DROP TABLE IF EXISTS `Offline_Songs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Offline_Songs` (
  `user_id` int NOT NULL,
  `music_id` int NOT NULL,
  `downloaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expiration_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`,`music_id`),
  KEY `music_id` (`music_id`),
  CONSTRAINT `Offline_Songs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `Offline_Songs_ibfk_2` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Offline_Songs`
--

LOCK TABLES `Offline_Songs` WRITE;
/*!40000 ALTER TABLE `Offline_Songs` DISABLE KEYS */;
/*!40000 ALTER TABLE `Offline_Songs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Payment_History`
--

DROP TABLE IF EXISTS `Payment_History`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Payment_History` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `subscription_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `status` enum('PENDING','SUCCESS','FAILED','REFUNDED') DEFAULT 'PENDING',
  `payment_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `subscription_id` (`subscription_id`),
  KEY `idx_payment_history_user` (`user_id`),
  CONSTRAINT `Payment_History_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `Payment_History_ibfk_2` FOREIGN KEY (`subscription_id`) REFERENCES `User_Subscriptions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Payment_History`
--

LOCK TABLES `Payment_History` WRITE;
/*!40000 ALTER TABLE `Payment_History` DISABLE KEYS */;
/*!40000 ALTER TABLE `Payment_History` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PlaybackState`
--

DROP TABLE IF EXISTS `PlaybackState`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PlaybackState` (
  `user_id` int NOT NULL,
  `current_music_id` int DEFAULT NULL,
  `current_playlist_id` int DEFAULT NULL,
  `repeat_mode` enum('OFF','ONE','ALL') DEFAULT 'OFF',
  `shuffle_mode` tinyint(1) DEFAULT '0',
  `last_position` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `current_music_id` (`current_music_id`),
  KEY `current_playlist_id` (`current_playlist_id`),
  CONSTRAINT `PlaybackState_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `PlaybackState_ibfk_2` FOREIGN KEY (`current_music_id`) REFERENCES `Music` (`id`) ON DELETE SET NULL,
  CONSTRAINT `PlaybackState_ibfk_3` FOREIGN KEY (`current_playlist_id`) REFERENCES `Playlists` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PlaybackState`
--

LOCK TABLES `PlaybackState` WRITE;
/*!40000 ALTER TABLE `PlaybackState` DISABLE KEYS */;
/*!40000 ALTER TABLE `PlaybackState` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Playlist_Songs`
--

DROP TABLE IF EXISTS `Playlist_Songs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Playlist_Songs` (
  `playlist_id` int NOT NULL,
  `music_id` int NOT NULL,
  `position` int DEFAULT NULL,
  PRIMARY KEY (`playlist_id`,`music_id`),
  KEY `music_id` (`music_id`),
  CONSTRAINT `Playlist_Songs_ibfk_1` FOREIGN KEY (`playlist_id`) REFERENCES `Playlists` (`id`) ON DELETE CASCADE,
  CONSTRAINT `Playlist_Songs_ibfk_2` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Playlist_Songs`
--

LOCK TABLES `Playlist_Songs` WRITE;
/*!40000 ALTER TABLE `Playlist_Songs` DISABLE KEYS */;
/*!40000 ALTER TABLE `Playlist_Songs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Playlists`
--

DROP TABLE IF EXISTS `Playlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Playlists` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `is_shared` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_playlists_user` (`user_id`),
  CONSTRAINT `Playlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Playlists`
--

LOCK TABLES `Playlists` WRITE;
/*!40000 ALTER TABLE `Playlists` DISABLE KEYS */;
/*!40000 ALTER TABLE `Playlists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Promo_Codes`
--

DROP TABLE IF EXISTS `Promo_Codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Promo_Codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `discount_percent` int DEFAULT NULL,
  `discount_amount` decimal(10,2) DEFAULT NULL,
  `valid_from` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `valid_until` timestamp NULL DEFAULT NULL,
  `max_uses` int DEFAULT NULL,
  `current_uses` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_promo_codes` (`code`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Promo_Codes`
--

LOCK TABLES `Promo_Codes` WRITE;
/*!40000 ALTER TABLE `Promo_Codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `Promo_Codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Promo_Usage`
--

DROP TABLE IF EXISTS `Promo_Usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Promo_Usage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `promo_id` int NOT NULL,
  `user_id` int NOT NULL,
  `subscription_id` int NOT NULL,
  `used_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `promo_id` (`promo_id`),
  KEY `user_id` (`user_id`),
  KEY `subscription_id` (`subscription_id`),
  CONSTRAINT `Promo_Usage_ibfk_1` FOREIGN KEY (`promo_id`) REFERENCES `Promo_Codes` (`id`),
  CONSTRAINT `Promo_Usage_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`),
  CONSTRAINT `Promo_Usage_ibfk_3` FOREIGN KEY (`subscription_id`) REFERENCES `User_Subscriptions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Promo_Usage`
--

LOCK TABLES `Promo_Usage` WRITE;
/*!40000 ALTER TABLE `Promo_Usage` DISABLE KEYS */;
/*!40000 ALTER TABLE `Promo_Usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Queue`
--

DROP TABLE IF EXISTS `Queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `music_id` int NOT NULL,
  `position` int NOT NULL,
  `added_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `repeat_mode` enum('OFF','ONE','ALL') DEFAULT 'OFF',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_queue_position` (`user_id`,`position`),
  KEY `music_id` (`music_id`),
  CONSTRAINT `Queue_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `Queue_ibfk_2` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Queue`
--

LOCK TABLES `Queue` WRITE;
/*!40000 ALTER TABLE `Queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `Queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Rankings`
--

DROP TABLE IF EXISTS `Rankings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Rankings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `platform` varchar(255) NOT NULL,
  `music_id` int NOT NULL,
  `rank_position` int NOT NULL,
  `ranking_date` date DEFAULT (curdate()),
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_ranking` (`platform`,`music_id`,`ranking_date`),
  KEY `music_id` (`music_id`),
  KEY `idx_rankings_date` (`ranking_date`),
  KEY `idx_rankings_platform` (`platform`),
  CONSTRAINT `Rankings_ibfk_1` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Rankings`
--

LOCK TABLES `Rankings` WRITE;
/*!40000 ALTER TABLE `Rankings` DISABLE KEYS */;
/*!40000 ALTER TABLE `Rankings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Search_History`
--

DROP TABLE IF EXISTS `Search_History`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Search_History` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `query` varchar(255) NOT NULL,
  `result_count` int DEFAULT NULL,
  `searched_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `Search_History_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Search_History`
--

LOCK TABLES `Search_History` WRITE;
/*!40000 ALTER TABLE `Search_History` DISABLE KEYS */;
/*!40000 ALTER TABLE `Search_History` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Stream_Cache`
--

DROP TABLE IF EXISTS `Stream_Cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Stream_Cache` (
  `id` int NOT NULL AUTO_INCREMENT,
  `music_id` int NOT NULL,
  `stream_url` text NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_expires` (`expires_at`),
  KEY `idx_stream_cache_music` (`music_id`),
  CONSTRAINT `Stream_Cache_ibfk_1` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Stream_Cache`
--

LOCK TABLES `Stream_Cache` WRITE;
/*!40000 ALTER TABLE `Stream_Cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `Stream_Cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Streaming_Errors`
--

DROP TABLE IF EXISTS `Streaming_Errors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Streaming_Errors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `music_id` int NOT NULL,
  `error_type` varchar(50) NOT NULL,
  `error_message` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_streaming_errors_music` (`music_id`),
  CONSTRAINT `Streaming_Errors_ibfk_1` FOREIGN KEY (`music_id`) REFERENCES `Music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Streaming_Errors`
--

LOCK TABLES `Streaming_Errors` WRITE;
/*!40000 ALTER TABLE `Streaming_Errors` DISABLE KEYS */;
/*!40000 ALTER TABLE `Streaming_Errors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Subscription_Plans`
--

DROP TABLE IF EXISTS `Subscription_Plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Subscription_Plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `duration_days` int NOT NULL,
  `features` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Subscription_Plans`
--

LOCK TABLES `Subscription_Plans` WRITE;
/*!40000 ALTER TABLE `Subscription_Plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `Subscription_Plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User_Subscriptions`
--

DROP TABLE IF EXISTS `User_Subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `User_Subscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `plan_id` int NOT NULL,
  `start_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `end_date` timestamp NOT NULL,
  `auto_renewal` tinyint(1) DEFAULT '0',
  `status` enum('ACTIVE','EXPIRED','CANCELLED','PENDING') DEFAULT 'PENDING',
  PRIMARY KEY (`id`),
  KEY `plan_id` (`plan_id`),
  KEY `idx_user_subscriptions` (`user_id`,`status`),
  CONSTRAINT `User_Subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `User_Subscriptions_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `Subscription_Plans` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User_Subscriptions`
--

LOCK TABLES `User_Subscriptions` WRITE;
/*!40000 ALTER TABLE `User_Subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `User_Subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `firebase_uid` varchar(128) NOT NULL,
  `email` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `profile_pic_url` text,
  `is_premium` tinyint(1) DEFAULT '0',
  `favorite_genres` json DEFAULT NULL,
  `favorite_artists` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') DEFAULT 'ACTIVE',
  PRIMARY KEY (`id`),
  UNIQUE KEY `firebase_uid` (`firebase_uid`),
  KEY `idx_users_email` (`email`),
  KEY `idx_firebase_uid` (`firebase_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-01-09 18:02:36
