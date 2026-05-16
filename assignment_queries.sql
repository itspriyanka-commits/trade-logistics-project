-- =================================================
-- ASSIGNMENT QUERIES — Cargo & Shipping Database
-- =================================================


-- -------------------------
-- QUERY 1: List all shipments with supplier and customer names
-- -------------------------
SELECT 
    sd.shipment_id,
    s.supplier_name,
    c.customer_name,
    sd.shipment_status,
    sd.dispatch_date,
    sd.expected_delivery,
    sd.shipping_cost
FROM shipping_details sd
JOIN cargo cg    ON sd.cargo_id    = cg.cargo_id
JOIN supplier s  ON cg.supplier_id = s.supplier_id
JOIN customer c  ON cg.customer_id = c.customer_id;


-- -------------------------
-- QUERY 2: Find all high hazard cargo with their shipment status
-- -------------------------
SELECT 
    cg.cargo_id,
    cg.cargo_type,
    cg.hazard_level,
    cg.weight,
    cg.value,
    sd.shipment_status
FROM cargo cg
JOIN shipping_details sd ON cg.cargo_id = sd.cargo_id
WHERE cg.hazard_level = 'High';


-- -------------------------
-- QUERY 3: Total shipping cost per transport mode
-- -------------------------
SELECT 
    tm.mode_type,
    tm.company_name,
    COUNT(sd.shipment_id)  AS total_shipments,
    SUM(sd.shipping_cost)  AS total_shipping_cost
FROM shipping_details sd
JOIN transport_mode tm ON sd.transport_id = tm.transport_id
GROUP BY tm.mode_type, tm.company_name;


-- -------------------------
-- QUERY 4: Warehouse occupancy percentage
-- -------------------------
SELECT 
    warehouse_name,
    location,
    storage_capacity,
    current_stock,
    ROUND((current_stock * 100.0 / storage_capacity), 2) AS occupancy_percent,
    temperature_control
FROM godown;


-- -------------------------
-- QUERY 5: Shipments that are delayed or still in transit
-- -------------------------
SELECT 
    sd.shipment_id,
    s.supplier_name,
    c.customer_name,
    sd.shipment_status,
    sd.expected_delivery,
    sd.shipping_cost
FROM shipping_details sd
JOIN cargo cg   ON sd.cargo_id    = cg.cargo_id
JOIN supplier s ON cg.supplier_id = s.supplier_id
JOIN customer c ON cg.customer_id = c.customer_id
WHERE sd.shipment_status IN ('Delayed', 'In Transit');


-- -------------------------
-- QUERY 6: Broker commission earned per deal
-- -------------------------
SELECT 
    mb.broker_name,
    mb.commission_rate,
    bd.deal_amount,
    ROUND((bd.deal_amount * mb.commission_rate / 100), 2) AS commission_earned,
    bd.deal_date
FROM broker_deals bd
JOIN middle_brokers mb ON bd.broker_id = mb.broker_id;


-- -------------------------
-- QUERY 7: Shipments with pending inspection or inactive insurance
-- -------------------------
SELECT 
    sd.shipment_id,
    sd.shipment_status,
    sm.inspection_status,
    sm.insurance_status,
    sm.hazard_protocol
FROM safety_measures sm
JOIN shipping_details sd ON sm.shipment_id = sd.shipment_id
WHERE sm.inspection_status != 'Passed'
   OR sm.insurance_status   = 'Inactive';


-- -------------------------
-- QUERY 8: Countries with restricted trade or high political risk
-- -------------------------
SELECT 
    country_name,
    trade_status,
    political_risk
FROM country
WHERE trade_status   = 'Restricted'
   OR political_risk = 'High';


-- -------------------------
-- QUERY 9: Shipment clearance status with authority details
-- -------------------------
SELECT 
    sc.clearance_id,
    sd.shipment_id,
    ra.authority_name,
    ra.checkpoint_location,
    sc.clearance_date,
    sc.remarks
FROM shipment_clearance sc
JOIN shipping_details sd       ON sc.shipment_id  = sd.shipment_id
JOIN regulatory_authorities ra ON sc.authority_id = ra.authority_id;


-- -------------------------
-- QUERY 10: Employees with their assigned warehouse
-- -------------------------
SELECT 
    e.employee_name,
    e.role,
    e.salary,
    e.shift_timing,
    g.warehouse_name,
    g.location
FROM employees e
JOIN godown g ON e.warehouse_id = g.warehouse_id
ORDER BY e.salary DESC;


-- -------------------------
-- QUERY 11: Trade agreements between countries
-- -------------------------
SELECT 
    c1.country_name  AS country_1,
    c2.country_name  AS country_2,
    cr.trade_agreement,
    cr.tariff_rate,
    cr.embargo_status
FROM country_relations cr
JOIN country c1 ON cr.country1_id = c1.country_id
JOIN country c2 ON cr.country2_id = c2.country_id;


-- -------------------------
-- QUERY 12: Total cargo value grouped by supplier
-- -------------------------
SELECT 
    s.supplier_name,
    COUNT(cg.cargo_id)  AS total_cargo,
    SUM(cg.value)       AS total_cargo_value,
    SUM(cg.weight)      AS total_weight
FROM cargo cg
JOIN supplier s ON cg.supplier_id = s.supplier_id
GROUP BY s.supplier_name;


-- -------------------------
-- QUERY 13: Delivery on time check
-- -------------------------
SELECT 
    sd.shipment_id,
    sd.expected_delivery,
    sd.actual_delivery,
    CASE 
        WHEN sd.actual_delivery <= sd.expected_delivery THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status
FROM shipping_details sd
WHERE sd.actual_delivery IS NOT NULL;


-- -------------------------
-- QUERY 14: Routes sorted by estimated travel days
-- -------------------------
SELECT 
    route_id,
    source_country || ' → ' || destination_country AS route,
    distance,
    estimated_days,
    risk_level
FROM route
ORDER BY estimated_days;


-- -------------------------
-- QUERY 15: Customers with pending payments
-- -------------------------
SELECT 
    c.customer_name,
    co.country_name,
    c.phone,
    c.email,
    c.payment_status
FROM customer c
JOIN country co ON c.country_id = co.country_id
WHERE c.payment_status = 'Pending';


-- =================================================
-- VIEWS (Simple)
-- =================================================


-- -------------------------
-- VIEW 1: Basic shipment overview
-- -------------------------
CREATE VIEW vw_shipment_overview AS
SELECT 
    sd.shipment_id,
    s.supplier_name,
    c.customer_name,
    cg.cargo_type,
    sd.shipment_status,
    sd.shipping_cost
FROM shipping_details sd
JOIN cargo cg   ON sd.cargo_id    = cg.cargo_id
JOIN supplier s ON cg.supplier_id = s.supplier_id
JOIN customer c ON cg.customer_id = c.customer_id;

-- Use the view:
SELECT * FROM vw_shipment_overview;


-- -------------------------
-- VIEW 2: Cargo with hazard and safety info
-- -------------------------
CREATE VIEW vw_cargo_safety AS
SELECT 
    cg.cargo_type,
    cg.hazard_level,
    sm.inspection_status,
    sm.insurance_status,
    sm.hazard_protocol
FROM cargo cg
JOIN shipping_details sd ON cg.cargo_id    = sd.cargo_id
JOIN safety_measures sm  ON sd.shipment_id = sm.shipment_id;

-- Use the view:
SELECT * FROM vw_cargo_safety;


-- -------------------------
-- VIEW 3: Supplier with their country info
-- -------------------------
CREATE VIEW vw_supplier_country AS
SELECT 
    s.supplier_name,
    s.phone,
    s.email,
    co.country_name,
    co.trade_status,
    co.political_risk
FROM supplier s
JOIN country co ON s.country_id = co.country_id;

-- Use the view:
SELECT * FROM vw_supplier_country;


-- -------------------------
-- VIEW 4: Warehouse with assigned employee
-- -------------------------
CREATE VIEW vw_warehouse_employee AS
SELECT 
    g.warehouse_name,
    g.location,
    g.storage_capacity,
    g.current_stock,
    e.employee_name,
    e.role,
    e.shift_timing
FROM godown g
LEFT JOIN employees e ON g.warehouse_id = e.warehouse_id;

-- Use the view:
SELECT * FROM vw_warehouse_employee;


-- -------------------------
-- VIEW 5: Broker deal and commission info
-- -------------------------
CREATE VIEW vw_broker_deals AS
SELECT 
    mb.broker_name,
    mb.commission_rate,
    bd.deal_amount,
    bd.deal_date,
    ROUND((bd.deal_amount * mb.commission_rate / 100), 2) AS commission_earned
FROM middle_brokers mb
JOIN broker_deals bd ON mb.broker_id = bd.broker_id;

-- Use the view:
SELECT * FROM vw_broker_deals;
