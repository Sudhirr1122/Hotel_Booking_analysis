1.Write a query to fetch Identify customers who have made multiple bookings and have canceled at least one of them. The result should have customer_name, total_bookings, total_prev_cancellations and a flag named “has_canceled_booking” which has Yes / No stating the outcome.

SELECT 
    name, 
    COUNT(*) AS total_bookings, 
    CASE
        WHEN previous_cancellations <> 0 AND is_repeated_guest = 1 THEN 'Yes'
        ELSE 'No'
    END AS has_canceled_booking
FROM 
    hotel_booking
GROUP BY 
    1, previous_cancellations, is_repeated_guest;



2.Write a query to fetch for each hotel and deposit_type, the average no of adults in them, total_booking_made and the percentage of bookings where the number of adults exceeds the average number of adults in the dataset.

WITH my_cte AS (
    SELECT 
        hotel,
        deposit_type,
        AVG(adults) AS avg_adults,
        CASE 
            WHEN adults > AVG(adults) THEN 1 
            ELSE 0 
        END AS adults_exceeds
    FROM 
        hotel_booking
    GROUP BY 
        1, 2, adults
)
SELECT 
    hotel,
    deposit_type,
    AVG(avg_adults) AS overall_avg_adults,
    COUNT(*) AS total_bookings,
    (SUM(adults_exceeds) / (SELECT COUNT(*) FROM hotel_booking)) * 100 AS percentage_of_adults_exceeds 
FROM 
    my_cte
GROUP BY 
    1, 2;


3.Write a query to Rank customers based on the lead time for their bookings, considering only those with the same number of adults. Display the customer name, lead time, and their rank within each group.

SELECT 
    adults, 
    name, 
    lead_time, 
    RANK() OVER(PARTITION BY adults ORDER BY lead_time) AS rank
FROM 
    hotel_booking;


4.Write a query to Calculate the average daily rate (adr) for each month, considering the previous months average daily rate using the LAG window function.

WITH my_cte AS (
    SELECT 
        arrival_date_month AS month,
        ROUND(AVG(adr), 2) AS AVG_ADR
    FROM 
        hotel_booking
    GROUP BY 
        1
)
SELECT 
    MONTH,
    AVG_ADR,
    LAG(AVG_ADR, 1, 0) OVER () AS lag
FROM 
    my_cte;

5.Write a query to Assign a percentile rank to each booking based on the lead time, categorized into quartiles. The output should have hotel, lead_time and lead_time_ntile_rank.

WITH my_cte AS (
    SELECT 
        hotel, 
        lead_time, 
        NTILE(4) OVER (PARTITION BY lead_time) AS lead_time_quartile
    FROM 
        hotel_booking
)
SELECT 
    hotel, 
    lead_time, 
    NTILE(100) OVER (PARTITION BY lead_time_quartile) AS lead_time_ntile_rank
FROM 
    my_cte;


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

SELECT 
    name,
    total_of_special_requests
FROM 
    hotel_booking
WHERE 
    total_of_special_requests > (SELECT total_of_special_requests FROM hotel_booking WHERE name = 'Ernest Barnes')
    AND reservation_status = (SELECT reservation_status FROM hotel_booking WHERE name = 'Ernest Barnes');

















