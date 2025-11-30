use depi_final_project_2;
--  معدل الانتشار لكل دولة
SELECT c.Country,round(AVG(h.Prevalence),2)  AS avg_prevalence
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country;


-- معدل الوفيات لكل دولة
SELECT c.Country, Round(AVG(h.Mortality),2)AS avg_mortality
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country;

-- متوسط نسبة الشفاء من الامراض لكل دولة 
SELECT c.Country, Round(AVG(h.`Recovery Rate (%)`),2) AS avg_recovery
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country;

-- مدى وصول المواطنين لخدمات العلاج
SELECT c.Country,Round( AVG(h.`Healthcare Access (%)`),2) AS avg_access
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country;

-- يقيس مدى كفاءة النظام في العلاج مقابل المرض
SELECT c.Country,
    Round(   AVG(h.`Recovery Rate (%)` / (h.Mortality + h.Incidence)),2) AS efficiency_index
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country;

-- لعلاقة بين عدد الاطباء و معدل الوفيات 
SELECT c.Country,
       Round(AVG(h.`Doctors per 1000`),2) AS avg_doctors,
       Round(AVG(h.Mortality),2) AS avg_mortality,
       Round((AVG(h.`Doctors per 1000`) / AVG(h.Mortality)),2) AS doctor_mortality_ratio
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country;

-- تقارن توفر المستشفيات مع معدلات الوفيات
SELECT c.Country,
       Round(AVG(h.`Hospital Beds per 1000`),2) AS avg_beds,
       Round(AVG(h.Mortality),2) AS avg_mortality,
       Round((AVG(h.`Hospital Beds per 1000`) / AVG(h.Mortality)),2) AS bed_mortality_ratio
FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country;

-- الفرق بين السنتين في prevelence , Mortality , Recovery
SELECT 
    c.Country,
    ROUND(
        AVG(CASE WHEN h.Year = 2024 THEN h.Mortality END) -
        AVG(CASE WHEN h.Year = 2023 THEN h.Mortality END), 2
    ) AS mortality_change,

    ROUND(
        AVG(CASE WHEN h.Year = 2024 THEN h.Prevalence END) -
        AVG(CASE WHEN h.Year = 2023 THEN h.Prevalence END), 2
    ) AS prevalence_change,

    ROUND(
        AVG(CASE WHEN h.Year = 2024 THEN h.`Recovery Rate (%)` END) -
        AVG(CASE WHEN h.Year = 2023 THEN h.`Recovery Rate (%)` END), 2
    ) AS recovery_change

FROM tbl_health h
JOIN tbl_country c ON h.country_id = c.country_id
GROUP BY c.Country
HAVING 
    COUNT(CASE WHEN h.Year = 2023 THEN 1 END) > 0
    AND
    COUNT(CASE WHEN h.Year = 2024 THEN 1 END) > 0;
