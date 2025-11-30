-- ======================================================
-- 🧭 1. استخدام قاعدة البيانات
-- ======================================================
USE depi_final_project_2;

SET SQL_SAFE_UPDATES = 0;

SET FOREIGN_KEY_CHECKS = 0;

-- ======================================================
-- 1️⃣ حذف الأمراض الفارغة أو NULL
-- ======================================================
DELETE FROM tbl_disease 
WHERE Disease = '' OR Disease IS NULL;

-- ======================================================
-- 2️⃣ حذف القيم NULL في الجداول المختلفة
-- ======================================================
DELETE FROM tbl_health
WHERE country_id IS NULL 
   OR disease_id IS NULL;

UPDATE tbl_health
SET Prevalence = 0
WHERE Prevalence IS NULL ;

UPDATE tbl_health
SET Mortality = 0
WHERE Mortality IS NULL ;

UPDATE tbl_health
SET `Doctors per 1000` = 0
WHERE `Doctors per 1000` IS NULL ;

UPDATE tbl_health
SET `Hospital Beds per 1000` = 0
WHERE `Hospital Beds per 1000` IS NULL;

UPDATE tbl_health
SET `Healthcare Access (%)` = 0
WHERE `Healthcare Access (%)` IS NULL  ;

UPDATE tbl_health
SET `Recovery Rate (%)` = 0
WHERE `Recovery Rate (%)` IS NULL ;


DELETE FROM tbl_food_consumption
WHERE country_id IS NULL OR food_id IS NULL;


-- ======================================================
-- 3️⃣ تنظيف القيم الغريبة (Outliers)
-- ======================================================
DELETE FROM tbl_air_quality
WHERE AQI < 0 OR AQI > 500
   OR `PM2.5 (Âµg/mÂ³)` < 0 OR `PM2.5 (Âµg/mÂ³)` > 500
   OR `PM10 (Âµg/mÂ³)` < 0 OR `PM10 (Âµg/mÂ³)` > 600
   OR `NO2 (ppb)` < 0 OR `NO2 (ppb)` > 200
   OR `SO2 (ppb)` < 0 OR `SO2 (ppb)` > 150
   OR `CO (ppm)` < 0 OR `CO (ppm)` > 50
   OR `O3 (ppb)` < 0 OR `O3 (ppb)` > 300
   OR `Temperature (Â°C)` < -50 OR `Temperature (Â°C)` > 60
   OR `Humidity (%)` < 0 OR `Humidity (%)` > 100
   OR `Wind Speed (m/s)` < 0 OR `Wind Speed (m/s)` > 100;


DELETE FROM tbl_health
WHERE `Doctors per 1000` < 0 OR `Doctors per 1000` > 50
   OR `Hospital Beds per 1000` < 0 OR `Hospital Beds per 1000` > 100
   OR `Healthcare Access (%)` < 0 OR `Healthcare Access (%)` > 100
   OR `Recovery Rate (%)` < 0 OR `Recovery Rate (%)` > 100;

DELETE FROM tbl_health WHERE Prevalence < 0 OR Mortality < 0 OR Prevalence > 100 OR Mortality > 100;

-- ======================================================
-- 4️⃣ إزالة الصفوف غير المرتبطة بين الجداول
-- ======================================================
DELETE FROM tbl_health 
WHERE country_id NOT IN (SELECT country_id FROM tbl_country)
   OR disease_id NOT IN (SELECT disease_id FROM tbl_disease);

DELETE FROM tbl_food_consumption
WHERE country_id NOT IN (SELECT country_id FROM tbl_country)
   OR food_id NOT IN (SELECT food_id FROM tbl_food);

DELETE FROM tbl_air_quality
WHERE country_id NOT IN (SELECT country_id FROM tbl_country);

-- ======================================================
-- 5️⃣ توحيد النصوص (تنظيف المسافات وتوحيد الحالة)
-- ======================================================
UPDATE tbl_country 
SET Country = TRIM(UPPER(Country));

UPDATE tbl_disease 
SET Disease = TRIM(UPPER(Disease));

UPDATE tbl_food 
SET food_name = TRIM(UPPER(food_name));

-- ======================================================
-- 6️⃣ تحويل التاريخ في جودة الهواء إلى صيغة صحيحة
-- ======================================================
-- 1. استبدال القيم الفارغة بمؤقت NULL
UPDATE tbl_air_quality
SET Date = NULL
WHERE TRIM(Date) = '';

-- 2. تحويل القيم بصيغة dd/mm/yyyy
UPDATE tbl_air_quality
SET Date = STR_TO_DATE(Date, '%d/%m/%Y')
WHERE Date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';

-- 3. تحويل القيم بصيغة yyyy-mm-dd (لو فيه أي نصوص محتاجة تحويل)
UPDATE tbl_air_quality
SET Date = CAST(Date AS DATE)
WHERE Date IS NOT NULL;

ALTER TABLE tbl_air_quality 
MODIFY COLUMN Date DATE;

-- ======================================================
-- 7️⃣ حذف التكرارات داخل الجداول (بطريقة آمنة)
-- ======================================================

-- الدول
CREATE TEMPORARY TABLE temp_country AS
SELECT MIN(country_id) AS keep_id
FROM tbl_country
GROUP BY Country;

DELETE FROM tbl_country
WHERE country_id NOT IN (SELECT keep_id FROM temp_country);
DROP TABLE temp_country;


-- الأطعمة
CREATE TEMPORARY TABLE temp_food AS
SELECT MIN(food_id) AS keep_id
FROM tbl_food
GROUP BY food_name;

DELETE FROM tbl_food
WHERE food_id NOT IN (SELECT keep_id FROM temp_food);
DROP TABLE temp_food;

-- الصحة
CREATE TEMPORARY TABLE temp_health AS
SELECT MIN(id) AS keep_id
FROM tbl_health
GROUP BY country_id, Year, disease_id;

DELETE FROM tbl_health
 WHERE id NOT IN (SELECT keep_id FROM temp_health);
 DROP TABLE temp_health;
 
 -- استهلاك الطعام
 CREATE TEMPORARY TABLE temp_food_con AS
SELECT MIN(id) AS keep_id
FROM tbl_food_consumption
GROUP BY country_id, Year, food_id;

DELETE FROM tbl_food_consumption 
WHERE id NOT IN (SELECT keep_id FROM temp_food_con);
DROP TABLE temp_food_con;

-- حذف الدول اللي  مش موجودة فى ال country
DELETE FROM tbl_food_consumption
WHERE country_id NOT IN (SELECT country_id FROM tbl_country);
   
DELETE FROM tbl_air_quality
WHERE country_id NOT IN (SELECT country_id FROM tbl_country);

DELETE FROM tbl_health
WHERE country_id NOT IN (SELECT country_id FROM tbl_country)
   OR disease_id NOT IN (SELECT disease_id FROM tbl_disease);
-- ======================================================
-- 8️⃣ إعادة تفعيل قيود العلاقاتغع
-- ======================================================
SET FOREIGN_KEY_CHECKS = 1;

-- ======================================================
-- 9️⃣ ملخص نهائي بعد التنظيف
-- ======================================================
SELECT 
  'tbl_country' AS TableName, COUNT(*) AS TotalRows FROM tbl_country
UNION ALL
SELECT 'tbl_disease', COUNT(*) FROM tbl_disease
UNION ALL
SELECT 'tbl_food', COUNT(*) FROM tbl_food
UNION ALL
SELECT 'tbl_health', COUNT(*) FROM tbl_health
UNION ALL
SELECT 'tbl_air_quality', COUNT(*) FROM tbl_air_quality
UNION ALL
SELECT 'tbl_food_consumption', COUNT(*) FROM tbl_food_consumption;
UNLOCK TABLES;


select * from tbl_health;