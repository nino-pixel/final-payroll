-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: example_app
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `departments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `departments_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'Human Resources','HR','Manages employee relations, recruitment, and HR policies','2024-12-21 06:11:18','2024-12-21 06:11:18'),(2,'Finance and Accounting','FIN','Manages company finances and accounting operations','2024-12-21 06:11:18','2024-12-21 06:11:18'),(3,'Sales','SALES','Drives revenue through sales activities','2024-12-21 06:11:18','2024-12-21 06:11:18'),(4,'Marketing','MKT','Handles brand management and marketing strategies','2024-12-21 06:11:18','2024-12-21 06:11:18'),(5,'Operations','OPS','Manages day-to-day business operations','2024-12-21 06:11:18','2024-12-21 06:11:18'),(6,'Information Technology','IT','Manages technology infrastructure and systems','2024-12-21 06:11:18','2024-12-21 06:11:18'),(7,'Customer Support','CS','Provides customer service and support','2024-12-21 06:11:18','2024-12-21 06:11:18'),(8,'Research and Development','RND','Focuses on innovation and product development','2024-12-21 06:11:18','2024-12-21 06:11:18'),(9,'Legal','LGL','Handles legal matters and compliance','2024-12-21 06:11:18','2024-12-21 06:11:18'),(10,'Procurement','PROC','Manages purchasing and vendor relationships','2024-12-21 06:11:18','2024-12-21 06:11:18'),(11,'Administrative','ADMIN','Provides administrative support','2024-12-21 06:11:18','2024-12-21 06:11:18'),(12,'Strategy and Business Development','SBD','Develops business strategies and growth plans','2024-12-21 06:11:18','2024-12-21 06:11:18'),(13,'Engineering','ENG','Handles technical engineering work','2024-12-21 06:11:18','2024-12-21 06:11:18'),(14,'Quality Assurance','QA','Ensures quality standards and compliance','2024-12-21 06:11:18','2024-12-21 06:11:18'),(15,'Public Relations','PR','Manages public image and communications','2024-12-21 06:11:18','2024-12-21 06:11:18'),(16,'Training and Development','TND','Manages employee training and development programs','2024-12-21 06:11:18','2024-12-21 06:11:18');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `department_id` bigint(20) unsigned NOT NULL,
  `base_salary` decimal(10,2) NOT NULL,
  `hire_date` date NOT NULL,
  `status` enum('active','inactive','on_leave') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `position_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employees_employee_id_unique` (`employee_id`),
  UNIQUE KEY `employees_email_unique` (`email`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `employees_department_id_foreign` (`department_id`),
  KEY `fk_position` (`position_id`),
  CONSTRAINT `employees_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `fk_position` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=291 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'1','Qgazrb','Rmxlnu','qgazrb.rmxlnu@example.com','09208583250',10,55382.00,'2024-06-03','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(2,'2','Ywzwwg','Qrnueh','ywzwwg.qrnueh@example.com','09989517864',5,69844.00,'2019-05-26','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(3,'3','Wfjift','Impqwt','wfjift.impqwt@example.com','09186049245',1,68834.00,'2018-02-06','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,8),(4,'4','Mhwtws','Ujhkwd','mhwtws.ujhkwd@example.com','09185441341',7,54430.00,'2023-06-21','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(5,'5','Qvrvkf','Zhmmse','qvrvkf.zhmmse@example.com','09187737948',7,50089.00,'2023-03-23','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(6,'6','Zputrt','Ydjpdt','zputrt.ydjpdt@example.com','09988683646',10,68508.00,'2021-10-18','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(7,'7','Ykpflk','Vpqiut','ykpflk.vpqiut@example.com','09204334350',6,59149.00,'2018-12-04','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(8,'8','Shedsg','Lefjwj','shedsg.lefjwj@example.com','09454754609',10,48236.00,'2017-10-09','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(9,'9','Fhvjaw','Hgsokb','fhvjaw.hgsokb@example.com','09179288083',10,59175.00,'2018-05-26','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(10,'10','Netwhc','Xuojlt','netwhc.xuojlt@example.com','09454927395',1,52677.00,'2019-02-17','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(11,'11','Visamd','Syanab','visamd.syanab@example.com','09452936387',1,51275.00,'2021-05-12','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,3),(12,'12','Kohpqn','Pkziqt','kohpqn.pkziqt@example.com','09983378876',10,69774.00,'2024-11-05','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(13,'13','Mfzbhr','Hhicah','mfzbhr.hhicah@example.com','09988462175',6,57490.00,'2016-03-25','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(14,'14','Xuuois','Oaqayk','xuuois.oaqayk@example.com','09201783766',2,58323.00,'2018-12-29','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,3),(15,'15','Mhsalg','Kskxfy','mhsalg.kskxfy@example.com','09208476106',8,59673.00,'2015-07-27','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(16,'16','Gxdsnz','Vnfwkk','gxdsnz.vnfwkk@example.com','09171483382',6,58804.00,'2020-02-05','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(17,'17','Dgbyez','Ablbrm','dgbyez.ablbrm@example.com','09453954445',8,55257.00,'2019-08-26','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(18,'18','Tpuxiq','Yoiecu','tpuxiq.yoiecu@example.com','09457646694',5,61063.00,'2015-10-16','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(19,'19','Xykmif','Qvtslv','xykmif.qvtslv@example.com','09189665687',2,46095.00,'2019-11-14','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(20,'20','Wcmqbn','Epxwof','wcmqbn.epxwof@example.com','09209552683',4,40895.00,'2023-01-11','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(21,'21','Zccdgg','Qfcgkk','zccdgg.qfcgkk@example.com','09187271022',6,56827.00,'2024-12-21','on_leave','2024-12-21 06:58:21','2024-12-21 07:58:12',NULL,37),(22,'22','Fhbokk','Mnrwqh','fhbokk.mnrwqh@example.com','09458554202',6,59948.00,'2019-09-06','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(23,'23','Cvdorq','Jjeqhh','cvdorq.jjeqhh@example.com','09183260579',1,45106.00,'2015-04-05','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(24,'24','Bmuplu','Btpqkf','bmuplu.btpqkf@example.com','09179445671',8,54618.00,'2018-02-18','inactive','2024-12-21 06:58:21','2024-12-21 06:58:50','2024-12-21 06:58:50',8),(25,'25','Vrjrsl','Mlugwf','vrjrsl.mlugwf@example.com','09179452924',6,46777.00,'2015-06-23','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(26,'26','Lpkgzu','Gyfkgl','lpkgzu.gyfkgl@example.com','09204109109',1,42441.00,'2020-06-20','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(27,'27','Rwvrib','Knyaok','rwvrib.knyaok@example.com','09981006512',1,56116.00,'2024-11-08','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(28,'28','Jdpypf','Svuhgk','jdpypf.svuhgk@example.com','09205424257',8,67069.00,'2015-08-20','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,8),(29,'29','Tcvbkt','Tyfkck','tcvbkt.tyfkck@example.com','09453658422',10,68078.00,'2024-04-08','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(30,'30','Ryuitz','Lombaj','ryuitz.lombaj@example.com','09982031837',3,40711.00,'2021-06-20','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(31,'31','Bmkjfk','Abzmuq','bmkjfk.abzmuq@example.com','09204803659',4,40562.00,'2022-12-16','inactive','2024-12-21 06:58:21','2024-12-21 06:55:24','2024-12-21 06:55:24',2),(32,'32','Jhopjk','Asuebz','jhopjk.asuebz@example.com','09981594243',2,59979.00,'2020-10-05','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(33,'33','Fhgrub','Gkteiw','fhgrub.gkteiw@example.com','09457255914',1,67289.00,'2020-10-03','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(34,'34','Efosfc','Mtbgnt','efosfc.mtbgnt@example.com','09981958839',5,55016.00,'2021-11-18','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,8),(35,'35','Dmbxan','Wnhfja','dmbxan.wnhfja@example.com','09981784514',5,50452.00,'2018-02-21','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,8),(36,'36','Tmahro','Qmqbat','tmahro.qmqbat@example.com','09983076139',3,46469.00,'2021-08-10','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(37,'37','Rfcjdc','Busbjd','rfcjdc.busbjd@example.com','09457321867',2,67059.00,'2018-09-09','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(38,'38','Bvmayq','Ebyond','bvmayq.ebyond@example.com','09209946563',9,65982.00,'2022-09-18','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(39,'39','Vshwtt','Gzoeec','vshwtt.gzoeec@example.com','09201446733',7,60087.00,'2018-05-27','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(40,'40','Zgcksm','Xlinpv','zgcksm.xlinpv@example.com','09457769715',9,47738.00,'2022-01-16','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(41,'41','Irtnyx','Qxawbb','irtnyx.qxawbb@example.com','09183025319',3,65716.00,'2023-12-01','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(42,'42','Avppwg','Zorilm','avppwg.zorilm@example.com','09986212331',1,61180.00,'2021-01-26','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(43,'43','Mxauyc','Iffpwb','mxauyc.iffpwb@example.com','09184110313',9,55920.00,'2023-12-28','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(44,'44','Cfkymj','Erutdr','cfkymj.erutdr@example.com','09983248666',3,41286.00,'2016-08-14','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(45,'45','Hxdzau','Gftmzu','hxdzau.gftmzu@example.com','09201438361',8,45548.00,'2021-12-04','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(46,'46','Gumfky','Klvrta','gumfky.klvrta@example.com','09204981648',4,69679.00,'2016-07-22','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(47,'47','Xxdjru','Lnbtxn','xxdjru.lnbtxn@example.com','09451209488',3,44680.00,'2023-06-24','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(48,'48','Fpvnbm','Padjdh','fpvnbm.padjdh@example.com','09987629249',6,48873.00,'2024-11-29','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(49,'49','Pyfkqs','Thuvnz','pyfkqs.thuvnz@example.com','09987626886',9,63696.00,'2024-05-26','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(50,'50','Fhwyqk','Dvgmla','fhwyqk.dvgmla@example.com','09182083609',3,46706.00,'2020-06-23','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(51,'51','Ogiybv','Mtoiui','ogiybv.mtoiui@example.com','09181827183',1,48879.00,'2017-12-16','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(52,'52','Eivxue','Rerjtb','eivxue.rerjtb@example.com','09983545759',5,67139.00,'2019-09-22','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(53,'53','Gjvrap','Sllqvt','gjvrap.sllqvt@example.com','09204073800',1,67220.00,'2016-08-25','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(54,'54','Epnobs','Uuqnlk','epnobs.uuqnlk@example.com','09208710570',9,66948.00,'2017-02-08','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(55,'55','Mlfhzz','Gvtmbp','mlfhzz.gvtmbp@example.com','09185685154',5,44435.00,'2019-06-17','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,3),(56,'56','Bnkary','Qlblof','bnkary.qlblof@example.com','09459024741',8,53636.00,'2021-10-02','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(57,'57','Eatbol','Eqagsi','eatbol.eqagsi@example.com','09981394206',4,61962.00,'2021-06-14','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(58,'58','Ysukcv','Aawvmt','ysukcv.aawvmt@example.com','09208861690',1,45846.00,'2016-07-16','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(59,'59','Wisegp','Sbgcyr','wisegp.sbgcyr@example.com','09201480323',3,46880.00,'2021-11-04','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(60,'60','Jjqmxo','Xifkpz','jjqmxo.xifkpz@example.com','09176040967',10,53895.00,'2024-05-08','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(61,'61','Hnkbyc','Bciboa','hnkbyc.bciboa@example.com','09985187264',8,42192.00,'2016-10-02','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(62,'62','Lbuqiu','Dxudck','lbuqiu.dxudck@example.com','09455475983',9,45427.00,'2018-05-16','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(63,'63','Upelkw','Ekrcny','upelkw.ekrcny@example.com','09185120183',8,51718.00,'2015-04-28','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(64,'64','Cvuhdp','Qgrvog','cvuhdp.qgrvog@example.com','09186704249',9,41313.00,'2015-08-20','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,3),(65,'65','Pyzejm','Ielbyw','pyzejm.ielbyw@example.com','09181728979',5,64113.00,'2024-11-27','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(66,'66','Lbksan','Vdsjmw','lbksan.vdsjmw@example.com','09451043850',4,53513.00,'2016-05-07','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(67,'67','Fwawbh','Ripxny','fwawbh.ripxny@example.com','09989191124',4,42936.00,'2021-11-07','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(68,'68','Lpupeq','Kxcuyj','lpupeq.kxcuyj@example.com','09454369593',7,43101.00,'2024-12-11','inactive','2024-12-21 06:58:21','2024-12-21 09:02:23',NULL,46),(69,'69','Ahxurh','Qeqand','ahxurh.qeqand@example.com','09458020400',5,69462.00,'2018-07-06','inactive','2024-12-21 06:58:21','2024-12-21 07:35:46','2024-12-21 07:35:46',4),(70,'70','Zehhez','Chidbz','zehhez.chidbz@example.com','09207161608',7,59455.00,'2024-06-20','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(71,'71','Mkwuaw','Wuwscg','mkwuaw.wuwscg@example.com','09182240985',5,58377.00,'2018-11-20','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(72,'72','Qkzdvp','Khgitd','qkzdvp.khgitd@example.com','09184418527',1,55776.00,'2024-03-09','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(73,'73','Gcwgmp','Yyzxna','gcwgmp.yyzxna@example.com','09185923631',2,57949.00,'2018-04-28','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(74,'74','Kgdpya','Kcuktu','kgdpya.kcuktu@example.com','09456116114',1,45789.00,'2023-03-23','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(75,'75','Uqjooa','Keycos','uqjooa.keycos@example.com','09181031611',6,62738.00,'2019-11-04','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(76,'76','Lugpew','Bclylu','lugpew.bclylu@example.com','09177301226',6,50535.00,'2019-05-21','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(77,'77','Crymsx','Ebembc','crymsx.ebembc@example.com','09174610169',3,56510.00,'2023-10-24','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(78,'78','Hcuhtl','Xmauyp','hcuhtl.xmauyp@example.com','09457657681',4,62015.00,'2023-01-27','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(79,'79','Asdhld','Cgwfle','asdhld.cgwfle@example.com','09171672827',9,49421.00,'2022-06-16','inactive','2024-12-21 06:58:21','2024-12-21 07:39:18','2024-12-21 07:39:18',9),(80,'80','Herjhk','Xlamaq','herjhk.xlamaq@example.com','09984995629',4,54370.00,'2019-03-21','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(81,'81','Otncks','Rjtlqc','otncks.rjtlqc@example.com','09171802178',10,57886.00,'2020-04-11','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(82,'82','Yhoqzd','Abkjiy','yhoqzd.abkjiy@example.com','09188684079',9,44124.00,'2024-03-20','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(83,'83','Bczbxf','Xzrztg','bczbxf.xzrztg@example.com','09176526043',1,44909.00,'2016-05-25','inactive','2024-12-21 06:58:21','2024-12-21 06:58:54','2024-12-21 06:58:54',7),(84,'84','Uezykt','Zysuxe','uezykt.zysuxe@example.com','09181441501',3,41443.00,'2017-01-07','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(85,'85','Fcafpa','Jqlrxa','fcafpa.jqlrxa@example.com','09189912520',6,48178.00,'2022-01-06','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(86,'86','Psvabn','Boxgvf','psvabn.boxgvf@example.com','09454728430',6,44949.00,'2016-04-23','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(87,'87','Gnyyle','Eqxeiu','gnyyle.eqxeiu@example.com','09204890175',9,55117.00,'2019-04-20','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(88,'88','gfgfg','Frmhjz','bddcgv.frmhjz@example.com','09984818468',10,54960.00,'2024-12-31','active','2024-12-21 06:58:21','2024-12-21 06:55:40',NULL,67),(89,'89','Dbimhn','Lwqdmk','dbimhn.lwqdmk@example.com','09455863097',7,69652.00,'2018-12-18','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,2),(90,'90','Zuruie','Ezosxa','zuruie.ezosxa@example.com','09452511818',3,56476.00,'2017-01-15','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(91,'91','Usgbar','Uobjhe','usgbar.uobjhe@example.com','09187905892',2,49017.00,'2016-09-21','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,9),(92,'92','Cwmcew','Rygjog','cwmcew.rygjog@example.com','09176802510',8,43106.00,'2015-06-15','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(93,'93','Sqpwmj','Vrcxre','sqpwmj.vrcxre@example.com','09988650502',8,40783.00,'2018-11-21','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,6),(94,'94','Evteeo','Ssukmg','evteeo.ssukmg@example.com','09173135491',4,63774.00,'2020-08-23','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,8),(95,'95','Catnai','Ytdjxz','catnai.ytdjxz@example.com','09457093146',5,42158.00,'2019-12-25','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(96,'96','Epvhmt','Mrodgn','epvhmt.mrodgn@example.com','09206033118',2,54827.00,'2015-12-13','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,4),(97,'97','Asvtbz','Kqmmmh','asvtbz.kqmmmh@example.com','09177277452',3,53112.00,'2022-12-31','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,1),(98,'98','Hdnlce','Dixook','hdnlce.dixook@example.com','09452735561',10,60752.00,'2020-03-11','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,10),(99,'99','Xbueki','Rgttrj','xbueki.rgttrj@example.com','09187772983',7,54056.00,'2021-04-30','inactive','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,5),(100,'100','Qfmvlf','Vtjozj','qfmvlf.vtjozj@example.com','09201462453',8,64935.00,'2018-08-20','active','2024-12-21 06:58:21','2024-12-21 06:58:21',NULL,7),(279,'101','antonino','balinado jr','antoninobalinado756@gmail.com','09563265328',1,50000.00,'2024-12-21','active','2024-12-21 01:25:03','2024-12-21 07:45:12',NULL,1),(280,'EMP001','John','Doe','john.doe@example.com','1234567890',1,50000.00,'2024-01-15','active','2024-12-21 01:38:50','2024-12-21 01:38:50',NULL,1),(281,'107','gaga','gag','gag@gmail.com','09563265328',1,50000.00,'2024-01-15','active','2024-12-21 05:29:45','2024-12-21 05:29:45',NULL,1),(282,'EMP0282','gaga','gaga','gaga@gmail.com',NULL,11,43434.00,'2024-12-21','active','2024-12-21 06:07:09','2024-12-21 19:40:15','2024-12-21 19:40:15',72),(283,'EMP0283','gaga','gaga','asdf@gmail.com',NULL,7,11111.00,'2024-12-12','active','2024-12-21 06:08:16','2024-12-21 06:08:16',NULL,45),(284,'EMP0284','asdfa','asdf','asdfad@fsd.com',NULL,11,33333.00,'2024-12-30','active','2024-12-21 06:14:22','2024-12-21 06:58:58','2024-12-21 06:58:58',71),(285,'EMP0285','asdfa','asdf','asfdfad@fsd.com',NULL,11,33333.00,'2024-12-30','active','2024-12-21 06:14:47','2024-12-21 06:59:02','2024-12-21 06:59:02',71),(286,'EMP0286','DFGH','DGHDF','JHFG@DYSF.COM',NULL,7,55555.00,'2024-12-14','active','2024-12-21 06:33:34','2024-12-21 06:33:34',NULL,47),(287,'EMP0287','bobobo','bobobbo','bobo@gmail.com',NULL,7,44444.00,'2024-12-25','active','2024-12-21 06:44:11','2024-12-21 06:44:11',NULL,49),(289,'EMP0288','rena','reana','d@ed.com',NULL,11,4334.00,'2024-12-25','active','2024-12-21 11:14:14','2024-12-21 11:14:14',NULL,71),(290,'EMP0290','adfasf','werwerwr','afda@ff.xch',NULL,11,3333.00,'2024-12-26','active','2024-12-21 11:16:26','2024-12-21 19:40:11','2024-12-21 19:40:11',73);
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2024_12_20_031117_create_users_table',1),(2,'2024_12_20_031129_create_cache_table',1),(3,'2024_12_20_031137_create_jobs_table',1),(4,'2024_12_20_031141_create_departments_table',1),(5,'2024_12_20_031151_create_employees_table',1),(6,'2024_12_20_031152_create_attendances_table',1),(7,'2024_12_20_031152_create_salary_adjustments_table',1),(8,'2024_12_20_031153_create_payrolls_table',1),(9,'2024_12_20_031154_create_payroll_details_table',1),(10,'2024_12_20_031159_create_personal_access_tokens_table',1),(11,'2024_12_20_034913_create_sessions_table',1),(12,'2024_12_20_071533_create_positions_table',1),(13,'2024_12_20_085746_add_soft_deletes_to_employees_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_details`
--

DROP TABLE IF EXISTS `payroll_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payroll_details` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_details`
--

LOCK TABLES `payroll_details` WRITE;
/*!40000 ALTER TABLE `payroll_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payrolls`
--

DROP TABLE IF EXISTS `payrolls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payrolls` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payrolls`
--

LOCK TABLES `payrolls` WRITE;
/*!40000 ALTER TABLE `payrolls` DISABLE KEYS */;
/*!40000 ALTER TABLE `payrolls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',2,'auth_token','cfeca15e0eea9df520fb4ca9d8935491a032b8025a91c12660646ab1ae34cb76','[\"*\"]',NULL,NULL,'2024-12-20 07:18:14','2024-12-20 07:18:14'),(2,'App\\Models\\User',2,'auth_token','d53854c19c7a6bc682840a73894710c57034bfcf8810afcd815d2685b9f07f93','[\"*\"]',NULL,NULL,'2024-12-20 07:19:40','2024-12-20 07:19:40'),(3,'App\\Models\\User',2,'auth_token','762ce9b30a3436ba04c95affb138708a4c9fe9100db3b9924e1a3396fc053bd9','[\"*\"]',NULL,NULL,'2024-12-20 07:19:53','2024-12-20 07:19:53'),(4,'App\\Models\\User',3,'auth_token','6155999bd784953344852fb4e914224ef67523752920039961750807c71a9fa7','[\"*\"]',NULL,NULL,'2024-12-20 07:27:55','2024-12-20 07:27:55'),(5,'App\\Models\\User',2,'auth_token','008243c954d75264873898c4f8189decc6b557f2a9a655c17e4498b74331ac40','[\"*\"]',NULL,NULL,'2024-12-20 07:28:20','2024-12-20 07:28:20'),(6,'App\\Models\\User',2,'auth_token','910c8ab14e2cb4ac48a73fb389afd5af28a127ee5e6dd278b3a731f6ae0da05b','[\"*\"]',NULL,NULL,'2024-12-20 07:28:35','2024-12-20 07:28:35'),(7,'App\\Models\\User',2,'auth_token','564914d7d7f0241bf324a4cad426d602803092e98c1deba3fb29b669cd88b121','[\"*\"]',NULL,NULL,'2024-12-20 07:35:25','2024-12-20 07:35:25'),(8,'App\\Models\\User',2,'auth_token','944e9e291476acae34ad6028885bbc6a48e8be08ee87ac2ed8b13376532dd1ee','[\"*\"]',NULL,NULL,'2024-12-20 07:35:30','2024-12-20 07:35:30'),(9,'App\\Models\\User',2,'auth_token','626077fb7ecd1e816e55ca307db92e1d5aaed99a88f0fac0d24d83bfa4a81302','[\"*\"]',NULL,NULL,'2024-12-20 07:35:40','2024-12-20 07:35:40'),(10,'App\\Models\\User',2,'auth_token','ab476221283a10375a74c23c8fcc7165464c357f7e1f2160928dbc6b9361e82c','[\"*\"]',NULL,NULL,'2024-12-20 07:37:42','2024-12-20 07:37:42'),(11,'App\\Models\\User',2,'auth_token','97f065c375384b3d38203e38c7a4563760defa810eebe2898f0ea2dee11a48ef','[\"*\"]',NULL,NULL,'2024-12-20 07:48:53','2024-12-20 07:48:53'),(12,'App\\Models\\User',2,'auth_token','61d3701a69bb31b98e651bcb804963fb71bc8d3806f1ae69b31184d692b3f178','[\"*\"]',NULL,NULL,'2024-12-20 07:49:34','2024-12-20 07:49:34'),(13,'App\\Models\\User',2,'auth_token','0b64df606af7e4a9e96f38f05f3c8247dc2da89a32ab6b37cc3aef209d670eed','[\"*\"]',NULL,NULL,'2024-12-20 07:49:42','2024-12-20 07:49:42'),(14,'App\\Models\\User',2,'auth_token','a22cb52d1957b9d301cc68655e39a9334793406ab4b835f0648a5ef675df5849','[\"*\"]','2024-12-21 05:05:08',NULL,'2024-12-20 07:49:48','2024-12-21 05:05:08'),(15,'App\\Models\\User',2,'auth_token','95f1c0759ddc85c5a69713cf52ec6706d3e5c4d3587f447d8daba98e06e97e42','[\"*\"]',NULL,NULL,'2024-12-20 07:57:07','2024-12-20 07:57:07'),(16,'App\\Models\\User',2,'auth_token','84b3cad0771ebf748bc6d8a81948a1ad54d9f331e943eebab366ca5ba3516be0','[\"*\"]',NULL,NULL,'2024-12-20 21:59:30','2024-12-20 21:59:30'),(17,'App\\Models\\User',2,'auth_token','6afb88deb57ea2aebdaf3bd227a910b26f9c59f596456bf22a4edc028ed706db','[\"*\"]','2024-12-20 23:31:24',NULL,'2024-12-20 22:00:15','2024-12-20 23:31:24'),(18,'App\\Models\\User',104,'auth_token','b777e153e7d854e10ab5263a1ce389a44cebf30cbb829a6c1abcad1c5d234411','[\"*\"]','2024-12-21 00:51:45',NULL,'2024-12-20 23:37:29','2024-12-21 00:51:45'),(19,'App\\Models\\User',105,'auth_token','bf33219d7d1738bd850c913656be6cb6ce9e2fe7f0142a73701bd66e156b1195','[\"*\"]',NULL,NULL,'2024-12-21 01:35:19','2024-12-21 01:35:19'),(20,'App\\Models\\User',2,'auth_token','d0f3bdffc9307970349b40dbf8c712a683f960603ad29b8372c688cdbbbd7bd5','[\"*\"]','2024-12-21 01:38:49',NULL,'2024-12-21 01:37:07','2024-12-21 01:38:49'),(21,'App\\Models\\User',2,'auth_token','c620a8031b8217becdc8b1d5671d334be6beb2ff7c0be56901f5c1d52fe5c873','[\"*\"]','2024-12-21 01:47:07',NULL,'2024-12-21 01:41:17','2024-12-21 01:47:07'),(22,'App\\Models\\User',106,'auth_token','fbfdd5f62730e3a2132e6d5d6a0b1b68e928f8ff151d75e19b999ab29b18a8f0','[\"*\"]',NULL,NULL,'2024-12-27 20:23:29','2024-12-27 20:23:29'),(23,'App\\Models\\User',106,'auth_token','39ba3f54efae878d7b5c2aa091416f63703b6bef27d5a68bb13681161508017a','[\"*\"]',NULL,NULL,'2024-12-27 20:24:06','2024-12-27 20:24:06');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `positions`
--

DROP TABLE IF EXISTS `positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `positions` (
  `id` int(11) NOT NULL,
  `department_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `positions_department_id_foreign` (`department_id`),
  CONSTRAINT `positions_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `positions`
--

LOCK TABLES `positions` WRITE;
/*!40000 ALTER TABLE `positions` DISABLE KEYS */;
INSERT INTO `positions` VALUES (1,1,'HR Manager/Director',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(2,1,'Recruiter',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(3,1,'Training and Development Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(4,1,'HR Generalist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(5,1,'Payroll Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(6,1,'Benefits Coordinator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(7,1,'Employee Relations Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(8,2,'Chief Financial Officer (CFO)',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(9,2,'Finance Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(10,2,'Accountant',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(11,2,'Bookkeeper',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(12,2,'Financial Analyst',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(13,2,'Accounts Payable/Receivable Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(14,2,'Tax Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(15,3,'Sales Manager/Director',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(16,3,'Account Executive',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(17,3,'Business Development Representative',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(18,3,'Sales Associate/Representative',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(19,3,'Key Account Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(20,3,'Sales Coordinator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(21,3,'Territory Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(22,4,'Chief Marketing Officer (CMO)',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(23,4,'Marketing Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(24,4,'Content Strategist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(25,4,'Social Media Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(26,4,'Graphic Designer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(27,4,'SEO Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(28,4,'Market Research Analyst',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(29,4,'Brand Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(30,5,'Chief Operating Officer (COO)',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(31,5,'Operations Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(32,5,'Logistics Coordinator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(33,5,'Supply Chain Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(34,5,'Inventory Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(35,5,'Quality Assurance (QA) Officer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(36,5,'Process Improvement Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(37,6,'Chief Information Officer (CIO)',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(38,6,'IT Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(39,6,'Network Administrator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(40,6,'Systems Analyst',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(41,6,'Cybersecurity Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(42,6,'Help Desk Technician',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(43,6,'Software Developer/Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(44,6,'Database Administrator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(45,7,'Customer Support Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(46,7,'Customer Service Representative',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(47,7,'Call Center Agent',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(48,7,'Technical Support Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(49,7,'Customer Experience Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(50,7,'Help Desk Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(51,7,'Retention Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(52,8,'R&D Manager/Director',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(53,8,'Research Scientist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(54,8,'Product Developer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(55,8,'Innovation Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(56,8,'Laboratory Technician',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(57,8,'Data Scientist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(58,9,'General Counsel/Chief Legal Officer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(59,9,'Legal Advisor',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(60,9,'Corporate Lawyer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(61,9,'Paralegal',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(62,9,'Compliance Officer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(63,9,'Contract Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(64,9,'Intellectual Property Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(65,10,'Procurement Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(66,10,'Purchasing Agent',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(67,10,'Vendor Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(68,10,'Inventory Controller',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(69,10,'Sourcing Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(70,10,'Procurement Analyst',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(71,11,'Administrative Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(72,11,'Office Administrator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(73,11,'Executive Assistant',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(74,11,'Receptionist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(75,11,'Data Entry Clerk',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(76,11,'Office Coordinator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(77,12,'Chief Strategy Officer (CSO)',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(78,12,'Business Development Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(79,12,'Strategic Planner',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(80,12,'Partnership Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(81,12,'Market Expansion Analyst',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(82,13,'Chief Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(83,13,'Mechanical Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(84,13,'Electrical Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(85,13,'Civil Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(86,13,'Software Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(87,13,'Project Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(88,13,'Design Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(89,14,'QA Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(90,14,'QA Analyst',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(91,14,'QA Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(92,14,'Test Engineer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(93,14,'Quality Inspector',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(94,14,'Compliance Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(95,15,'PR Manager/Director',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(96,15,'Media Relations Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(97,15,'Communications Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(98,15,'Event Coordinator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(99,15,'Publicist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(100,15,'Community Relations Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(101,16,'Training Manager',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(102,16,'Corporate Trainer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(103,16,'Instructional Designer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(104,16,'Learning and Development Specialist',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(105,16,'E-Learning Developer',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56'),(106,16,'Training Coordinator',NULL,'2024-12-21 06:11:56','2024-12-21 06:11:56');
/*!40000 ALTER TABLE `positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_adjustments`
--

DROP TABLE IF EXISTS `salary_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `salary_adjustments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_adjustments`
--

LOCK TABLES `salary_adjustments` WRITE;
/*!40000 ALTER TABLE `salary_adjustments` DISABLE KEYS */;
/*!40000 ALTER TABLE `salary_adjustments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('jQvdelse3EuBpesVvs54rO7aZkstoEaVQSL410R3',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiQ1hFMDZxYWVNaTh4dkhoQzl3Q2w3UVdhbUQzMmRodFFhWGpBMnVIbyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zYW5jdHVtL2NzcmYtY29va2llIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1734839267),('wTE5ElXXPyw5dVJPNIZnjJUV6TeSQlwzOAZS4Aco',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiYzlRZW5KYlI1OFBQWUdySGVFempIcUIyV01hZXdyMFJOUGEzZVpSbyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9zYW5jdHVtL2NzcmYtY29va2llIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1734809046);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Test User','test@example.com','$2y$12$5MPy8iVMKx6nV2LIMzPzo.XRFN9clRgFpvWoEGNCkT86xDPxalP8i',NULL,'2024-12-20 07:00:08','2024-12-20 07:00:08'),(2,'sheena','sheena@gmail.com','$2y$12$kpwFlkgscWF6vvbsVqwcGOrquPFZtiz8uBYjLiKLKEOS73XxiATlO',NULL,'2024-12-20 07:18:13','2024-12-20 07:18:13'),(3,'jayron','jayron@gmail.com','$2y$12$.eiPfxeHvRmd6CCg3dRh.OPo0XobcfEeGPo6wfRNehwY9n2Xx/TfC',NULL,'2024-12-20 07:27:54','2024-12-20 07:27:54'),(4,'Urvjty Yqpnfx','urvjty.yqpnfx@mail.com','PVDmJKuU',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(5,'Kxrspk Jkshsz','kxrspk.jkshsz@test.com','d6KieXl2',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(6,'Ryspfv Cpsgns','ryspfv.cpsgns@mail.com','iegBwm9n',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(7,'Ofbsok Arplfv','ofbsok.arplfv@mail.com','38XSv1CR',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(8,'Mqbejm Ciwyng','mqbejm.ciwyng@demo.com','W4kJlIDy',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(9,'Vccciw Vngmfj','vccciw.vngmfj@test.com','6k3FhubT',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(10,'Atoqqo Ucfdod','atoqqo.ucfdod@demo.com','YZJWZhHr',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(11,'Kkpudk Rygubr','kkpudk.rygubr@example.com','vesFeeHF',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(12,'Hlohiy Krxvpe','hlohiy.krxvpe@mail.com','50Lahjb9',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(13,'Jfvhwd Dmjkaq','jfvhwd.dmjkaq@demo.com','OSTOUF23',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(14,'Gqzsqi Ifuczz','gqzsqi.ifuczz@test.com','taCUZKYx',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(15,'Ffgxws Ojdnaz','ffgxws.ojdnaz@example.com','yOYepbiP',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(16,'Fanlrg Sveskf','fanlrg.sveskf@test.com','lMI9ik6w',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(17,'Aesrib Rrzgzg','aesrib.rrzgzg@test.com','ryE2XZyn',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(18,'Drnaye Rlxaiy','drnaye.rlxaiy@mail.com','tZZiwHCZ',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(19,'Rvrnre Iihpuv','rvrnre.iihpuv@test.com','yVEUEVsy',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(20,'Chukey Lxkbmn','chukey.lxkbmn@test.com','zeqxpSX6',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(21,'Muanzt Zfgkyz','muanzt.zfgkyz@example.com','GjRLYjM3',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(22,'Jwvgay Ygncue','jwvgay.ygncue@test.com','TDaMN0BL',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(23,'Itzggo Tjkldc','itzggo.tjkldc@demo.com','11P8onoh',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(24,'Sjeinp Eeoanj','sjeinp.eeoanj@mail.com','F1sDg1iL',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(25,'Dckfll Dmynmw','dckfll.dmynmw@demo.com','l4CYBbqr',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(26,'Yrpbyo Enkaxm','yrpbyo.enkaxm@example.com','RjoIRRBN',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(27,'Hsxdnt Pvsqno','hsxdnt.pvsqno@mail.com','ajw8JPkK',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(28,'Tgrffc Oimsty','tgrffc.oimsty@example.com','wUDToGml',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(29,'Uhkyog Sjqrft','uhkyog.sjqrft@demo.com','M0WCMHyC',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(30,'Ldonuv Tfjugp','ldonuv.tfjugp@example.com','2I2oMpYk',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(31,'Zpkrqw Lzfzal','zpkrqw.lzfzal@demo.com','QDQn0mbY',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(32,'Utiuyt Gyywai','utiuyt.gyywai@demo.com','vgiAMGUU',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(33,'Etasvc Irjxqe','etasvc.irjxqe@example.com','WESJBBgU',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(34,'Dcnrsn Mjohry','dcnrsn.mjohry@example.com','pxsWoTXG',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(35,'Cegzxg Mqnuul','cegzxg.mqnuul@example.com','lhikd9JK',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(36,'Aanpzi Rcfrwu','aanpzi.rcfrwu@example.com','LpXaSGjn',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(37,'Wxcdqf Nbkmmh','wxcdqf.nbkmmh@test.com','1PEvuDiS',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(38,'Cdedkm Yihbmk','cdedkm.yihbmk@mail.com','ETDNuRGC',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(39,'Lagdev Jxjkqj','lagdev.jxjkqj@example.com','aoZc4yJl',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(40,'Mvsooj Jyrsxu','mvsooj.jyrsxu@demo.com','Pj1Ki0E9',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(41,'Ihgaws Yekdqz','ihgaws.yekdqz@example.com','NwhiQspU',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(42,'Mukpej Iviuoa','mukpej.iviuoa@example.com','uTm7nVrb',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(43,'Tesxgl Nevhcx','tesxgl.nevhcx@mail.com','v2ppYzx6',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(44,'Xqtdfj Vrvqrw','xqtdfj.vrvqrw@example.com','BUDwGH7T',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(45,'Dapxem Yeotto','dapxem.yeotto@test.com','3hcJNLig',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(46,'Vctlns Chbkzv','vctlns.chbkzv@mail.com','uVsHLyK8',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(47,'Jabppq Cteank','jabppq.cteank@example.com','Js02yc4J',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(48,'Obziac Uaiqtp','obziac.uaiqtp@mail.com','4Qd3lqjL',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(49,'Fchnfx Tqsnxs','fchnfx.tqsnxs@example.com','rqapj5nr',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(50,'Qohsgu Dlgkmc','qohsgu.dlgkmc@mail.com','KjDEM9yx',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(51,'Gbdcbs Xydxwx','gbdcbs.xydxwx@demo.com','cXH5XygH',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(52,'Itlazd Hnsvkz','itlazd.hnsvkz@test.com','JIIhIV98',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(53,'Evrezm Beziwg','evrezm.beziwg@demo.com','QHtqq4rm',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(54,'Cpdlmf Bbcjhm','cpdlmf.bbcjhm@mail.com','PbWao3EI',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(55,'Ovvgfh Iganhj','ovvgfh.iganhj@mail.com','56x106Li',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(56,'Mlkytr Lpxnsa','mlkytr.lpxnsa@mail.com','KZU6eyFW',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(57,'Rqmnkh Brgopc','rqmnkh.brgopc@mail.com','7LQijA1e',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(58,'Prywlk Ysaxuz','prywlk.ysaxuz@demo.com','IybKMve2',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(59,'Vzaevh Kdxhnm','vzaevh.kdxhnm@test.com','MDHrO9vH',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(60,'Joblru Yqvyaf','joblru.yqvyaf@demo.com','C9ahyuBq',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(61,'Pzqoza Wvubiu','pzqoza.wvubiu@mail.com','qEmyWs8j',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(62,'Tififn Thahow','tififn.thahow@demo.com','OR6xCabD',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(63,'Zofpmi Icistd','zofpmi.icistd@demo.com','59cPId55',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(64,'Iqypgq Fzayoj','iqypgq.fzayoj@test.com','rh3tIroD',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(65,'Kvojfb Hqjqqa','kvojfb.hqjqqa@mail.com','74DsSLVH',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(66,'Hsatby Wjhdma','hsatby.wjhdma@test.com','XsU4FNQf',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(67,'Awogcz Yioarr','awogcz.yioarr@demo.com','epIxeu0j',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(68,'Qfkhmn Sqvzxh','qfkhmn.sqvzxh@demo.com','JPaaMZJy',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(69,'Rwaxlo Admwgq','rwaxlo.admwgq@demo.com','L8JLFY9H',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(70,'Ttkjsu Tzutev','ttkjsu.tzutev@demo.com','tYxWpZuz',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(71,'Twimci Kjqzap','twimci.kjqzap@example.com','jv0pcWDN',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(72,'Utkwcf Wmczvj','utkwcf.wmczvj@example.com','qS4TrDIY',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(73,'Tyyipe Cirzis','tyyipe.cirzis@test.com','fUvYQzbz',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(74,'Burukm Fqojtk','burukm.fqojtk@test.com','OkzvqSoB',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(75,'Hakcjl Ekkzlo','hakcjl.ekkzlo@mail.com','Kn8gYM4R',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(76,'Lmdopa Bihguk','lmdopa.bihguk@mail.com','ehGxKZ8k',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(77,'Ccsosy Ipwpjo','ccsosy.ipwpjo@demo.com','fSlBdNyC',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(78,'Qvcdbu Pcwuxe','qvcdbu.pcwuxe@mail.com','eUARGOZc',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(79,'Ljubyq Jwyiwp','ljubyq.jwyiwp@example.com','3rcAgSI8',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(80,'Gkthxe Hkzqrz','gkthxe.hkzqrz@mail.com','qx36UmIU',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(81,'Qburrj Egsiyc','qburrj.egsiyc@demo.com','HO2N0VMv',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(82,'Buzinv Geblrj','buzinv.geblrj@mail.com','GZykBii4',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(83,'Gbqovv Rsbwzj','gbqovv.rsbwzj@test.com','7MAV44Ys',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(84,'Fibmzn Payqmn','fibmzn.payqmn@example.com','8QY2KmhU',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(85,'Yvksio Fenfbq','yvksio.fenfbq@demo.com','VjJDl2fa',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(86,'Lwderq Lwnwsp','lwderq.lwnwsp@example.com','aJCeJ7l9',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(87,'Najvmi Inujzr','najvmi.inujzr@example.com','ouZUnouF',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(88,'Ezbnwr Arqlhi','ezbnwr.arqlhi@test.com','xRWS81gQ',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(89,'Wigriw Vnjeao','wigriw.vnjeao@test.com','cEi73cEO',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(90,'Dkapeo Dezrzd','dkapeo.dezrzd@example.com','jP5tFa0W',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(91,'Lcjfvb Ltowka','lcjfvb.ltowka@mail.com','MCZaADBL',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(92,'Gtgabb Wrkpxg','gtgabb.wrkpxg@test.com','XXzs5BTq',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(93,'Qbflko Wxybmh','qbflko.wxybmh@mail.com','kLu3lrkj',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(94,'Omjvce Casabw','omjvce.casabw@mail.com','6uzhaUGu',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(95,'Jhpmdh Uagfgj','jhpmdh.uagfgj@test.com','taonRikS',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(96,'Surekv Oglazf','surekv.oglazf@example.com','L4W8ImA5',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(97,'Zdsepe Zmjsbj','zdsepe.zmjsbj@demo.com','E7Uo18d3',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(98,'Zbktpc Upqdnq','zbktpc.upqdnq@demo.com','2Gvj76Pl',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(99,'Psduwl Wjnkxt','psduwl.wjnkxt@test.com','OqF1FPcs',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(100,'Wgelyd Qxsbgj','wgelyd.qxsbgj@test.com','WT3uXQwq',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(101,'Kupbro Enmmex','kupbro.enmmex@example.com','ewvUN9mR',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(102,'Pucfma Eevlor','pucfma.eevlor@demo.com','z8xyOaEM',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(103,'Xoescl Sjbbxi','xoescl.sjbbxi@mail.com','tLUuWzqc',NULL,'2024-12-21 07:20:00','2024-12-21 07:20:00'),(104,'jhoanna','jhoanna@gmail.com','$2y$12$lOdsWsi9hoO.MtN58QSiJ.Cko19KINLNf/GQxSiqF2Wp1XyT2YSGa',NULL,'2024-12-20 23:37:29','2024-12-20 23:37:29'),(105,'nino','nino@gmail.com','$2y$12$aoTNfq/7By40gmOQUhkyYu/TVWIkVnDZT.BYchCiaVKY4N5UDbtie',NULL,'2024-12-21 01:35:19','2024-12-21 01:35:19'),(106,'antonino balinado jr','antoninobalinado756@gmail.com','$2y$12$xN8ER9mJpMmrC9nl9uRfG.gLq4EpYpSjdFT074LGQ9hLqCEaYvfqK',NULL,'2024-12-27 20:23:29','2024-12-27 20:23:29');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-28 17:37:25
