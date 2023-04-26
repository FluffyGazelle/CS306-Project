

use death_database;




-- env_factor_view: Displays health-related environmental factors per country, including unsafe water sources, unsafe sanitation, and lack of handwashing facilities.
CREATE VIEW env_factor_view AS
SELECT c.iso_code, c.countries_name, ef.unsafe_water, ef.unsafe_sanitation, ef.hand_washing
FROM countries c
JOIN env_factor ef ON c.iso_code = ef.iso_code;


-- child_mortality_diet_view: Shows child mortality indicators and dietary factors for each country, such as child wasting, breastfeeding rates, and consumption of different food groups.
CREATE VIEW child_mortality_diet_view AS
SELECT cm.iso_code, c.countries_name, cm.child_wasting, cm.non_bfeeding, cm.low_birth_weight, cm.d_bfeeding, d.high_sodium, d.low_fruits, d.low_nuts_seeds, d.low_whole_grain, d.low_vegetables
FROM countries c
JOIN child_mortality cm ON c.iso_code = cm.iso_code
JOIN diet d ON c.iso_code = d.iso_code;

-- addiction_air_pol_view: Combines addiction behaviors, like smoking, drug use, and alcohol consumption, with air pollution levels for each country.
CREATE VIEW addiction_air_pol_view AS
SELECT a.iso_code, c.countries_name, a.smoke, a.drug_use, a.alcohol, ap.indoor, ap.outdoor
FROM countries c
JOIN addiction a ON c.iso_code = a.iso_code
JOIN air_pol ap ON c.iso_code = ap.iso_code;

-- diet_env_view: Presents dietary factors and environmental health risks for every country.
CREATE VIEW diet_env_view AS
SELECT d.iso_code, c.countries_name, d.high_sodium, d.low_fruits, d.low_nuts_seeds, d.low_whole_grain, d.low_vegetables, ef.unsafe_water, ef.unsafe_sanitation, ef.hand_washing, ef.air_pollution
FROM countries c
JOIN diet d ON c.iso_code = d.iso_code
JOIN env_factor ef ON c.iso_code = ef.iso_code;



-- addiction_env_child_mortality_view: Merges addiction behaviors, environmental health risks, and child mortality indicators for each country.
CREATE VIEW addiction_env_child_mortality_view AS
SELECT a.iso_code, c.countries_name, a.smoke, a.drug_use, a.alcohol, ef.unsafe_water, ef.unsafe_sanitation, ef.hand_washing, ef.air_pollution, cm.child_wasting, cm.non_bfeeding, cm.low_birth_weight, cm.d_bfeeding
FROM countries c
JOIN addiction a ON c.iso_code = a.iso_code
JOIN env_factor ef ON c.iso_code = ef.iso_code
JOIN child_mortality cm ON c.iso_code = cm.iso_code;



-- This query returns countries with more than 50,000 people exposed to unsafe water and either less than 3,000 people exposed to indoor air pollution or more than 12,000 people exposed to outdoor air pollution.
SELECT countries_name
FROM env_factor_view
WHERE unsafe_water > 50000
INTERSECT
SELECT countries_name
FROM air_pol_view
WHERE indoor < 3000 OR outdoor > 12000;

-- This query finds countries with high sodium intake but without child wasting.
SELECT c.countries_name
FROM countries c
JOIN diet d ON c.iso_code = d.iso_code
JOIN child_mortality cm ON c.iso_code = cm.iso_code
WHERE d.high_sodium = 1
EXCEPT
SELECT c.countries_name
FROM countries c
JOIN child_mortality cm ON c.iso_code = cm.iso_code
WHERE cm.child_wasting = 1;


-- This query also retrieves countries with high sodium intake but without child wasting, using LEFT JOINs.
SELECT c.countries_name
FROM countries c
LEFT JOIN diet d ON c.iso_code = d.iso_code AND d.high_sodium = 1
LEFT JOIN child_mortality cm ON c.iso_code = cm.iso_code AND cm.child_wasting = 1
WHERE d.high_sodium IS NOT NULL AND cm.child_wasting IS NULL;

-- This query selects all records from the child_mortality table where the iso_code is present in the diet table with high_sodium greater than 50,000.
SELECT *
FROM child_mortality cm
WHERE cm.iso_code IN (
    SELECT iso_code
    FROM diet
    WHERE high_sodium > 50000 
); 

-- This query selects all records from the child_mortality table where the iso_code is present in the diet table with high_sodium equal to 1.
SELECT *
FROM child_mortality cm
WHERE cm.iso_code IN (
    SELECT iso_code
    FROM diet
    WHERE high_sodium = 1
); 

-- This query retrieves the iso_code and countries_name from the countries table where the iso_code is present in the child_mortality_diet_view with high_sodium equal to 1.
SELECT c.iso_code, c.countries_name
FROM countries c
WHERE c.iso_code IN (
    SELECT cmdv.iso_code
    FROM child_mortality_diet_view cmdv
    WHERE cmdv.high_sodium = 1
);

-- This query fetches the iso_code and countries_name from the countries table where there exists a record in the child_mortality_diet_view with iso_code equal to the countries.iso_code and high_sodium equal to 1.
SELECT c.iso_code, c.countries_name
FROM countries c
WHERE EXISTS (
    SELECT 1
    FROM child_mortality_diet_view cmdv
    WHERE cmdv.iso_code = c.iso_code AND cmdv.high_sodium = 1
);



-- This query returns countries with high sodium intake and more than 50 people exposed to unsafe water, and the number of such countries.
SELECT cmdv.countries_name, COUNT(*) AS countries_with_high_sodium_and_unsafe_water
FROM child_mortality_diet_view cmdv
JOIN env_factor_view efv ON cmdv.iso_code = efv.iso_code
WHERE cmdv.high_sodium = 1 AND efv.unsafe_water > 50
GROUP BY cmdv.countries_name
HAVING countries_with_high_sodium_and_unsafe_water > 0;

-- This query calculates the average smoking rate and child wasting rate for each country and returns countries where the average smoking rate is above 20 and the average child wasting rate is above 5.
SELECT aapv.countries_name, AVG(aapv.smoke) AS avg_smoke, AVG(cmdv.child_wasting) AS avg_child_wasting
FROM addiction_air_pol_view aapv
JOIN child_mortality_diet_view cmdv ON aapv.iso_code = cmdv.iso_code
GROUP BY aapv.countries_name
HAVING avg_smoke > 20 AND avg_child_wasting > 5;

-- This query retrieves the countries with a sum of indoor air pollution exposure above 100 and a sum of alcohol consumption above 50.
SELECT apv.countries_name, SUM(apv.indoor) AS sum_indoor, SUM(aapv.alcohol) AS sum_alcohol
FROM air_pol_view apv
JOIN addiction_air_pol_view aapv ON apv.iso_code = aapv.iso_code
GROUP BY apv.countries_name
HAVING sum_indoor > 100 AND sum_alcohol > 50;

-- This query finds countries with the lowest unsafe sanitation levels below 30 and the lowest outdoor air pollution levels below 40.
SELECT efv.countries_name, MIN(efv.unsafe_sanitation) AS min_unsafe_sanitation, MIN(apv.outdoor) AS min_outdoor_pollution
FROM env_factor_view efv
JOIN air_pol_view apv ON efv.iso_code = apv.iso_code
GROUP BY efv.countries_name
HAVING min_unsafe_sanitation < 30 AND min_outdoor_pollution < 40;

-- This query displays countries with the highest percentage of low vegetable intake and highest percentage of low birth weight, both exceeding specified values 0 and 5 accordingly.
SELECT dev.countries_name, MAX(dev.low_vegetables) AS max_low_vegetables, MAX(cmdv.low_birth_weight) AS max_low_birth_weight
FROM diet_env_view d
JOIN child_mortality_diet_view cmdv ON dev.iso_code = cmdv.iso_code
GROUP BY dev.countries_name
HAVING max_low_vegetables > 0 AND max_low_birth_weight > 5;




ALTER TABLE addiction
-- ck_smoke_range checks that smoke values are between 0 and 1,700,000,
ADD CONSTRAINT ck_smoke_range CHECK (smoke >= 0 AND smoke <= 1700000),

-- ck_drug_use_range checks that drug_use values are between 0 and 100,000,
ADD CONSTRAINT ck_drug_use_range CHECK (drug_use >= 0 AND drug_use <= 100000),

-- ck_alcohol_range checks that alcohol values are between 0 and 400,000.
ADD CONSTRAINT ck_alcohol_range CHECK (alcohol >= 0 AND alcohol <= 400000);

select MAX(smoke) from addiction;
select MAX(drug_use) from addiction;
select MAX(alcohol) from addiction;


/*
Before inserting or updating entries in the addiction table, this code block sets two triggers (addiction_before_insert and addiction_before_update) that check that 
the values for smoking, using drugs, and drinking alcohol are within the acceptable range of 0 to 100.
*/
DELIMITER $$


CREATE TRIGGER addiction_before_insert
BEFORE INSERT ON addiction
FOR EACH ROW
BEGIN
  IF NEW.smoke < 0 THEN
    SET NEW.smoke = 0;
  ELSEIF NEW.smoke > 100 THEN
    SET NEW.smoke = 100;
  END IF;

  IF NEW.drug_use < 0 THEN
    SET NEW.drug_use = 0;
  ELSEIF NEW.drug_use > 100 THEN
    SET NEW.drug_use = 100;
  END IF;

  IF NEW.alcohol < 0 THEN
    SET NEW.alcohol = 0;
  ELSEIF NEW.alcohol > 100 THEN
    SET NEW.alcohol = 100;
  END IF;
END$$

-- Create the BEFORE UPDATE trigger
CREATE TRIGGER addiction_before_update
BEFORE UPDATE ON addiction
FOR EACH ROW
BEGIN
  IF NEW.smoke < 0 THEN
    SET NEW.smoke = 0;
  ELSEIF NEW.smoke > 100 THEN
    SET NEW.smoke = 100;
  END IF;

  IF NEW.drug_use < 0 THEN
    SET NEW.drug_use = 0;
  ELSEIF NEW.drug_use > 100 THEN
    SET NEW.drug_use = 100;
  END IF;

  IF NEW.alcohol < 0 THEN
    SET NEW.alcohol = 0;
  ELSEIF NEW.alcohol > 100 THEN
    SET NEW.alcohol = 100;
  END IF;
END$$

-- Reset the delimiter
DELIMITER ;


-- Trying to insert invalid values and getting error logs.
INSERT INTO countries (iso_code, countries_name, year)
VALUES ('XX', 'Test Country', 2023);

INSERT INTO addiction (smoke, drug_use, alcohol, iso_code)
VALUES (-10, 110, 50, 'XX');

select * from addiction where iso_code = 'XX';



/*
Defined a stored procedure called country_health_data that takes an iso_code as input and 
returns different health-related data depending on the input addiction data for Japan (JPN), diet data for Italy (ITA), or air pollution data for any other country.

*/


DELIMITER $$

CREATE PROCEDURE country_health_data (IN p_iso_code VARCHAR(5))
BEGIN
  IF p_iso_code = 'JPN' THEN
    SELECT
      a.iso_code,
      a.smoke,
      a.drug_use,
      a.alcohol
    FROM
      addiction a
    WHERE
      a.iso_code = p_iso_code;
  ELSEIF p_iso_code = 'ITA' THEN
    SELECT
      d.iso_code,
      d.high_sodium,
      d.low_fruits,
      d.low_nuts_seeds,
      d.low_whole_grain,
      d.low_vegetables
    FROM
      Diet d
    WHERE
      d.iso_code = p_iso_code;
  ELSE
    SELECT
      ap.iso_code,
      ap.indoor,
      ap.outdoor
    FROM
      air_pol ap
    WHERE
      ap.iso_code = p_iso_code;
  END IF;
END$$

DELIMITER ;



CALL country_health_data('JPN');
CALL country_health_data('ITA');
CALL country_health_data('TUR')





