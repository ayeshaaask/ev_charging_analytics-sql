create database ev_charging_analytics;
use ev_charging_analytics;

CREATE TABLE ev_charging_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(50),
  vehicle_model VARCHAR(100),
  battery_capacity_kwh DOUBLE,
  charging_station_id VARCHAR(50),
  charging_station_location VARCHAR(100),
  charging_start DATETIME,
  charging_end DATETIME,
  energy_consumed DOUBLE,
  charging_duration_hours DOUBLE,
  charging_rate_kw DOUBLE,
  charging_cost_usd DOUBLE,
  time_of_day VARCHAR(50),
  day_of_week VARCHAR(50),
  soc_start_pct DOUBLE,
  soc_end_pct DOUBLE,
  distance_km DOUBLE,
  temperature_c DOUBLE,
  vehicle_age_years INT,
  charger_type VARCHAR(50),
  user_type VARCHAR(50)
);

select * from ev_charging_sessions;

SELECT COUNT(*) FROM ev_charging_sessions;

-- PART A — DDL
-- Add charging_efficiency_pct column
ALTER TABLE ev_charging_sessions
ADD COLUMN charging_efficiency_pct INT;

-- Modify charging_cost_usd precision
ALTER TABLE ev_charging_sessions
MODIFY COLUMN charging_cost_usd DECIMAL(10, 4);

-- Drop temperature_c
ALTER TABLE ev_charging_sessions
DROP COLUMN temperature_c;

-- PART B — DML
--  Update charging_efficiency_pct
UPDATE ev_charging_sessions
SET charging_efficiency_pct = (energy_consumed / battery_capacity_kwh) * 100;

-- 8. Increase charging_cost_usd by 5% for New York
UPDATE ev_charging_sessions
SET charging_cost_usd = charging_cost_usd * 1.05
WHERE charging_station_location = 'New York';

-- 9. Delete records where energy_consumed < 5
DELETE FROM ev_charging_sessions
WHERE energy_consumed < 5;

INSERT INTO ev_charging_sessions 
(user_id, vehicle_model, battery_capacity_kwh, charging_station_id, 
charging_station_location, charging_start, charging_end, energy_consumed, 
charging_duration_hours, charging_rate_kw, charging_cost_usd, time_of_day, 
day_of_week, soc_start_pct, soc_end_pct, distance_km, vehicle_age_years, 
charger_type, user_type)
VALUES 
('User_999', 'Tesla Model 3', 75.0, 'Station_001', 
'Mumbai', '2024-03-01 10:00:00', '2024-03-01 12:00:00', 50.0, 
2.0, 25.0, 15.00, 'Morning', 
'Monday', 20.0, 80.0, 150.0, 3, 
'Level 2', 'Commuter');

-- Part C — DQL
-- Sessions where charging_rate_kw > 40
SELECT * FROM ev_charging_sessions
WHERE charging_rate_kw > 40;

-- Top 5 most expensive sessions
SELECT *,
       RANK() OVER (ORDER BY charging_cost_usd DESC) AS cost_rank
FROM ev_charging_sessions
ORDER BY cost_rank
LIMIT 5;

-- Distinct vehicle models and counts
SELECT vehicle_model, COUNT(*) AS total_sessions
FROM ev_charging_sessions
GROUP BY vehicle_model
ORDER BY total_sessions DESC;

-- Average charging cost per location
SELECT charging_station_location, 
       ROUND(AVG(charging_cost_usd), 2) AS avg_cost
FROM ev_charging_sessions
GROUP BY charging_station_location
ORDER BY avg_cost DESC;

-- Sessions on weekends
SELECT * FROM ev_charging_sessions
WHERE day_of_week IN ('Saturday', 'Sunday');

-- Sessions where soc_end_pct - soc_start_pct > 40
SELECT * FROM ev_charging_sessions
WHERE (soc_end_pct - soc_start_pct) > 40;

--  Average energy and duration per charger_type
SELECT charger_type,
       ROUND(AVG(energy_consumed), 2) AS avg_energy_kwh,
       ROUND(AVG(charging_duration_hours), 2) AS avg_duration_hrs
FROM ev_charging_sessions
GROUP BY charger_type;

--  Sessions with vehicle_age_years > 5 and user_type = 'Commuter'
SELECT * FROM ev_charging_sessions
WHERE vehicle_age_years > 5
AND user_type = 'Commuter';

-- Categorize sessions as Low / Medium / High Energy
SELECT *,
  CASE 
    WHEN energy_consumed < 20 THEN 'Low Energy'
    WHEN energy_consumed BETWEEN 20 AND 50 THEN 'Medium Energy'
    ELSE 'High Energy'
  END AS energy_category
FROM ev_charging_sessions;














