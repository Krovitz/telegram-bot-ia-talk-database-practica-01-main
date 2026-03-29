-- Sakila Sample Database Schema
-- Version 1.5

-- PostgreSQL port of 01-sakila-schema.sql from MySQL

SET client_encoding = 'UTF8';

SET SCHEMA 'public';

--
-- Definition for type RATING
--

CREATE TYPE RATING AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17');

--
-- Definition for domain YEARONLY
--

CREATE DOMAIN YEARONLY AS INT
  CONSTRAINT year_check CHECK ((VALUE >= 1901) AND (VALUE <= 2155));

--
-- Common trigger function
--

CREATE FUNCTION set_last_update_func() RETURNS TRIGGER 
AS $$  
BEGIN
  NEW.last_update=CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

--
-- Table structure for table `address`
--

CREATE TABLE address (
  address_id SMALLINT CHECK (address_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT CHECK (city_id > 0) NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (address_id)
);

CREATE INDEX idx_address_fk_city_id ON address (city_id);

CREATE TRIGGER address_before_update BEFORE UPDATE ON address FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `actor`
--

CREATE TABLE actor (
  actor_id SMALLINT CHECK (actor_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id)
);

CREATE INDEX idx_actor_last_name ON actor (last_name);

CREATE TRIGGER actor_before_update BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `category`
--

CREATE TABLE category (
  category_id SMALLINT CHECK (category_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (category_id)
);

CREATE TRIGGER category_before_update BEFORE UPDATE ON category FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `city`
--

CREATE TABLE city (
  city_id SMALLINT CHECK (city_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT CHECK (country_id > 0) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (city_id)
);

CREATE INDEX idx_city_fk_country_id ON city (country_id);

CREATE TRIGGER city_before_update BEFORE UPDATE ON city FOR EACH ROW EXECUTE FUNCTION set_last_update_func();
--
-- Table structure for table `country`
--

CREATE TABLE country (
  country_id SMALLINT CHECK (country_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (country_id)
);

CREATE TRIGGER country_before_update BEFORE UPDATE ON country FOR EACH ROW EXECUTE FUNCTION set_last_update_func();
--
-- Table structure for table `customer`
--

CREATE TABLE customer (
  customer_id SMALLINT CHECK (customer_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  store_id SMALLINT CHECK (store_id > 0) NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT CHECK (address_id > 0) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  create_date TIMESTAMP(0) NOT NULL,
  last_update TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id)
);

CREATE INDEX idx_customer_fk_store_id ON customer (store_id);
CREATE INDEX idx_customer_fk_address_id ON customer (address_id);
CREATE INDEX idx_customer_last_name ON customer (last_name);

CREATE TRIGGER customer_before_update BEFORE UPDATE ON customer FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `film`
--

CREATE TABLE film (
  film_id SMALLINT CHECK (film_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  title VARCHAR(128) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year YEARONLY DEFAULT NULL,
  language_id SMALLINT CHECK (language_id > 0) NOT NULL,
  original_language_id SMALLINT CHECK (original_language_id > 0) DEFAULT NULL,
  rental_duration SMALLINT CHECK (rental_duration > 0) NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT CHECK (length > 0) DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating RATING DEFAULT 'G'::RATING,
  special_features text[] DEFAULT NULL, -- PostgreSQL does not support MySQL-like SET types
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id)
);

CREATE INDEX idx_film_title ON film (title);
CREATE INDEX idx_film_fk_language_id ON film (language_id);
CREATE INDEX idx_film_fk_original_language_id ON film (original_language_id);

CREATE TRIGGER film_before_update BEFORE UPDATE ON film FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `film_actor`
--

CREATE TABLE film_actor (
  actor_id SMALLINT CHECK (actor_id > 0) NOT NULL,
  film_id SMALLINT CHECK (film_id > 0) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id,film_id)
);

CREATE INDEX idx_film_actor_fk_film_id ON film_actor (film_id);

CREATE TRIGGER film_actor_before_update BEFORE UPDATE ON film_actor FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `film_category`
--

CREATE TABLE film_category (
  film_id SMALLINT CHECK (film_id > 0) NOT NULL,
  category_id SMALLINT CHECK (category_id > 0) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id, category_id)
);

CREATE TRIGGER film_category_before_update BEFORE UPDATE ON film_category FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `film_text`
--

CREATE TABLE film_text (
  film_id SMALLINT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  PRIMARY KEY (film_id)
);

CREATE INDEX idx_film_text_title_description ON film_text(title,description);

--
-- Triggers for loading film_text from film
--

CREATE FUNCTION ins_film_func() RETURNS TRIGGER 
AS $$  
BEGIN
  INSERT INTO 
    film_text (film_id, title, description)
  VALUES 
    (new.film_id, new.title, new.description);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_film AFTER INSERT ON film 
FOR EACH ROW EXECUTE FUNCTION ins_film_func();


CREATE FUNCTION upd_film_func() RETURNS TRIGGER 
AS $$  
BEGIN
  IF (old.title != new.title) OR (old.description != new.description) OR (old.film_id != new.film_id)
  THEN
    UPDATE 
	  film_text
    SET 
	  title=new.title,
      description=new.description,
      film_id=new.film_id
    WHERE 
	  film_id=old.film_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_film AFTER UPDATE ON film 
FOR EACH ROW EXECUTE FUNCTION upd_film_func();


CREATE FUNCTION del_film_func() RETURNS TRIGGER 
AS $$  
BEGIN
  DELETE FROM film_text WHERE film_id = old.film_id;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER del_film AFTER DELETE ON film 
FOR EACH ROW EXECUTE FUNCTION del_film_func();

--
-- Table structure for table `inventory`
--

CREATE TABLE inventory (
  inventory_id INT CHECK (inventory_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  film_id SMALLINT CHECK (film_id > 0) NOT NULL,
  store_id SMALLINT CHECK (store_id > 0) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (inventory_id)
);

CREATE INDEX idx_inventory_fk_film_id ON inventory (film_id);
CREATE INDEX idx_inventory_store_id_film_id ON inventory (store_id,film_id);

CREATE TRIGGER inventory_before_update BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `language`
--

CREATE TABLE language (
  language_id SMALLINT CHECK (language_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (language_id)
);

CREATE TRIGGER language_before_update BEFORE UPDATE ON language FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `payment`
--

CREATE TABLE payment (
  payment_id SMALLINT CHECK (payment_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  customer_id SMALLINT CHECK (customer_id > 0) NOT NULL,
  staff_id SMALLINT CHECK (staff_id > 0) NOT NULL,
  rental_id INT DEFAULT NULL,
  amount DECIMAL(5,2) NOT NULL,
  payment_date TIMESTAMP(0) NOT NULL,
 last_update TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (payment_id)
) ;

CREATE INDEX idx_payment_fk_staff_id ON payment (staff_id);
CREATE INDEX idx_payment_fk_customer_id ON payment (customer_id);

CREATE TRIGGER payment_before_update BEFORE UPDATE ON payment FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `rental`
--

CREATE TABLE rental (
  rental_id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
  rental_date TIMESTAMP(0) NOT NULL,
  inventory_id INT CHECK (inventory_id > 0) NOT NULL,
  customer_id SMALLINT CHECK (customer_id > 0) NOT NULL,
  return_date TIMESTAMP(0) DEFAULT NULL,
  staff_id SMALLINT CHECK (staff_id > 0) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (rental_id),
  UNIQUE (rental_date,inventory_id,customer_id)
) ;

CREATE INDEX idx_rental_fk_inventory_id ON rental (inventory_id);
CREATE INDEX idx_rental_fk_customer_id ON rental (customer_id);
CREATE INDEX idx_rental_fk_staff_id ON rental (staff_id);

CREATE TRIGGER rental_before_update BEFORE UPDATE ON rental FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `staff`
--

CREATE TABLE staff (
  staff_id SMALLINT CHECK (staff_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id SMALLINT CHECK (address_id > 0) NOT NULL,
  picture BYTEA DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  store_id SMALLINT CHECK (store_id > 0) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) DEFAULT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (staff_id)
) ;

CREATE INDEX idx_staff_fk_store_id ON staff (store_id);
CREATE INDEX idx_staff_fk_address_id ON staff (address_id);

CREATE TRIGGER staff_before_update BEFORE UPDATE ON staff FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Table structure for table `store`
--

CREATE TABLE store (
  store_id SMALLINT CHECK (store_id > 0) NOT NULL GENERATED ALWAYS AS IDENTITY,
  manager_staff_id SMALLINT CHECK (manager_staff_id > 0) NOT NULL,
  address_id SMALLINT CHECK (address_id > 0) NOT NULL,
  last_update TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (store_id),
  UNIQUE (manager_staff_id)
);

CREATE INDEX idx_store_fk_address_id ON store (address_id);

CREATE TRIGGER store_before_update BEFORE UPDATE ON store FOR EACH ROW EXECUTE FUNCTION set_last_update_func();

--
-- Foreign key constraints
--

ALTER TABLE address
  ADD CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE city
  ADD CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE customer
  ADD CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE customer
  ADD CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE film
  ADD CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE film
  ADD CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE film_actor
  ADD CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE film_actor
  ADD CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE film_category
  ADD CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE film_category
  ADD CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE inventory
  ADD CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE inventory
  ADD CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE payment
  ADD CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE payment
  ADD CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE payment
  ADD CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE rental
  ADD CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE rental
  ADD CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE rental
  ADD CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE staff
  ADD CONSTRAINT fk_staff_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE staff
  ADD CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE store
  ADD CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE store
  ADD CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- View structure for view `customer_list`
--

CREATE VIEW customer_list
AS
SELECT 
  cu.customer_id AS ID, 
  CONCAT(cu.first_name::text, ' '::text, cu.last_name::text) AS name, 
  a.address AS address, 
  a.postal_code AS "zip code",
  a.phone AS phone, 
  city.city AS city, 
  country.country AS country, 
  CASE WHEN cu.active THEN  'active' ELSE '' END AS notes, 
  cu.store_id AS SID
FROM 
  customer AS cu 
JOIN 
  address AS a ON cu.address_id = a.address_id 
JOIN 
  city ON a.city_id = city.city_id
JOIN 
  country ON city.country_id = country.country_id;

--
-- View structure for view `film_list`
--

CREATE VIEW film_list
AS
SELECT 
  film.film_id AS FID, 
  film.title AS title, 
  film.description AS description, 
  category.name AS category, 
  film.rental_rate AS price,
  film.length AS length, 
  film.rating AS rating, 
  string_agg(CONCAT(actor.first_name::text, ' '::text, actor.last_name::text), ', ') AS actors
FROM 
  film 
LEFT JOIN 
  film_category ON film_category.film_id = film.film_id
LEFT JOIN 
  category ON category.category_id = film_category.category_id 
LEFT JOIN 
  film_actor ON film.film_id = film_actor.film_id 
LEFT JOIN 
  actor ON film_actor.actor_id = actor.actor_id
GROUP BY 
  film.film_id, category.name;

--
-- View structure for view `nicer_but_slower_film_list`
--

CREATE VIEW nicer_but_slower_film_list
AS
SELECT 
  film.film_id AS FID, 
  film.title AS title, 
  film.description AS description, 
  category.name AS category, 
  film.rental_rate AS price,
  film.length AS length, 
  film.rating AS rating, 
  string_agg(CONCAT(
    CONCAT(
	  upper("substring"(actor.first_name::text, 1, 1)),
	  lower("substring"(actor.first_name::text, 2, LENGTH(actor.first_name::text))), ' '::text,
	CONCAT(
	  upper("substring"(actor.last_name::text, 1, 1)), 
	  lower("substring"(actor.last_name::text, 2, LENGTH(actor.last_name::text)))))), ', '::text) AS actors
FROM 
  film 
LEFT JOIN 
  film_category ON film_category.film_id = film.film_id
LEFT JOIN 
  category ON category.category_id = film_category.category_id 
LEFT JOIN 
  film_actor ON film.film_id = film_actor.film_id 
LEFT JOIN 
  actor ON film_actor.actor_id = actor.actor_id
GROUP BY 
  film.film_id, category.name;

--
-- View structure for view `staff_list`
--

CREATE VIEW staff_list
AS
SELECT 
  s.staff_id AS ID, 
  CONCAT(s.first_name::text, ' '::text, s.last_name::text) AS name,
  a.address AS address, a.postal_code AS "zip code",
  a.phone AS phone,
  city.city AS city, 
  country.country AS country,
  s.store_id AS SID
FROM 
  staff AS s 
JOIN 
  address AS a ON s.address_id = a.address_id 
JOIN 
  city ON a.city_id = city.city_id
JOIN 
  country ON city.country_id = country.country_id;

--
-- View structure for view `sales_by_store`
--

CREATE VIEW sales_by_store
AS
SELECT
  CONCAT(c.city::text, ','::text, cy.country::text) AS store, 
  CONCAT(m.first_name::text, ' '::text, m.last_name::text) AS manager,
  SUM(p.amount) AS total_sales
FROM 
  payment AS p
INNER JOIN 
  rental AS r ON p.rental_id = r.rental_id
INNER JOIN 
  inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN 
  store AS s ON i.store_id = s.store_id
INNER JOIN 
  address AS a ON s.address_id = a.address_id
INNER JOIN 
  city AS c ON a.city_id = c.city_id
INNER JOIN 
  country AS cy ON c.country_id = cy.country_id
INNER JOIN 
  staff AS m ON s.manager_staff_id = m.staff_id
GROUP BY 
  cy.country, c.city, s.store_id, m.first_name, m.last_name
ORDER BY 
  cy.country, c.city;

--
-- View structure for view `sales_by_film_category`
--
-- Note that total sales will add up to >100% because
-- some titles belong to more than 1 category
--

CREATE VIEW sales_by_film_category
AS
SELECT
  c.name AS category, 
  SUM(p.amount) AS total_sales
FROM 
  payment AS p
INNER JOIN 
  rental AS r ON p.rental_id = r.rental_id
INNER JOIN 
  inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN 
  film AS f ON i.film_id = f.film_id
INNER JOIN 
  film_category AS fc ON f.film_id = fc.film_id
INNER JOIN 
  category AS c ON fc.category_id = c.category_id
GROUP BY 
  c.name
ORDER BY 
  total_sales DESC;

--
-- View structure for view `actor_info`
--

CREATE  VIEW actor_info
AS
SELECT
  a.actor_id,
  a.first_name,
  a.last_name,
  string_agg(DISTINCT 
    CONCAT(c.name, ': ', (
	  SELECT 
	    string_agg(f.title::text, ', ' ORDER BY f.title)
      FROM 
	    film f
      INNER JOIN 
	    film_category fc ON f.film_id = fc.film_id 
	  INNER JOIN 
	    film_actor fa ON f.film_id = fa.film_id
      WHERE 
	    fc.category_id = c.category_id AND fa.actor_id = a.actor_id
    )) , '; ') AS film_info
FROM 
  actor a
LEFT JOIN 
  film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN 
  film_category fc ON fa.film_id = fc.film_id
LEFT JOIN 
  category c ON fc.category_id = c.category_id
GROUP BY 
  a.actor_id, a.first_name, a.last_name;

--
-- Procedure structure for procedure `rewards_report`
--

CREATE PROCEDURE rewards_report (
  IN min_monthly_purchases SMALLINT,
  IN min_dollar_amount_purchased DECIMAL(10,2),
  OUT count_rewardees INT, cur REFCURSOR, cur2 REFCURSOR, cur3 REFCURSOR
)
AS $$
  -- Provides a customizable report on best customers
DECLARE
  last_month_start DATE;
  last_month_end DATE;
BEGIN

  /* Some sanity checks... */
  IF min_monthly_purchases = 0 THEN
    OPEN cur FOR SELECT 'Minimum monthly purchases parameter must be > 0';
    RETURN;
  END IF;
  IF min_dollar_amount_purchased = 0.00 THEN
    OPEN cur2 FOR SELECT 'Minimum monthly dollar amount purchased parameter must be > $0.00';
    RETURN;
  END IF;

  /* Determine start and end time periods */
  last_month_start := CURRENT_DATE - '1 month'::interval;
  last_month_start := STR_TO_DATE(CONCAT(EXTRACT(YEAR FROM last_month_start),'-',EXTRACT(MONTH FROM last_month_start),'-01'),'%Y-%m-%d');
  last_month_end := LAST_DAY(last_month_start);

  /*
     Create a temporary storage area for
     Customer IDs.
  */
  CREATE TEMPORARY TABLE tmpCustomer (customer_id SMALLINT CHECK (customer_id > 0) NOT NULL PRIMARY KEY);

  /*
     Find all customers meeting the
     monthly purchase requirements
  */
  INSERT INTO 
    tmpCustomer (customer_id)
  SELECT 
    p.customer_id
  FROM 
    payment AS p
  WHERE 
    DATE(p.payment_date) BETWEEN last_month_start AND last_month_end
  GROUP BY 
    customer_id
  HAVING 
    SUM(p.amount) > min_dollar_amount_purchased AND 
	COUNT(customer_id) > min_monthly_purchases;

  /* Populate OUT parameter with count of found customers */
  SELECT COUNT(*) FROM tmpCustomer INTO count_rewardees;

  /*
     Output ALL customer information of matching rewardees.
     Customize output as needed.
  */
  OPEN 
    cur3 FOR SELECT c.*
  FROM 
    tmpCustomer AS t
  INNER JOIN 
    customer AS c ON t.customer_id = c.customer_id;

  /* Clean up */
  DROP TABLE tmpCustomer;

END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION get_customer_balance(
  p_customer_id INT,
  p_effective_date TIMESTAMP(0)) RETURNS DECIMAL(5,2)
AS $$
  -- OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
  -- THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
  --   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
  --   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
  --   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
  --   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
DECLARE
  v_rentfees DECIMAL(5,2); -- FEES PAID TO RENT THE VIDEOS INITIALLY
  v_overfees INT;          -- LATE FEES FOR PRIOR RENTALS
  v_payments DECIMAL(5,2); -- SUM OF PAYMENTS MADE PREVIOUSLY
BEGIN

  SELECT 
    IFNULL(SUM(film.rental_rate),0) 
  INTO 
    v_rentfees
  FROM 
    film, inventory, rental
  WHERE 
    film.film_id = inventory.film_id AND 
	inventory.inventory_id = rental.inventory_id AND 
	rental.rental_date <= p_effective_date AND 
	rental.customer_id = p_customer_id;

  SELECT 
    IFNULL(SUM(CASE WHEN (TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) > film.rental_duration THEN
      ((TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) - film.rental_duration) ELSE 0 END),0) 
  INTO 
    v_overfees
  FROM 
    rental, inventory, film
  WHERE 
    film.film_id = inventory.film_id AND 
	inventory.inventory_id = rental.inventory_id AND 
	rental.rental_date <= p_effective_date AND 
	rental.customer_id = p_customer_id;

  SELECT 
    IFNULL(SUM(payment.amount),0) 
  INTO 
    v_payments
  FROM 
    payment
  WHERE 
    payment.payment_date <= p_effective_date AND 
	payment.customer_id = p_customer_id;

  RETURN v_rentfees + v_overfees - v_payments;

END;
$$ LANGUAGE plpgsql;


CREATE PROCEDURE film_in_stock(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT, cur REFCURSOR)
AS $$
BEGIN

  OPEN 
    cur FOR SELECT inventory_id
  FROM 
    inventory
  WHERE 
    film_id = p_film_id AND 
	store_id = p_store_id AND 
	inventory_in_stock(inventory_id);

  SELECT 
    COUNT(*)
  FROM 
    inventory
  WHERE 
    film_id = p_film_id AND 
	store_id = p_store_id AND 
	inventory_in_stock(inventory_id)
  INTO 
    p_film_count;

END;
$$ LANGUAGE plpgsql;


CREATE PROCEDURE film_not_in_stock(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT, cur REFCURSOR)
AS $$
BEGIN

  OPEN 
    cur FOR SELECT inventory_id
  FROM 
    inventory
  WHERE 
    film_id = p_film_id AND 
	store_id = p_store_id AND 
	NOT inventory_in_stock(inventory_id);

  SELECT 
    COUNT(*)
  FROM 
    inventory
  WHERE 
    film_id = p_film_id AND 
	store_id = p_store_id AND 
	NOT inventory_in_stock(inventory_id)
  INTO 
    p_film_count;

END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION inventory_held_by_customer(p_inventory_id INT) RETURNS INT
AS $$
DECLARE
  v_customer_id INT;
BEGIN

  SELECT 
    customer_id 
  INTO 
    v_customer_id
  FROM 
    rental
  WHERE 
    return_date IS NULL AND inventory_id = p_inventory_id;

  RETURN v_customer_id;

END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION inventory_in_stock(p_inventory_id INT) RETURNS BOOLEAN
AS $$
DECLARE
  v_rentals INT;
  v_out     INT;
BEGIN

  -- AN ITEM IS IN-STOCK IF THERE ARE EITHER NO ROWS IN THE rental TABLE
  -- FOR THE ITEM OR ALL ROWS HAVE return_date POPULATED

  SELECT 
    COUNT(*) 
  INTO 
    v_rentals    
  FROM 
    rental
  WHERE 
    inventory_id = p_inventory_id;

  IF v_rentals = 0 THEN
    RETURN TRUE;
  END IF;

  SELECT 
    COUNT(rental_id) 
  INTO 
    v_out
  FROM 
    inventory 
  LEFT JOIN 
    rental USING(inventory_id)
  WHERE 
    inventory.inventory_id = p_inventory_id AND rental.return_date IS NULL;

  IF v_out > 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

END;
$$ LANGUAGE plpgsql;