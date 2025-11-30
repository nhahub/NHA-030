use depi_final_project_2;
--  Average Total Calories per Country
SELECT 
    c.Country AS country_name,
    AVG(f.total_calories) AS avg_calories
FROM tbl_food_consumption f
JOIN tbl_country c ON f.country_id = c.country_id
GROUP BY c.Country
ORDER BY avg_calories DESC;

-- Fat / Protein / Carbs Percentage per Country
SELECT 
    c.Country AS country_name,
    ROUND(AVG(f.Fat), 2) AS avg_fat,
    ROUND(AVG(f.Protein), 2) AS avg_protein,
    ROUND(AVG(f.Carbs), 2) AS avg_carbs,
    ROUND(AVG(f.Fat) / (AVG(f.Fat) + AVG(f.Protein) + AVG(f.Carbs)) * 100, 2) AS fat_percentage,
    ROUND(AVG(f.Protein) / (AVG(f.Fat) + AVG(f.Protein) + AVG(f.Carbs)) * 100, 2) AS protein_percentage,
    ROUND(AVG(f.Carbs) / (AVG(f.Fat) + AVG(f.Protein) + AVG(f.Carbs)) * 100, 2) AS carbs_percentage
FROM tbl_food_consumption f
JOIN tbl_country c ON f.country_id = c.country_id
GROUP BY c.Country;

-- Correlation Between Fat Intake and Disease Prevalence

SELECT 
    c.Country AS country_name,
    f.Year,
    ROUND(AVG(f.Fat), 2) AS avg_fat,
    ROUND(AVG(h.Prevalence), 2) AS avg_prevalence
FROM tbl_food_consumption f
JOIN tbl_health h 
    ON f.country_id = h.country_id AND f.Year = h.Year
JOIN tbl_country c 
    ON f.country_id = c.country_id
GROUP BY c.Country, f.Year
ORDER BY c.Country, f.Year;

-- Top 5 Most Consumed Foods per Country
SELECT 
    c.Country,
    fd.food_name,
    AVG(f.total_calories) AS avg_calories
FROM tbl_food_consumption f
JOIN tbl_food fd ON f.food_id = fd.food_id
JOIN tbl_country c ON f.country_id = c.country_id
GROUP BY c.Country, fd.food_name
ORDER BY c.Country, avg_calories DESC;

-- Calories vs Urbanization Rate
SELECT 
    c.Country,
    f.Year,
    AVG(f.total_calories) AS avg_calories,
    Round(AVG(h.`Urbanization Rate (%)`), 2) AS urbanization_rate
FROM tbl_food_consumption f
JOIN tbl_health h 
    ON f.country_id = h.country_id AND f.Year = h.Year
JOIN tbl_country c 
    ON f.country_id = c.country_id
GROUP BY c.Country, f.Year
ORDER BY c.Country, f.Year;

-- Balanced Diet Indicator (Fat/Protein/Carbs Ideal Range)
SELECT 
    c.Country,
    ROUND(AVG(f.Fat), 2) AS avg_fat,
    ROUND(AVG(f.Protein), 2) AS avg_protein,
    ROUND(AVG(f.Carbs), 2) AS avg_carbs,
    CASE 
        WHEN AVG(f.Fat) BETWEEN 20 AND 35
         AND AVG(f.Carbs) BETWEEN 45 AND 65
         AND AVG(f.Protein) BETWEEN 10 AND 35
        THEN 'Balanced'
        ELSE 'Unbalanced'
    END AS diet_status
FROM tbl_food_consumption f
JOIN tbl_country c ON f.country_id = c.country_id
GROUP BY c.Country;




