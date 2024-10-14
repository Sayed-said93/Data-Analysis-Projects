 
--Which countries have the most Invoices?

select billing_country ,count(*) num_of_Invoices
from invoice
group by billing_country
order by num_of_Invoices desc

--Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money

select  billing_city,SUM(total) as InvoiceTotal
from invoice
group by billing_city
order by InvoiceTotal desc
limit 1

--Who is the best customer? The customer who has spent the most money

select  c.customer_id, first_name, last_name, SUM(total) as total_spending
from customer c inner join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by total_spending desc
limit 1;


/*Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A*/


select distinct email,first_name, last_name
from customer c inner join invoice i
on c.customer_id = i.customer_id inner join invoice_line l
on i.invoice_id = l.invoice_id
where track_id in(
	select track_id from track t inner join genre g
	on t.genre_id = g.genre_id
	where g.name like 'Rock'
)
order by  email


--Write a query that returns the Artist name and total track count of the top 10 rock bands


select r.artist_id ,r.name,COUNT(r.artist_id) as number_of_songs
from track  t  inner join album  a
on a.album_id = t.album_id inner join  artist  r
on r.artist_id = a.artist_id inner join genre  g
on g.genre_id = t.genre_id
where g.name like 'Rock'
group by r.artist_id 
order by number_of_songs desc
limit 10


--Return all the track names that have a song length longer than the average song length


select name,milliseconds
from track
where milliseconds > (
	select AVG(milliseconds) as avg_track_length
	from track )
order by  milliseconds desc


--Find how much amount spent by each customer on artists


with best_selling_artist as (
	select r.artist_id as artist_id, r.name as artist_name, SUM(l.unit_price*l.quantity) as total_sales
	from invoice_line l inner join track t 
	on t.track_id = l.track_id inner join album a 
	on a.album_id = t.album_id inner join artist r 
	on r.artist_id = a.artist_id
	group by r.artist_id
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) as amount_spent
from invoice i inner join customer c 
on c.customer_id = i.customer_id inner join invoice_line il 
on il.invoice_id = i.invoice_id inner join track t 
on t.track_id = il.track_id inner join album alb 
on alb.album_id = t.album_id inner join best_selling_artist bsa 
on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by amount_spent desc



/* We want to find out the most popular music Genre for each country.We determine the most popular genre as the genre  with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
 the maximum number of purchases is shared return all Genres */


with popular_genre as 
(
    select COUNT(l.quantity) as purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(partition by c.country order by COUNT(l.quantity) desc) as RowNo 
    from invoice_line l
	inner join invoice  i on i.invoice_id = l.invoice_id
	inner join customer c on c.customer_id = i.customer_id
	inner join track t on t.track_id = l.track_id
	inner join genre g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1



/*Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with Customter_with_country as (
		select c.customer_id,first_name,last_name,billing_country,SUM(total) as total_spending,
	    ROW_NUMBER() OVER(partition by billing_country order by SUM(total) desc) as RowNo 
		from invoice i inner join customer  c 
		on c.customer_id = i.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from Customter_with_country where RowNo <= 1





