use depi_final_project_2;

ALTER TABLE tbl_food_consumption ADD COLUMN Fat DOUBLE DEFAULT 0;
ALTER TABLE tbl_food_consumption ADD COLUMN Carbs DOUBLE DEFAULT 0;
ALTER TABLE tbl_food_consumption ADD COLUMN Protein DOUBLE DEFAULT 0;
ALTER TABLE tbl_food_consumption ADD COLUMN total_calories DOUBLE DEFAULT 0;

SET SQL_SAFE_UPDATES = 0;

-- Extract total_calories, Fat, Carbs, and Protein from description_y
UPDATE tbl_food_consumption
SET 
    total_calories = CAST(
        SUBSTRING(
            description,
            LOCATE('Calories:', description) + 9,
            LOCATE('kcal', description) - (LOCATE('Calories:', description) + 9)
        ) AS DECIMAL(10,2)
    ),

    Fat = CAST(
        SUBSTRING(
            description,
            LOCATE('Fat:', description) + 4,
            LOCATE('g', description, LOCATE('Fat:', description)) - (LOCATE('Fat:', description) + 4)
        ) AS DECIMAL(10,2)
    ),

    Carbs = CAST(
        SUBSTRING(
            description,
            LOCATE('Carbs:', description) + 6,
            LOCATE('g', description, LOCATE('Carbs:', description)) - (LOCATE('Carbs:', description) + 6)
        ) AS DECIMAL(10,2)
    ),

    Protein = CAST(
        SUBSTRING(
            description,
            LOCATE('Protein:', description) + 8,
            LOCATE('g', description, LOCATE('Protein:', description)) - (LOCATE('Protein:', description) + 8)
        ) AS DECIMAL(10,2)
    )
WHERE description LIKE '%Calories:%'
  AND description LIKE '%Fat:%'
  AND description LIKE '%Carbs:%'
  AND description LIKE '%Protein:%';