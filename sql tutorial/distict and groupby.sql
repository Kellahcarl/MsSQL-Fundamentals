-- select distict in for one column
SELECT DISTINCT
    city
FROM
    sales.customers
ORDER BY
    city;


-- finding distinct city and state from customer table
SELECT DISTINCT
    city,
    state
FROM
    sales.customers


-- DISTINCT with null values example
SELECT DISTINCT
    phone
FROM
    sales.customers
ORDER BY
    phone;


SELECT 
	city, 
	state, 
	zip_code
FROM 
	sales.customers
GROUP BY 
	city, state, zip_code
ORDER BY
	city, state, zip_code

SELECT 
	DISTINCT 
       city, 
       state, 
       zip_code
FROM 
	sales.customers;