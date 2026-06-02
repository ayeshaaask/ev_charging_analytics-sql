# ⚡ EV Charging Analytics — SQL Project

This project demonstrates how SQL can be used to analyze **Electric Vehicle (EV) charging session data** — exploring patterns in charging cost, energy consumption, battery efficiency, and user behavior.

> 💡 The dataset contains 1,320 real-world EV charging session records. All DDL, DML, and DQL tasks were performed using MySQL Workbench.

---

## 📌 Table of Contents
- <a href="#project-overview">🚗 Project Overview</a>
- <a href="#database-schema">🧱 Database Schema</a>
- <a href="#ddl">🧩 Part A — DDL (Data Definition Language)</a>
- <a href="#dml">✏️ Part B — DML (Data Manipulation Language)</a>
- <a href="#dql">📊 Part C — DQL (Data Query Language)</a>
- <a href="#tools">🧰 Tools & Technologies</a>
- <a href="#how-to-run">🏁 How to Run</a>
- <a href="#deliverables">🧾 Project Deliverables</a>
- <a href="#author--contact">👤 Author & Contact</a>

---

<h2><a class="anchor" id="project-overview"></a>🚗 Project Overview</h2>

With the rapid adoption of electric vehicles, understanding charging behavior is crucial for both **Charge Point Operators (CPOs)** and **mobility data analysts**.  
This project uses SQL to extract insights such as:
- Cost patterns across different locations
- Energy consumption and charging efficiency
- Trends by time of day and day of week
- Charger type utilization
- User behavior segmentation

---

<h2><a class="anchor" id="database-schema"></a>🧱 Database Schema</h2>

**Database:** `EV_Charging_Analytics`  
**Table:** `ev_charging_sessions`

| Column | Data Type | Description |
|--------|-----------|-------------|
| `id` | INT (PK) | Unique session ID (auto increment) |
| `user_id` | VARCHAR(50) | Unique identifier for each EV user |
| `vehicle_model` | VARCHAR(100) | Model name of the EV |
| `battery_capacity_kwh` | DOUBLE | Total battery capacity of the vehicle |
| `charging_station_id` | VARCHAR(50) | Station identifier |
| `charging_station_location` | VARCHAR(100) | City/location of the charging station |
| `charging_start` | DATETIME | Timestamp when charging began |
| `charging_end` | DATETIME | Timestamp when charging completed |
| `energy_consumed` | DOUBLE | Energy consumed during the session (kWh) |
| `charging_duration_hours` | DOUBLE | Duration of the session in hours |
| `charging_rate_kw` | DOUBLE | Charging rate / power output |
| `charging_cost_usd` | DECIMAL(10,4) | Cost of the charging session in USD |
| `charging_efficiency_pct` | DOUBLE | Efficiency = (energy_consumed / battery_capacity_kwh) * 100 |
| `time_of_day` | VARCHAR(50) | Part of day (Morning / Afternoon / Evening / Night) |
| `day_of_week` | VARCHAR(50) | Day on which the session occurred |
| `soc_start_pct` | DOUBLE | Battery state of charge before charging (%) |
| `soc_end_pct` | DOUBLE | Battery state of charge after charging (%) |
| `distance_km` | DOUBLE | Distance traveled before current session |
| `vehicle_age_years` | INT | Age of the vehicle in years |
| `charger_type` | VARCHAR(50) | Type of charger (Level 1 / Level 2 / DC Fast Charger) |
| `user_type` | VARCHAR(50) | User category (Commuter / Casual Driver / Long-Distance Traveler) |

---

<h2><a class="anchor" id="ddl"></a>🧩 Part A — DDL (Data Definition Language)</h2>

### 1. Create Database
Creates a fresh database to house all project tables.
```sql
CREATE DATABASE EV_Charging_Analytics;
USE EV_Charging_Analytics;
```

### 2. Create Table
Defines the `ev_charging_sessions` table with appropriate data types and constraints. Key decisions:
- `user_id` as `VARCHAR` because values are like `User_1`, not plain integers
- `soc_start_pct` and `soc_end_pct` as `DOUBLE` since dataset has decimal values
- `vehicle_age_years` as `INT` since age should be whole years
- `id` as `AUTO_INCREMENT PRIMARY KEY` for unique row identification

### 3. Add New Column
Adds `charging_efficiency_pct` to store calculated efficiency values.
```sql
ALTER TABLE ev_charging_sessions
ADD COLUMN charging_efficiency_pct DOUBLE AFTER charging_cost_usd;
```

### 4. Modify Column Precision
Increases `charging_cost_usd` precision to 4 decimal places for accurate financial calculations.
```sql
ALTER TABLE ev_charging_sessions
MODIFY COLUMN charging_cost_usd DECIMAL(10, 4);
```

### 5. Drop Column
Removes `temperature_c` as it is not needed for analysis.
```sql
ALTER TABLE ev_charging_sessions
DROP COLUMN temperature_c;
```

---

<h2><a class="anchor" id="dml"></a>✏️ Part B — DML (Data Manipulation Language)</h2>

### 6. Import Records
All 1,320 records were imported from `Ev_charging_pattern.csv` using MySQL Workbench's **Table Data Import Wizard** with UTF-8 encoding and direct column mapping.

### 7. Update Charging Efficiency
Calculates and populates `charging_efficiency_pct` for all rows using the formula:
```sql
UPDATE ev_charging_sessions
SET charging_efficiency_pct = (energy_consumed / battery_capacity_kwh) * 100;
```
*A higher value means more of the battery capacity was utilized during the session.*

### 8. Increase Cost for New York (5%)
Applies a 5% price increase to all sessions at New York stations.  
Multiplying by `1.05` = original 100% + 5% increase.
```sql
UPDATE ev_charging_sessions
SET charging_cost_usd = charging_cost_usd * 1.05
WHERE charging_station_location = 'New York';
```

### 9. Delete Low Energy Sessions
Removes sessions where `energy_consumed < 5` kWh as they likely represent incomplete or failed charging events.
```sql
DELETE FROM ev_charging_sessions
WHERE energy_consumed < 5;
```

### 10. Insert Test Record
Manually inserts a single test session to verify insert functionality and table structure.
```sql
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
```

---

<h2><a class="anchor" id="dql"></a>📊 Part C — DQL (Data Query Language)</h2>

### 11. Sessions with High Charging Rate
Retrieves all sessions where charging rate exceeds 40 kW — typically DC Fast Chargers.
```sql
SELECT * FROM ev_charging_sessions
WHERE charging_rate_kw > 40;
```

### 12. Top 5 Most Expensive Sessions
Displays the 5 costliest charging sessions using `RANK()` for accurate tie handling.
```sql
SELECT *,
       RANK() OVER (ORDER BY charging_cost_usd DESC) AS cost_rank
FROM ev_charging_sessions
ORDER BY cost_rank
LIMIT 5;
```
*`RANK()` is preferred over plain `LIMIT` because it correctly handles ties — two sessions with equal cost both get the same rank.*

### 13. Vehicle Model Counts
Shows each distinct vehicle model and how many sessions it has.
```sql
SELECT vehicle_model, COUNT(*) AS total_sessions
FROM ev_charging_sessions
GROUP BY vehicle_model
ORDER BY total_sessions DESC;
```

### 14. Average Charging Cost per Location
Finds the average session cost at each city/station location.
```sql
SELECT charging_station_location, 
       ROUND(AVG(charging_cost_usd), 2) AS avg_cost
FROM ev_charging_sessions
GROUP BY charging_station_location
ORDER BY avg_cost DESC;
```

### 15. Weekend Sessions
Lists all sessions that occurred on Saturday or Sunday.
```sql
SELECT * FROM ev_charging_sessions
WHERE day_of_week IN ('Saturday', 'Sunday');
```

### 16. High SOC Gain Sessions
Retrieves sessions where the battery charge increased by more than 40 percentage points — indicating a deep charge from low to high.
```sql
SELECT * FROM ev_charging_sessions
WHERE (soc_end_pct - soc_start_pct) > 40;
```

### 17. Average Energy and Duration per Charger Type
Compares how different charger types (Level 1, Level 2, DC Fast Charger) perform on average.
```sql
SELECT charger_type,
       ROUND(AVG(energy_consumed), 2) AS avg_energy_kwh,
       ROUND(AVG(charging_duration_hours), 2) AS avg_duration_hrs
FROM ev_charging_sessions
GROUP BY charger_type;
```

### 18. Highest Temperature Recorded
*(Note: This query was run before `temperature_c` was dropped in DDL Task 5.)*
```sql
SELECT MAX(temperature_c) AS highest_temp
FROM ev_charging_sessions;
```

### 19. Older Commuter Vehicles
Finds sessions where the vehicle is older than 5 years and the user is a Commuter — useful for identifying aging fleet usage.
```sql
SELECT * FROM ev_charging_sessions
WHERE vehicle_age_years > 5
AND user_type = 'Commuter';
```

### 20. Energy Category Classification
Uses `CASE WHEN` to label each session as Low, Medium, or High Energy based on kWh consumed.
```sql
SELECT *,
  CASE 
    WHEN energy_consumed < 20 THEN 'Low Energy'
    WHEN energy_consumed BETWEEN 20 AND 50 THEN 'Medium Energy'
    ELSE 'High Energy'
  END AS energy_category
FROM ev_charging_sessions;
```
*Thresholds: below 20 kWh = Low, 20–50 kWh = Medium, above 50 kWh = High.*

---

<h2><a class="anchor" id="tools"></a>🧰 Tools & Technologies</h2>

| Tool | Purpose |
|------|---------|
| MySQL 8.0 | Database engine |
| MySQL Workbench | Query editor and import wizard |
| SQL (DDL, DML, DQL) | Data definition, manipulation, and querying |
| CSV (1,320 records) | Source dataset |

---

<h2><a class="anchor" id="how-to-run"></a>🏁 How to Run</h2>

1. Open MySQL Workbench and connect to your local server
2. Run `ev_charging_project.sql` — it contains all statements in order
3. Screenshots of all query outputs are in the `outputs/` folder

---

<h2><a class="anchor" id="deliverables"></a>🧾 Project Deliverables</h2>

- ✅ `Ev_charging_pattern.csv` — Source dataset
- ✅ `ev_charging_project.sql` — All SQL statements (DDL + DML + DQL)
- ✅ `readme.md` — This documentation file
- ✅ `outputs/` — Screenshots of all query results

---

<h2><a class="anchor" id="author--contact"></a>👤 Author & Contact</h2>

**Ayesha Shaikh**  
Data Analyst  
📧 Email: skayesha318siddiqa@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/sk-ayesha-siddiqa)
