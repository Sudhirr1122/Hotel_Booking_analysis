1.Write a query to fetch Identify customers who have made multiple bookings and have canceled at least one of them. The result should have customer_name, total_bookings, total_prev_cancellations and a flag named “has_canceled_booking” which has Yes / No stating the outcome.

select name, count (*) total_bookings, 
case
when previous_cancellations <> 0 and is_repeated_guest = 1 then 'Yes'
else 'no'
end as has_canceled_booking
from hotel_booking
group by 1,previous_cancellations,is_repeated_guest ;


2.Write a query to fetch for each hotel and deposit_type, the average no of adults in them, total_booking_made and the percentage of bookings where the number of adults exceeds the average number of adults in the dataset.

with my_cte as (
SELECT hotel,deposit_type,avg(adults) as avg_adults,
case 
when adults > avg(adults) then 1 else 0 end as adults_exceeds
FROM hotel_booking
group by 1,2,adults
)
select 
hotel,deposit_type, AVG(avg_adults) AS overall_avg_adults,count(*) as total_bookings,
(sum(adults_exceeds)/(select count (*) from hotel_booking))*100 as percentage_of_adults_exceeds 
from my_cte
group by 1,2;

3.Write a query to Rank customers based on the lead time for their bookings, considering only those with the same number of adults. Display the customer name, lead time, and their rank within each group.

select adults,name, lead_time,rank() OVER(PARTITION BY adults order by lead_time) as rank
from hotel_booking;

4.Write a query to Calculate the average daily rate (adr) for each month, considering the previous months average daily rate using the LAG window function.

with my_cte as (
select  arrival_date_month AS month,Round (avg(adr),2) AS AVG_ADR
from hotel_booking
group BY 1
)
SELECT MONTH,AVG_ADR,LAG(AVG_ADR,1,0) OVER () AS lag
FROM my_cte

5.Write a query to Assign a percentile rank to each booking based on the lead time, categorized into quartiles. The output should have hotel, lead_time and lead_time_ntile_rank.

with my_cte as(
select hotel, lead_time, NTILE(4) OVER
         (PARTITION BY lead_time)as  lead_time_quartile
from hotel_booking
)
select hotel, lead_time, NTILE(100) OVER
         (PARTITION BY lead_time_quartile ) as lead_time_ntile_rank
         from my_cte ;
         

6.Write a query to Determine the running total of number of booking changes over time for each hotel, considering only bookings with a lead time greater than the average lead time across all bookings.


WITH my_cte AS (
  SELECT
    hotel,
    lead_time,
    arrival_date_month,
    AVG(lead_time) OVER (PARTITION BY hotel) AS avg_lead_time,
    CASE
      WHEN name IS NOT NULL THEN 1
      ELSE 0
    END AS count_of_booking
  FROM
    hotel_booking
)

SELECT
  hotel,
   arrival_date_month,
  SUM(count_of_booking) OVER (PARTITION BY arrival_date_month ORDER BY lead_time) AS running_total
FROM
  my_cte
WHERE
  lead_time > avg_lead_time;

7.Write a query to Identify the customers who have made bookings with the same reservation status as a customer named 'Ernest Barnes' but have a higher total number of special requests.

select name,total_of_special_requests
from hotel_booking
where 
total_of_special_requests > (select  total_of_special_requests 
from hotel_booking
where name ='Ernest Barnes')
and reservation_status = (select  reservation_status
from hotel_booking
where name ='Ernest Barnes')
















