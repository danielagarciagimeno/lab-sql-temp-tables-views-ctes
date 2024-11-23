USE sakila;

-- Step 1: Create a View

CREATE VIEW rental_summary AS
SELECT 
    customer.customer_id,
    CONCAT(customer.first_name, ' ', customer.last_name) AS customer_name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM 
    customer
JOIN 
    rental ON customer.customer_id = rental.customer_id
GROUP BY 
    customer.customer_id;
    
-- Step 2: Create a Temporary Table

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    rental_summary.customer_id,
    SUM(payment.amount) AS total_paid
FROM 
    rental_summary
JOIN 
    payment ON rental_summary.customer_id = payment.customer_id
GROUP BY 
    rental_summary.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report

WITH customer_summary AS (
    SELECT
        rental_summary.customer_name,
        rental_summary.email,
        rental_summary.rental_count,
        customer_payment_summary.total_paid,
        CASE
            WHEN rental_summary.rental_count > 0 THEN customer_payment_summary.total_paid / rental_summary.rental_count
            ELSE 0
        END AS average_payment_per_rental
    FROM
        rental_summary
    JOIN
        customer_payment_summary ON rental_summary.customer_id = customer_payment_summary.customer_id
)

-- Generar el reporte final
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM
    customer_summary;