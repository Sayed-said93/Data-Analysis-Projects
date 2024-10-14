--1.Rank users according to the number of distinct songs they played.
--  If two users shared the same counts, they should have the same rank

select userid,count(distinct song) as number_of_song,rank() over(order by count(distinct song) desc) as ranking
from songs_events
group by 1


--2.Rank users according to the number of distinct songs they played. 
--  If two users shared the same counts, each user should have his/her own number.

select userid,count(distinct song) as number_of_song,row_number() over(order by count(distinct song) desc) as ranking
from songs_events
group by 1


--3.Find the next song a user listened to during the session
--   PS: for the last song in the session print "No Next" 

select userid,sessionid,song,lead(song,1,'No_Next') over(partition by sessionid  order by ts) next_song
from songs_events


--4.Select the third highest userid who listened to paid songs

select tt.userid,tt.number_of_song ,tt.row_
from(
     select userid,count(*) as number_of_song,dense_rank() over (order by count(*) desc) as row_
     from songs_events
	 where level='paid'
	  group by 1
	 ) tt
where tt.row_=3 


--5.Select the user, session, first song and last song played per session

select distinct  firstname || ' ' || lastname AS full_name ,sessionid,first_value(song) over (partition by sessionid order by ts ) as first_song,last_value(song ) over (partition by sessionid order by ts rows between unbounded preceding and unbounded following  ) as last_song
from songs_events

--6.Select the userId of the longest session duration using time_stamp column

select userid,sessionid,max(period_) as max_period 
from (
   select userid,sessionid,(last_value(ts) over (partition by sessionid order by ts rows between unbounded preceding and unbounded following) - first_value(ts) over (partition by sessionid order by ts )) as period_ 
    from songs_events
     )
group by 1,2
order by  max_period desc
limit 1


--7.For each song in this session Calculate the count of songs that the user played during 2 hours interval (1 hour before and 1 hour after)
--Hint : to convert epoch time to human readable timestamp use  
----timezone(your timezone ex: 'America/New_york' ,  to_timestamp(epoch_time/1000))

select song,sessionid,count(*) over (partition by sessionid order by timezone('America/New_York', to_timestamp(ts / 1000)) range between interval'1'hour preceding and interval'1'hour following)
from songs_events

