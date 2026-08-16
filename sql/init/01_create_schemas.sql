-- ===================================================
-- SmartLift Data Intelligence Platform - DDL Initialisation
-- Schemas: bronze, silver, gold
-- ===================================================

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

COMMENT ON SCHEMA bronze IS 'Staging layer for raw un-transformed data ingested from CSVs, APIs, and Simulator';
COMMENT ON SCHEMA silver IS 'Cleaned, typed, normalized, and validated domain data tables';
COMMENT ON SCHEMA gold IS 'Dimensional Data Warehouse (Star Schema: Dimensions and Fact tables)';

-- ===================================================
-- STAGING / BRONZE TABLES
-- ===================================================

-- 1. Elevator Energy Efficiency Raw
CREATE TABLE IF NOT EXISTS bronze.raw_elevator_energy_efficiency (
    id SERIAL PRIMARY KEY,
    num_elevators INT,
    num_floors INT,
    avg_passengers NUMERIC(10,2),
    traffic_intensity NUMERIC(10,2),
    avg_waiting_time_sec NUMERIC(10,2),
    avg_trip_time_sec NUMERIC(10,2),
    dispatch_algorithm VARCHAR(100),
    total_energy_kwh NUMERIC(10,2),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255) DEFAULT 'Elevator_Energy_Efficiency.csv'
);

-- 2. Elevator Traffic Raw
CREATE TABLE IF NOT EXISTS bronze.raw_elevator_traffic (
    id SERIAL PRIMARY KEY,
    timestamp_str VARCHAR(100),
    floor_requested INT,
    wait_time_seconds NUMERIC(10,2),
    direction VARCHAR(20),
    people_count INT,
    peak_hour INT,
    load_percent NUMERIC(10,2),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255) DEFAULT 'elevator_traffic_dataset.csv'
);

-- 3. Elevator Door Fault Raw
CREATE TABLE IF NOT EXISTS bronze.raw_elevator_door_fault (
    id SERIAL PRIMARY KEY,
    door_distance_signal NUMERIC(10,4),
    door_velocity NUMERIC(10,4),
    door_acceleration NUMERIC(10,4),
    signal_noise_level NUMERIC(10,4),
    trapezoid_curve_fit_error NUMERIC(10,4),
    processing_time_sec NUMERIC(10,4),
    fault_status INT,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255) DEFAULT 'elevator_door_fault_dataset.csv'
);

-- 4. Predictive Maintenance Raw
CREATE TABLE IF NOT EXISTS bronze.raw_predictive_maintenance (
    id SERIAL PRIMARY KEY,
    sample_id INT,
    revolutions NUMERIC(10,2),
    humidity NUMERIC(10,2),
    vibration NUMERIC(10,4),
    x1 NUMERIC(10,4),
    x2 NUMERIC(10,4),
    x3 NUMERIC(10,4),
    x4 NUMERIC(10,4),
    x5 NUMERIC(10,4),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255) DEFAULT 'predictive-maintenance-dataset.csv'
);

-- ===================================================
-- GOLD CORE DIMENSIONS
-- ===================================================

-- dim_date
CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    week INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

-- dim_time
CREATE TABLE IF NOT EXISTS gold.dim_time (
    time_key INT PRIMARY KEY,
    hour INT NOT NULL,
    minute INT NOT NULL,
    second INT NOT NULL,
    time_of_day VARCHAR(20) NOT NULL,
    hour_bucket VARCHAR(20) NOT NULL
);

-- dim_building
CREATE TABLE IF NOT EXISTS gold.dim_building (
    building_key SERIAL PRIMARY KEY,
    building_id VARCHAR(50) NOT NULL UNIQUE,
    building_name VARCHAR(100) NOT NULL,
    building_type VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Morocco',
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    num_floors INT,
    construction_year INT,
    occupancy_capacity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- dim_elevator
CREATE TABLE IF NOT EXISTS gold.dim_elevator (
    elevator_key SERIAL PRIMARY KEY,
    elevator_id VARCHAR(50) NOT NULL UNIQUE,
    serial_number VARCHAR(100),
    building_key INT REFERENCES gold.dim_building(building_key),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    installation_date DATE,
    capacity_kg NUMERIC(10,2),
    capacity_persons INT,
    speed_mps NUMERIC(5,2),
    elevator_type VARCHAR(50) DEFAULT 'traction',
    current_status VARCHAR(50) DEFAULT 'OPERATIONAL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- dim_sensor
CREATE TABLE IF NOT EXISTS gold.dim_sensor (
    sensor_key SERIAL PRIMARY KEY,
    sensor_id VARCHAR(50) NOT NULL UNIQUE,
    elevator_key INT REFERENCES gold.dim_elevator(elevator_key),
    sensor_type VARCHAR(50) NOT NULL,
    measurement_unit VARCHAR(20),
    location VARCHAR(100),
    installation_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Initial default metadata inserts
INSERT INTO gold.dim_building (building_id, building_name, building_type, city, num_floors, occupancy_capacity)
VALUES ('BLD_EMSI_01', 'EMSI Casablanca Campus 1', 'University', 'Casablanca', 7, 500),
       ('BLD_MARELEV_HQ', 'MARELEV Headquarters', 'Commercial', 'Casablanca', 5, 200)
ON CONFLICT (building_id) DO NOTHING;

INSERT INTO gold.dim_elevator (elevator_id, serial_number, building_key, manufacturer, model, capacity_kg, capacity_persons, speed_mps)
VALUES ('ELEV_01', 'SN-MRL-2024-001', 1, 'MARELEV', 'UltraLift-3000', 1000.0, 13, 1.75),
       ('ELEV_02', 'SN-MRL-2024-002', 1, 'MARELEV', 'UltraLift-3000', 1000.0, 13, 1.75),
       ('ELEV_03', 'SN-MRL-2025-009', 2, 'MARELEV', 'CargoMaster-5000', 2000.0, 26, 1.00)
ON CONFLICT (elevator_id) DO NOTHING;

SELECT 'SmartLift Database Initialization Complete!' as status;
