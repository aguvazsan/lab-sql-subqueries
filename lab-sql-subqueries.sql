# Lab | SQL Subqueries

-- In this lab, you will be using the [Sakila](https://dev.mysql.com/doc/sakila/en/) database of movie rentals. Create appropriate joins wherever necessary. 

USE sakila;

### Instructions

-- 1. How many copies of the film _Hunchback Impossible_ exist in the inventory system?


-- SELECT film_id, title, COUNT(film_id);

SELECT film_id, COUNT(inventory_id) 
FROM sakila.inventory
WHERE film_id IN (
    SELECT film_id 
    FROM film 
    WHERE title = "Hunchback Impossible"
)
GROUP BY film_id;

SELECT * FROM film;

SELECT * FROM inventory;


-- 2. List all films whose length is longer than the average of all the films.

SELECT *
FROM film
HAVING length > (SELECT AVG(length) 
FROM (
    SELECT *
    FROM sakila.film
    GROUP BY film_id
) subtrans)
ORDER BY length;

-- 3. Use subqueries to display all actors who appear in the film _Alone Trip_.

SELECT *
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id = (
		SELECT film_id 
		FROM film
		WHERE title = 'Alone Trip')) ;

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT * 
FROM film
WHERE film_id IN (
	SELECT film_id 
	FROM film_category
	WHERE category_id =
		(SELECT category_id
		FROM category
		WHERE name = 'family'));

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

SELECT * 
FROM customer
	WHERE address_id IN (
	SELECT address_id
		FROM address
		WHERE city_id IN (
		SELECT city_id
			FROM city
			WHERE country_id = (
				SELECT country_id
					FROM country
					WHERE country = 'canada')));

SELECT *
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city cy ON a.city_id = cy.city_id
JOIN country co ON cy.country_id = co.country_id
WHERE co.country = 'Canada';
                
-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- Peliculas en las que actuó
SELECT *
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_actor
	WHERE actor_id = (
		SELECT actor_id
		FROM film_actor
		GROUP BY actor_id
		ORDER BY COUNT(film_id) DESC
		LIMIT 1));

-- Quien es la actriz
SELECT * 
FROM actor
WHERE actor_id = (
	SELECT actor_id
	FROM film_actor
	GROUP BY actor_id
	ORDER BY COUNT(film_id) DESC
	LIMIT 1);

-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT * 
FROM film
WHERE film_id IN (
SELECT film_id
FROM inventory
WHERE inventory_id IN (
	SELECT inventory_id
	FROM  rental
		WHERE rental_id IN (
		SELECT rental_id
		FROM payment
			WHERE customer_id = (
				SELECT customer_id
				FROM payment
				GROUP BY customer_id
				ORDER BY SUM(amount) DESC
				LIMIT 1))))
ORDER BY film_id;

    
-- 8. Get the `client_id` and the `total_amount_spent` of those clients who spent more than the average of the `total_amount` spent by each client.
            
-- Promedio de Total_Amoun por cliente
SELECT AVG(total_amount)
FROM (
    SELECT customer_id, SUM(amount) AS total_amount
    FROM payment
    GROUP BY customer_id
) sub;


-- Listado de clientes

SELECT customer_id AS cliente, SUM(amount) AS Total_Amount
FROM payment
WHERE customer_id IN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) > (
        SELECT AVG(total_amount)
        FROM (
            SELECT customer_id, SUM(amount) AS total_amount
            FROM payment
            GROUP BY customer_id
        ) sq
    )
)
GROUP BY customer_id
ORDER BY Total_Amount;



