use depi_final_project_2;

-- Calculates the average Air Quality Index (AQI) for each country by year and orders the results by year.
SELECT 
    c.Country,
    a.Year,
    AVG(a.AQI) AS avg_AQI
FROM tbl_air_quality a
JOIN tbl_country c ON a.country_id = c.country_id
GROUP BY c.Country, a.Year
ORDER BY a.Year;

-- Retrieves the average Air Quality Index (AQI) for each country specifically for the year 2023.

SELECT 
    c.Country,
    a.Year,
    AVG(a.AQI) AS avg_AQI_2023
FROM tbl_air_quality a
JOIN tbl_country c ON a.country_id = c.country_id
WHERE a.Year = 2023
GROUP BY c.Country, a.Year;

-- Retrieves the average Air Quality Index (AQI) for each country specifically for the year 2024.
SELECT 
    c.Country,
    a.Year,
    AVG(a.AQI) AS avg_AQI_2024
FROM tbl_air_quality a
JOIN tbl_country c ON a.country_id = c.country_id
WHERE a.Year = 2024
GROUP BY c.Country, a.Year;


-- Shows yearly average pollutant levels per country, rounded to two decimals.

SELECT 
    c.Country,
    a.Year,
    ROUND(AVG(a.`PM2.5 (Âµg/mÂ³)`), 2) AS avg_PM25,
    ROUND(AVG(a.`NO2 (ppb)`), 2) AS avg_NO2,
    ROUND(AVG(a.`SO2 (ppb)`), 2) AS avg_SO2,
    ROUND(AVG(a.`CO (ppm)`), 2) AS avg_CO,
    ROUND(AVG(a.`O3 (ppb)`), 2) AS avg_O3
FROM tbl_air_quality a
JOIN tbl_country c ON a.country_id = c.country_id
GROUP BY c.Country, a.Year
ORDER BY a.Year, c.Country;


-- Percentage Change in AQI (YoY)
SELECT 
    c.Country,
    ROUND(
        (AVG(CASE WHEN a.Year = 2024 THEN a.AQI END) -
         AVG(CASE WHEN a.Year = 2023 THEN a.AQI END))
        / AVG(CASE WHEN a.Year = 2023 THEN a.AQI END) * 100, 2
    ) AS AQI_change_percent
FROM tbl_air_quality a
JOIN tbl_country c ON a.country_id = c.country_id
WHERE a.Year IN (2023, 2024)
GROUP BY c.Country
HAVING COUNT(DISTINCT a.Year) = 2;


-- Dominant Pollutant Contribution
SELECT 
    c.Country,
    CASE 
        WHEN AVG(a.`PM2.5 (Âµg/mÂ³)`) >= GREATEST(
                AVG(a.`PM10 (Âµg/mÂ³)`), 
                AVG(a.`NO2 (ppb)`), 
                AVG(a.`SO2 (ppb)`), 
                AVG(a.`CO (ppm)`), 
                AVG(a.`O3 (ppb)`)
            ) THEN 'PM2.5'
        WHEN AVG(a.`PM10 (Âµg/mÂ³)`) >= GREATEST(
                AVG(a.`NO2 (ppb)`), 
                AVG(a.`SO2 (ppb)`), 
                AVG(a.`CO (ppm)`), 
                AVG(a.`O3 (ppb)`)
            ) THEN 'PM10'
        WHEN AVG(a.`NO2 (ppb)`) >= GREATEST(
                AVG(a.`SO2 (ppb)`), 
                AVG(a.`CO (ppm)`), 
                AVG(a.`O3 (ppb)`)
            ) THEN 'NO2'
        WHEN AVG(a.`SO2 (ppb)`) >= GREATEST(
                AVG(a.`CO (ppm)`), 
                AVG(a.`O3 (ppb)`)
            ) THEN 'SO2'
        WHEN AVG(a.`CO (ppm)`) >= AVG(a.`O3 (ppb)`) THEN 'CO'
        ELSE 'O3'
    END AS dominant_pollutant
FROM tbl_air_quality a
JOIN tbl_country c ON a.country_id = c.country_id
GROUP BY c.Country;





-- TOP 5 Countries with avg_aqi
WITH country_avg AS (
  SELECT 
    aq.country_id,
    c.Country,
    AVG(aq.AQI) AS avg_country_aqi
  FROM tbl_air_quality aq
  JOIN tbl_country c ON aq.country_id = c.country_id
  WHERE aq.Year IN (2023, 2024)
  GROUP BY aq.country_id, c.Country
),

-- اختيار أعلى 5 دول من حيث متوسط الـ AQI
top5 AS (
  SELECT *
  FROM country_avg
  ORDER BY avg_country_aqi DESC
  LIMIT 5
),

-- حساب متوسط AQI لكل مدينة في نفس السنين
city_avg AS (
  SELECT 
    aq.country_id,
    aq.City,
    AVG(aq.AQI) AS avg_city_aqi
  FROM tbl_air_quality aq
  WHERE aq.Year IN (2023, 2024)
  GROUP BY aq.country_id, aq.City
),

-- ترتيب المدن داخل كل دولة
ranked AS (
  SELECT 
    t.Country,
    ca.City,
    ca.avg_city_aqi,
    ta.avg_country_aqi,
    ROW_NUMBER() OVER (PARTITION BY ca.country_id ORDER BY ca.avg_city_aqi DESC) AS city_rank
  FROM city_avg ca
  JOIN top5 ta ON ca.country_id = ta.country_id
  JOIN tbl_country t ON t.country_id = ca.country_id
)

-- عرض أعلى مدينة في كل دولة من أعلى 5 دول
SELECT 
  Country,
  City AS highest_polluting_city,
  ROUND(avg_city_aqi, 2) AS city_avg_aqi,
  ROUND(avg_country_aqi, 2) AS country_avg_aqi
FROM ranked
WHERE city_rank = 1
ORDER BY avg_country_aqi DESC;




































