		#Question Set 1 - Easy
	#Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC LIMIT 1;


	#Which countries have the most Invoices?

SELECT COUNT(*) AS total_invoices, billing_country FROM invoice
GROUP BY billing_country ORDER BY total_invoices ASC;


	#What are top 3 values of total invoice?

SELECT * FROM invoice 
ORDER BY total DESC LIMIT 3;


	/*Which city has the best customers? We would like to throw a promotional Music Festival in the city 
we made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/

SELECT billing_city, sum(total) AS invoice_tot FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC LIMIT 1;

	
	/*Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money*/

SELECT customer.customer_id, concat(first_name," ", last_name) AS name, SUM(invoice.total) as total FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC LIMIT 1;



		#Question Set 2 - Moderate
	/*Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A*/

SELECT DISTINCT 
	c.email,
   c.first_name,
   c.last_name,
   g.name AS genre
	
	FROM customer AS c
	
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS t ON il.track_id = t.track_id
JOIN genre AS g ON t.genre_id = g.genre_id

WHERE g.name = 'Rock'
ORDER BY c.email ASC
;

	/*Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands*/
SELECT 
   ar.name AS artist_name,
   COUNT(t.track_id) AS rock_track_count
   
FROM artist AS ar

JOIN album AS al ON ar.artist_id = al.artist_id
JOIN track AS t ON al.album_id = t.album_id
JOIN genre AS g ON t.genre_id = g.genre_id

WHERE g.name = 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY rock_track_count DESC
LIMIT 10;


	/*Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first*/

SELECT NAME, milliseconds from track 
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track) 
ORDER BY  milliseconds DESC ;

		#Question SET 3 - Advance
	#Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT
	c.customer_id, 
   CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
   ar.name AS artist_name,
   SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id

GROUP BY c.customer_id, ar.artist_id
ORDER BY total_spent DESC;

	#We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

WITH GenrePerCountry AS (
	SELECT c.country, g.name AS genre_name, COUNT(*) AS purchase_count
	FROM invoice i
    
	JOIN customer c ON i.customer_id = c.customer_id
   JOIN invoice_line il ON il.invoice_id = i.invoice_id
   JOIN track t ON t.track_id = il.track_id
   JOIN genre g ON g.genre_id = t.genre_id
   
   GROUP BY c.country, g.name
),

RankedGenre AS (
	SELECT *, RANK() OVER (PARTITION BY country ORDER BY purchase_count DESC) AS rank_in_country
	FROM GenrePerCountry
)

SELECT * FROM RankedGenre WHERE rank_in_country = 1
ORDER BY country ASC;


	#Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

WITH CustomerSpending AS (
   SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) AS total_spending
   FROM customer c
   JOIN invoice i ON c.customer_id = i.customer_id
    
   GROUP BY 
      c.customer_id,
      c.first_name,
      c.last_name,
      i.billing_country
),

RankedCustomers AS (
   SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY total_spending DESC) AS row_num
   FROM CustomerSpending
)

SELECT customer_id, first_name, last_name, billing_country, total_spending
FROM RankedCustomers
WHERE row_num = 1;

