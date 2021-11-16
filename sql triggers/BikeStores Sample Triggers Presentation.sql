USE BikeStores;

--create audit table to use

CREATE TABLE [production].[product_audits](
    change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);

DROP TABLE IF EXISTS [production].[product_audits];

--create a trigger that inserts into audit table values inserted or deleted from the products table--
CREATE TRIGGER [production].[trg_product_audit]
ON production.products
AFTER INSERT, DELETE
AS
BEGIN

--set nocount optimizes the query--

    SET NOCOUNT ON; 
    INSERT INTO production.product_audits(
        product_id, 
        product_name,
        brand_id,
        category_id,
        model_year,
        list_price, 
        updated_at, 
        operation
    )
    SELECT
        i.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        i.list_price,
        GETDATE(),
        'INS'
    FROM
        inserted i
    UNION ALL
    SELECT
        d.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        d.list_price,
        GETDATE(),
        'DEL'
    FROM
        deleted d;
END;

--event that fires the trigger--

INSERT INTO production.products(
    product_name, 
    brand_id, 
    category_id, 
    model_year, 
    list_price
)
VALUES (
    'testing product',
    2,
    2,
    2021,
    58
);

delete from production.products where product_name = 'Test product'


--check for changes made in tables

SELECT 
    *
FROM 
    production.product_audits;

    SELECT * FROM production.products;

--drop trigger--
DROP TRIGGER IF EXISTS production.trg_product_audit;


-- INSTEAD OF TRIIGER--

--create approvals' table--
CREATE TABLE production.brand_approvals(
    brand_id INT IDENTITY PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);

DROP TABLE production.brand_approvals

--create view of brands--
CREATE VIEW [production].[vw_brands] 
AS
SELECT
    brand_name,
    'Approved' approval_status
FROM
    production.brands
UNION
SELECT
    brand_name,
    'Pending Approval' approval_status
FROM
    production.brand_approvals;

DROP VIEW production.brand_approvals


--trigger that adds brand name into brand approvals table if brand doesn't exist in brands table--
CREATE TRIGGER [production].[trg_vw_brands] 
ON production.vw_brands
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO production.brand_approvals ( 
        brand_name
    )
    SELECT
        i.brand_name
    FROM
        inserted i
    WHERE
        i.brand_name NOT IN (
            SELECT 
                brand_name
            FROM
                production.brands
        );
END


SELECT brand_name FROM production.brand_approvals;


SELECT brand_name FROM production.brands;


--insert new brand name, this fire the triggers--
INSERT INTO production.vw_brands(brand_name)
VALUES('Eddy Merckx');
 

-- --drop a DML trigger--
DROP TRIGGER IF EXISTS production.trg_vw_brands;


-- --DDL TRIGGERS--
--index log table takes in the values of indexes
CREATE TABLE index_logs (
    log_id INT IDENTITY PRIMARY KEY,
    event_data XML NOT NULL,
    changed_by SYSNAME NOT NULL
);
GO



--create DDL trigger that is fired when index changes take place--
CREATE TRIGGER trg_index_changes
ON DATABASE
FOR	
--event types--
    CREATE_INDEX,
    ALTER_INDEX, 
    DROP_INDEX
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO index_logs (
        event_data,
        changed_by
    )
    VALUES (
        EVENTDATA(),
        USER
    );
END;
GO



--dropping a DDL trigger--
DROP TRIGGER IF EXISTS trg_index_changes ON DATABASE;

--create indices for columns--
CREATE NONCLUSTERED INDEX nidx_fname
ON sales.customers(first_name);
GO

CREATE NONCLUSTERED INDEX nidx_lname
ON sales.customers(last_name);
GO

--drop indexes--

DROP INDEX [nidx_fname] ON [sales].[customers]
GO

DROP INDEX [nidx_lname] ON [sales].[customers]
GO

--check for change--
SELECT 
    *
FROM
    index_logs;
    
DROP TABLE dbo.index_logs;


--listing all triggers--
SELECT  
    name,
    is_instead_of_trigger
FROM 
    sys.triggers  
WHERE 
    type = 'TR';


-- --get definition of a trigger--

-- SELECT 
--     definition   
-- FROM 
--     sys.sql_modules  
-- WHERE 
--     object_id = OBJECT_ID('trg_index_changes'); 


--enable and disable triggers--
ENABLE TRIGGER ALL ON DATABASE; 
DISABLE TRIGGER ALL ON DATABASE;


