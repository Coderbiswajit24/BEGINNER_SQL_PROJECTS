-- Music Store Analysis Project
-- Basic level SQL query questions and answers
-- (1). Write a SQL query to find who is the senior most employee based job title.
select 
    *
from employee
    order by levels desc
limit 1;

-- (2). Write a SQL query to find out which countries have most invoices

select * from invoice;

select
    billing_country,
	count(invoice_id) as total_number_of_invoices
from invoice
    group by billing_country
	    order by total_number_of_invoices desc;

-- (3). Write a SQL query to find only three countries which have most invoices

select
    billing_country,
	count(invoice_id) as total_number_of_invoices
from invoice
    group by billing_country
	    order by total_number_of_invoices desc
		     limit 3;
/* (4). Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a SQL query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */	
select
   billing_city,
   sum(total) as invoice_total
from invoice
    group by billing_city
	     order by invoice_total desc 
		     limit 1;
-- Another part of this quuestion returns all cities and sum of invoice total
select
   billing_city,
   ROUND(CAST(sum(total)AS INT),2) as invoice_total
from invoice
    group by billing_city
	     order by invoice_total desc;

/* Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a SQL query that returns the person who has spent the 
most money */

select * from customer;
select * from invoice;
select
    c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	sum(i.total) as total_money_spent
from customer as c
    inner join invoice as i on c.customer_id = i.customer_id
	     group by c.customer_id
		     order by total_money_spent desc
		     limit 1;
select * from genre;
-- Write s SQL query to find artist name,artist_id who/whom singing Rock and Roll,Pop,Opera,Drama genre type album and their total album count.
select * from artist;
select * from genre;
(select
    t1.artist_id,
	t1.name,
	count(t2.album_id) as total_number_of_albums,
	'Rock And Roll' as genre_name
from artist as t1
    inner join album as t2 on t1.artist_id = t2.artist_id
	     inner join track as t3 on t2.album_id = t3.album_id
		      inner join genre as t4 on t3.genre_id = t4.genre_id
	where t4.name = 'Rock And Roll'
	    group by t1.artist_id
		    order by t1.artist_id asc )
union all
(select
    t1.artist_id,
	t1.name,
	count(t2.album_id) as total_number_of_albums,
	'Pop' as genre_name
from artist as t1
    inner join album as t2 on t1.artist_id = t2.artist_id
	     inner join track as t3 on t2.album_id = t3.album_id
		      inner join genre as t4 on t3.genre_id = t4.genre_id
	where t4.name = 'Pop'
	     group by t1.artist_id
		    order by t1.artist_id asc)
union all
(select
    t1.artist_id,
	t1.name,
	count(t2.album_id) as total_number_of_albums,
	'Drama' as genre_name
from artist as t1
    inner join album as t2 on t1.artist_id = t2.artist_id
	     inner join track as t3 on t2.album_id = t3.album_id
		      inner join genre as t4 on t3.genre_id = t4.genre_id
	where t4.name = 'Drama'
	     group by t1.artist_id
		    order by t1.artist_id asc)

union all
(select
    t1.artist_id,
	t1.name,
	count(t2.album_id) as total_number_of_albums,
	'Opera' as genre_name
from artist as t1
    inner join album as t2 on t1.artist_id = t2.artist_id
	     inner join track as t3 on t2.album_id = t3.album_id
		      inner join genre as t4 on t3.genre_id = t4.genre_id
	where t4.name = 'Opera'
	    group by t1.artist_id
		    order by t1.artist_id asc);

-- Intermediate Level SQL query Questions and Answers	

/*
Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A 
*/

select
    distinct c.email,
	c.first_name,
	c.last_name
from customer as c
inner join invoice as i on c.customer_id = i.customer_id
inner join invoice_line as il on i.invoice_id = il.invoice_id
inner join track as t on il.track_id = t.track_id
where t.genre_id in (
					 select 
						 genre_id
					 from genre 
					      where name = 'Rock') and lower(c.email) like 'a%'
 order by c.email asc;	

/*
Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands 
*/

select
   a.name,
   sum(t1.track_id) as total_track_count
from artist as a
    inner join album as t on a.artist_id = t.artist_id
	    inner join track as t1 on t.album_id = t1.album_id
		     where t1.genre_id in (select genre_id from genre where name = 'Rock')
group by a.name
    order by total_track_count desc
	    limit 10;

/*
Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first
*/
select * from track;
select
    name,
	milliseconds
from track 
    where milliseconds > (select avg(milliseconds) as avg_track_length from track)
	  order by milliseconds desc;
	  
-- Advanced level SQL query questions and answers

/*
Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent
*/
select
    c.customer_id,
    c.first_name||' '||c.last_name as customer_full_name,
	a.name as artist_name,
	sum(il.unit_price * il.quantity) as total_amount_spent
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id 
join album as al on t.album_id = al.album_id
join artist as a on al.artist_id = a.artist_id
group by c.customer_id, c.first_name||' '||c.last_name, a.name
    order by customer_full_name, artist_name ,total_amount_spent desc;

/*
We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres
*/

with most_popular_genre(genre_name, highest_amount_purchases) as (
select
      g.name as genre_name,
	  sum(il.quantity) as highest_amount_purchases
from genre as g
join track as t on g.genre_id = t.genre_id 
join invoice_line as il on t.track_id = il.track_id
   group by g.name
        having sum(il.quantity) > 100
             order by highest_amount_purchases desc
)
select
    i.billing_country,
	g.name as top_genre_name
from invoice as i
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id
join genre as g on t.genre_id = g.genre_id 
   group by i.billing_country, g.name
       having sum(il.quantity) in (select highest_amount_purchases from most_popular_genre)
	         order by i.billing_country asc;

  

   
	
	
	    