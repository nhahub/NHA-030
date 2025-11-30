use depi_final_project_2;

SET SQL_SAFE_UPDATES = 0;

-- 1️⃣ تنظيف النصوص في العمود الوصفي
UPDATE tbl_food_consumption
SET 
    description = REPLACE(description, '(Estimated)', ''),
    description = REPLACE(description, '"', ''),
    description = TRIM(description);

-- 2️⃣ تنظيف الأعمدة الرقمية من أي رموز أو وحدات
UPDATE tbl_food_consumption
SET 
    total_calories = NULLIF(TRIM(REPLACE(REPLACE(REPLACE(total_calories, 'kcal', ''), '"', ''), ' ', '')), ''),
    Fat = NULLIF(TRIM(REPLACE(REPLACE(REPLACE(Fat, 'g', ''), '"', ''), ' ', '')), ''),
    Carbs = NULLIF(TRIM(REPLACE(REPLACE(REPLACE(Carbs, 'g', ''), '"', ''), ' ', '')), ''),
    Protein = NULLIF(TRIM(REPLACE(REPLACE(REPLACE(Protein, 'g', ''), '"', ''), ' ', '')), '');

-- 3️⃣ استبدال أي NULL بـ 0
UPDATE tbl_food_consumption
SET 
    total_calories = IFNULL(total_calories, 0),
    Fat = IFNULL(Fat, 0),
    Carbs = IFNULL(Carbs, 0),
    Protein = IFNULL(Protein, 0);
    
    
-- حذف ال outliers
DELETE FROM tbl_food_consumption
WHERE total_calories < 0 OR total_calories > 10000
   OR Fat < 0 OR Fat > 1000
   OR Carbs < 0 OR Carbs > 1000
   OR Protein < 0 OR Protein > 1000;

SET SQL_SAFE_UPDATES = 1;
