USE depi_final_project_2;

-- 1️⃣ Base metrics per country-year
DROP VIEW IF EXISTS base_metrics_per_country_year;
CREATE VIEW base_metrics_per_country_year AS
SELECT 
    c.country_id,
    h.Year,
    AVG(h.Prevalence) AS prevalence,
    AVG(h.Mortality) AS mortality,
    AVG(h.`Recovery Rate (%)`) AS recovery_rate,
    AVG(h.`Healthcare Access (%)`) AS healthcare_access,
    AVG(h.`Doctors per 1000`) AS doctors_per_1000,
    AVG(h.`Hospital Beds per 1000`) AS beds_per_1000,
    AVG(h.`Urbanization Rate (%)`) AS urbanization_rate,
    AVG(a.AQI) AS avg_aqi,
    AVG(a.`PM2.5 (Âµg/mÂ³)`) AS avg_pm25,
    AVG(f.Fat) AS avg_fat,
    AVG(f.Carbs) AS avg_carbs,
    AVG(f.Protein) AS avg_protein,
    AVG(f.total_calories) AS avg_calories
FROM tbl_country c
LEFT JOIN tbl_health h ON c.country_id = h.country_id
LEFT JOIN tbl_air_quality a ON c.country_id = a.country_id AND a.Year = h.Year
LEFT JOIN tbl_food_consumption f ON c.country_id = f.country_id AND f.Year = h.Year
GROUP BY c.country_id, h.Year;

--------------------------------------------------------------------------------

-- 2️⃣ Normalized metrics (optimized)
DROP VIEW IF EXISTS normalized_metrics;
CREATE VIEW normalized_metrics AS
WITH stats AS (
    SELECT
        MIN(avg_aqi) AS min_aqi, MAX(avg_aqi) AS max_aqi,
        MIN(avg_pm25) AS min_pm25, MAX(avg_pm25) AS max_pm25,
        MIN(avg_fat) AS min_fat, MAX(avg_fat) AS max_fat,
        MIN(avg_calories) AS min_calories, MAX(avg_calories) AS max_calories,
        MIN(prevalence) AS min_prev, MAX(prevalence) AS max_prev,
        MIN(mortality) AS min_mort, MAX(mortality) AS max_mort,
        MIN(recovery_rate) AS min_recovery, MAX(recovery_rate) AS max_recovery,
        MIN(healthcare_access) AS min_healthcare, MAX(healthcare_access) AS max_healthcare,
        MIN(doctors_per_1000) AS min_doctors, MAX(doctors_per_1000) AS max_doctors,
        MIN(beds_per_1000) AS min_beds, MAX(beds_per_1000) AS max_beds,
        MIN(urbanization_rate) AS min_urban, MAX(urbanization_rate) AS max_urban
    FROM base_metrics_per_country_year
)
SELECT
    b.country_id,
    b.Year,
    (b.avg_aqi - s.min_aqi) / NULLIF(s.max_aqi - s.min_aqi,0) AS norm_aqi,
    (b.avg_pm25 - s.min_pm25) / NULLIF(s.max_pm25 - s.min_pm25,0) AS norm_pm25,
    (b.avg_fat - s.min_fat) / NULLIF(s.max_fat - s.min_fat,0) AS norm_fat,
    (b.avg_calories - s.min_calories) / NULLIF(s.max_calories - s.min_calories,0) AS norm_calories,
    (b.prevalence - s.min_prev) / NULLIF(s.max_prev - s.min_prev,0) AS norm_prevalence,
    (b.mortality - s.min_mort) / NULLIF(s.max_mort - s.min_mort,0) AS norm_mortality,
    (b.recovery_rate - s.min_recovery) / NULLIF(s.max_recovery - s.min_recovery,0) AS norm_recovery,
    (b.healthcare_access - s.min_healthcare) / NULLIF(s.max_healthcare - s.min_healthcare,0) AS norm_healthcare_access,
    (b.doctors_per_1000 - s.min_doctors) / NULLIF(s.max_doctors - s.min_doctors,0) AS norm_doctors,
    (b.beds_per_1000 - s.min_beds) / NULLIF(s.max_beds - s.min_beds,0) AS norm_beds,
    (b.urbanization_rate - s.min_urban) / NULLIF(s.max_urban - s.min_urban,0) AS norm_urbanization
FROM base_metrics_per_country_year b
CROSS JOIN stats s;


-- 3️⃣ Health Risk Composite Index (HRCI)
use depi_final_project_2;
CREATE OR REPLACE VIEW HRCI_view AS
SELECT
    country_id, Year,
    (norm_prevalence * 0.4) +
    (norm_mortality * 0.3) +
    (norm_aqi * 0.2) +
    (norm_fat * 0.1) AS HRCI
FROM normalized_metrics;



-- Healthy Lifestyle Score (HLS)
CREATE OR REPLACE VIEW HLS_view AS
SELECT
    country_id, Year,
    ((1 - norm_calories) * 0.3 +
     (1 - norm_urbanization) * 0.3 +
     (1 - norm_prevalence) * 0.4) AS HLS
FROM normalized_metrics;

--  Environmental-Health Burden Indicator (EHBI)
CREATE OR REPLACE VIEW EHBI_view AS
SELECT
    country_id, Year,
    (norm_aqi * 0.4) +
    (norm_prevalence * 0.3) +
    (norm_mortality * 0.3) AS EHBI
FROM normalized_metrics;


-- Food → Health Impact Score (FHIS)
CREATE OR REPLACE VIEW FHIS_view AS
SELECT
    country_id, Year,
    (norm_fat * 0.3) +
    (norm_calories * 0.3) +
    (norm_prevalence * 0.3) +
    ((1 - norm_recovery) * 0.1) AS FHIS
FROM normalized_metrics;


-- Resource Utilization Score (RUS)
CREATE OR REPLACE VIEW RUS_view AS
SELECT
    country_id, Year,
    ((norm_doctors * 0.25) +
     (norm_beds * 0.2) +
     (norm_healthcare_access * 0.25) +
     ((1 - norm_mortality) * 0.15) +
     (norm_recovery * 0.15)) AS RUS
FROM normalized_metrics;


 -- Overall Country Wellness Index (OCWI)
 SELECT
    h.country_id,
    h.Year,
    h.HRCI,
    l.HLS,
    e.EHBI,
    f.FHIS,
    r.RUS,
    ((l.HLS * 0.25) +
     ((1 - h.HRCI) * 0.25) +
     ((1 - e.EHBI) * 0.15) +
     (r.RUS * 0.20) +
     ((1 - f.FHIS) * 0.15)) AS OCWI
FROM HRCI_view h
JOIN HLS_view l ON h.country_id = l.country_id AND h.Year = l.Year
JOIN EHBI_view e ON h.country_id = e.country_id AND h.Year = e.Year
JOIN FHIS_view f ON h.country_id = f.country_id AND h.Year = f.Year
JOIN RUS_view r ON h.country_id = r.country_id AND h.Year = r.Year;


-- يربط الحالة الصحية (Prevalence, Mortality) مع استهلاك الغذاء (food_value)
SELECT 
    c.Country,
    h.Year,
    h.Prevalence,
    h.Mortality,
    f.food_id AS Food_Consumption
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
JOIN tbl_food_consumption f ON h.country_id = f.country_id AND h.Year = f.Year;

-- يربط الصحة مع جودة الهواء (AQI, PM2.5)
SELECT 
    c.Country,
    h.Year,
    h.Mortality,
    h.Prevalence,
    a.AQI,
    a.`PM2.5 (Âµg/mÂ³)` AS PM25
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
JOIN tbl_air_quality a ON h.country_id = a.country_id AND h.Year = a.Year;

-- يركّز على كفاءة الموارد الصحية وتأثيرها على الوفيات
SELECT 
    c.Country,
    h.Year,
    h.`Doctors per 1000` AS Doctors,
    h.Mortality
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id;

-- يحلّل العلاقة بين معدل التمدّن وانتشار الأمراض
SELECT 
    c.Country,
    h.Year,
    h.`Urbanization Rate (%)` AS Urbanization,
    h.Prevalence,
    h.Incidence
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id;

 

SELECT 
    country_id, Year,
    (norm_prevalence * 0.4) +
    (norm_mortality * 0.3) +
    (norm_aqi * 0.2) +
    (norm_fat * 0.1) AS HRCI
FROM normalized_metrics
LIMIT 10;


SELECT * FROM HRCI_view;
SELECT * FROM HLS_view;
SELECT * FROM EHBI_view;
SELECT * FROM FHIS_view;
SELECT * FROM RUS_view;

-- ✅ Overall Country Wellness Index (OCWI) with NULLs replaced by 0
SELECT
    COALESCE(h.country_id, 0) AS country_id,
    COALESCE(h.Year, 0) AS Year,
    COALESCE(h.HRCI, 0) AS HRCI,
    COALESCE(l.HLS, 0) AS HLS,
    COALESCE(e.EHBI, 0) AS EHBI,
    COALESCE(f.FHIS, 0) AS FHIS,
    COALESCE(r.RUS, 0) AS RUS,
    (
        (COALESCE(l.HLS, 0) * 0.25) +
        ((1 - COALESCE(h.HRCI, 0)) * 0.25) +
        ((1 - COALESCE(e.EHBI, 0)) * 0.15) +
        (COALESCE(r.RUS, 0) * 0.20) +
        ((1 - COALESCE(f.FHIS, 0)) * 0.15)
    ) AS OCWI
FROM HRCI_view h
LEFT JOIN HLS_view l ON h.country_id = l.country_id AND h.Year = l.Year
LEFT JOIN EHBI_view e ON h.country_id = e.country_id AND h.Year = e.Year
LEFT JOIN FHIS_view f ON h.country_id = f.country_id AND h.Year = f.Year
LEFT JOIN RUS_view r ON h.country_id = r.country_id AND h.Year = r.Year;