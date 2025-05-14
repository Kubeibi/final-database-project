-- =====================================================
-- Project Title: Black Soldier Fly (BSF) Farm Management System
-- Description:
-- A scalable database system to track batches, feedings, harvests, sales,
-- inventory, environment, mortality, transactions, and reports. 
-- Designed to handle larger datasets, support future growth, and provide 
-- comprehensive analytics.
--
-- Create database and switch to it
-- =====================================================
CREATE DATABASE IF NOT EXISTS bsf_farm_v2;
USE bsf_farm_v2;

-- =====================================================
-- Customers Table
-- =====================================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    address TEXT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Staff Table
-- =====================================================
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    contact VARCHAR(20),
    hire_date DATE,
    status ENUM('Active', 'Inactive') DEFAULT 'Active'
);

-- =====================================================
-- Products Table (Products sold: Larvae, Frass, Pupae)
-- =====================================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category ENUM('Larvae', 'Frass', 'Pupae', 'Other') NOT NULL
);

-- =====================================================
-- Batches Table
-- One-to-Many with Feedings and Harvests
-- =====================================================
CREATE TABLE batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    start_date DATE NOT NULL,
    stage ENUM('Egg', 'Larvae', 'Pupae', 'Adult') NOT NULL,
    current_weight_kg DECIMAL(5,2),
    current_mortality DECIMAL(5,2) DEFAULT 0,  -- Mortality percentage
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    notes TEXT
);

-- =====================================================
-- Feedings Table
-- Many feedings per batch
-- =====================================================
CREATE TABLE feedings (
    feeding_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    feed_date DATE NOT NULL,
    feed_type VARCHAR(100) NOT NULL,
    feed_quantity_kg DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- Harvests Table
-- Each batch may have multiple harvests
-- =====================================================
CREATE TABLE harvests (
    harvest_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    harvest_date DATE NOT NULL,
    larvae_weight_kg DECIMAL(5,2) NOT NULL,
    frass_weight_kg DECIMAL(5,2),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- Sales Table
-- Many-to-One with Customers and Products
-- =====================================================
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATE NOT NULL,
    product_id INT NOT NULL,
    quantity_kg DECIMAL(5,2) NOT NULL,
    price_per_kg DECIMAL(6,2) NOT NULL,
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (quantity_kg * price_per_kg) STORED,
    customer_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- Inventory Table (Track inventory for feed and supplies)
-- =====================================================
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    quantity_available DECIMAL(5,2) NOT NULL,
    unit_price DECIMAL(6,2),
    restock_date DATE,
    status ENUM('In Stock', 'Out of Stock', 'Pending') DEFAULT 'In Stock'
);

-- =====================================================
-- Mortality Table (Track batch mortality)
-- =====================================================
CREATE TABLE mortality (
    mortality_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    mortality_date DATE NOT NULL,
    mortality_rate DECIMAL(5,2) NOT NULL,  -- Percentage
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- Transactions Table (Track payments for sales)
-- =====================================================
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Cash', 'Card', 'Transfer') NOT NULL,
    payment_status ENUM('Completed', 'Pending', 'Failed') DEFAULT 'Completed',
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);

-- =====================================================
-- Environment Table (Track environmental conditions)
-- =====================================================
CREATE TABLE environment (
    environment_id INT AUTO_INCREMENT PRIMARY KEY,
    log_time DATETIME NOT NULL,
    temperature_c DECIMAL(4,2) NOT NULL,
    humidity_percent DECIMAL(5,2) NOT NULL,
    location VARCHAR(100)
);

-- =====================================================
-- Report Table (Custom analytics and reporting)
-- =====================================================
CREATE TABLE reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_date DATE NOT NULL,
    report_type ENUM('Batch Performance', 'Sales', 'Inventory', 'Mortality') NOT NULL,
    report_data JSON,  -- Store JSON formatted report data for flexibility
    generated_by INT,  -- staff_id who generated the report
    FOREIGN KEY (generated_by) REFERENCES staff(staff_id)
);

