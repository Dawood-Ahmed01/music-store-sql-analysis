						--Level 1
--1.Who is the senior most employee based on job title?
select
	employee_id,
	first_name,
	last_name,
	title,
	hire_date
from employee
where hire_date = (select min(hire_date) from employee)

--2. Which countries have the most Invoices?
select
	billing_country as country,
	count(*) as invoices
from invoice
group by 1
order by invoices desc


--3. What are top 3 values of total invoice?
select * from invoice
order by total desc
limit 3

--4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals
select
	billing_city as city,
	sum(total) as total_invoice
from invoice
group by 1
order by total_invoice desc
limit 1

--5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money
select
	i.customer_id,
	c.first_name,
	c.last_name,
	sum(i.total) as total_spent
from invoice i
join customer c on c.customer_id = i.customer_id
group by 1 ,2 ,3
order by total_spent desc
limit 1

							--Level 2
--1. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A
select
	c.first_name,
	c.last_name,
	c.email,
	g.name as genre
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
WHERE g.name = 'Rock'
group by 1, 2, 3 , 4
order by c.email asc

--2. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands
select
	a.artist_id,
	a.name as artist_name,
	g.name as genre,
	count(t.*) as total_track
from artist a
join album aa on a.artist_id = aa.artist_id
join track t on t.album_id = aa.album_id 
join genre g on g.genre_id = t.genre_id
where g.name = 'Rock'
group by 1 , 2 ,3
order by total_track desc
limit 10

--3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first
select 
	t.name as track_name,
	milliseconds
from track t
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc

								--Level 3

--1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
select
	c.first_name,
	c.last_name,
	aa.name as artist_name,
	round(sum(il.quantity * il.unit_price)::numeric , 2) as total_spent
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album a on a.album_id = t.album_id
join artist aa on aa.artist_id = a.artist_id
group by 1 , 2 , 3 
order by total_spent desc

--2. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres
with ranking as (
select
	i.billing_country as country ,
	g.name as genre,
	count(il.quantity) as total_purchases,
	rank() over (partition by i.billing_country order by sum(il.quantity) desc) as ranking
from invoice i
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by 1 , 2
)
select 
	country,
	genre , 
	total_purchases
from ranking
where ranking = 1
order by ranking asc

--3. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount
with ranking as (
select 
	c.first_name as first_name,
	c.last_name as last_name,
	i.billing_country as country,
	sum(i.total) as total_spent,
	rank() over (partition by i.billing_country order by sum(i.total) desc) as ranking
from customer c
join invoice i on i.customer_id = c.customer_id
group by 1 , 2, 3
)
select 
	country ,
	first_name,
	last_name,
	round(total_spent:: numeric , 2) as total_spent
from ranking
where ranking = 1
order by ranking asc