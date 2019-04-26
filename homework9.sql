USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b
SELECT UPPER(CONCAT(first_name, " ", last_name))
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor ac
WHERE first_name = "Joe";

--  2b. Find all actors whose last name contain the letters GEN:
SELECT first_name,last_name
FROM actor 
WHERE last_name LIKE  "%gen%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)
FROM actor ac
GROUP BY ac.last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names 
-- that are shared by at least two actors
SELECT last_name, COUNT(*)
FROM actor ac
GROUP BY ac.last_name
HAVING COUNT(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
SELECT *
FROM actor
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

SELECT first_name, last_name
FROM actor
WHERE first_name = 'HARPO'
AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the 
-- correct name after all! In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO'
AND last_name = 'WILLIAMS';

SELECT first_name, last_name
FROM actor
WHERE first_name = 'HARPO'
AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
--  Use the tables staff and address:
SELECT st.first_name, st.last_name, ad.address
FROM staff st
INNER JOIN address ad 
ON st.address_id = ad.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT st.first_name, st.last_name, SUM(pt.amount)
FROM staff st
INNER JOIN payment pt
ON st.staff_id = pt.staff_id
GROUP BY pt.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
-- Use inner join.
SELECT film.title, COUNT(fa.actor_id)
FROM film
INNER JOIN film_actor fa 
ON film.film_id = fa.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(*)
FROM film
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT cus.first_name, cus.last_name, SUM(pt.amount)
FROM customer cus
INNER JOIN payment pt
ON cus.customer_id = pt.customer_id
GROUP BY cus.last_name
ORDER BY cus.last_name;

SELECT * FROM language;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE title LIKE 'k%'
OR title LIKE 'q%'
AND language_id = 1;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor, film_actor fa
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip')
AND actor.actor_id = fa.actor_id;

SELECT * FROM country;
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the 
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer cus
WHERE address_id IN (SELECT address_id 
					FROM address 
					WHERE city_id IN (
									SELECT city_id
                                    FROM city
                                    WHERE country_id IN (
														SELECT country_id
                                                        FROM country
                                                        WHERE country = 'Canada')));



-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title
FROM film 
WHERE film_id IN (
				SELECT film_id
                FROM film_category
                WHERE category_id IN (
									SELECT category_id
                                    FROM category
                                    WHERE name = 'Family'));
                

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(film.film_id) as rent_num
FROM film, rental
WHERE film_id IN (
				SELECT film_id
                FROM inventory
                WHERE inventory_id IN (
									SELECT inventory_id
                                    FROM rental
                                    WHERE inventory.inventory_id = rental.inventory_id))
GROUP BY film.film_id
ORDER BY rent_num DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM( pt.amount)
FROM store, payment pt
WHERE customer_id IN (
					  SELECT customer_id
                      FROM customer 
                      WHERE store_id IN (
										 SELECT store_id
                                         FROM payment pt, customer cus
                                         WHERE  pt.customer_id = cus.customer_id))
                                         GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- SELECT st.store_id, city.city, ct.country
-- FROM store st, city, country ct 
-- WHERE store_id = ( SELECT store_id
-- 					FROM store
--                     WHERE address_id IN (
-- 										SELECT address_id
--                                         FROM address
--                                         WHERE city_id IN (
-- 														 SELECT city_id
--                                                          FROM city
--                                                          WHERE country_id IN (
-- 																			  SELECT ct.country_id, city.country_id
--                                                                               FROM country ct, city
--                                                                               WHERE ct.country_id = city.country_id))));
         
SELECT st.store_id, city.city, ct.country
FROM  store   st, address ad, city,country ct
WHERE st.address_id  = ad.address_id
AND ad.city_id     = city.city_id
AND city.country_id = ct.country_id;
   
   -- 7h. List the top five genres in gross revenue in descending order. 
   -- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT cat.name as Genre, sum(pt.amount) as Gross_revenue
FROM  payment pt, rental rt, inventory inv ,film_category fc ,category cat
WHERE    pt.rental_id = rt.rental_id
AND    rt.inventory_id = inv.inventory_id
AND    inv.film_id      = fc.film_id
AND    fc.category_id = Cat.category_id
GROUP BY cat.name
ORDER BY Gross_revenue DESC
LIMIT  5 ;

--  8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Gross_revenue_genre as 
	(SELECT cat.name as Genre, sum(pt.amount) as Gross_revenue
	FROM   payment pt, rental rt, inventory inv ,film_category fc ,category cat
	WHERE    pt.rental_id = rt.rental_id
	  AND    rt.inventory_id = inv.inventory_id
	  AND    inv.film_id      = fc.film_id
	  AND    fc.category_id = cat.category_id
	GROUP BY cat.name
	ORDER BY Gross_revenue DESC
	LIMIT  5 );
    
    SHOW CREATE VIEW Gross_revenue_genre;
    
    SELECT * FROM Gross_revenue_genre ;
    
    DROP VIEW Gross_revenue_genre;



															



















