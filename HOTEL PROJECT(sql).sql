CREATE DATABASE hotel;
USE hotel;
SELECT*FROM hotel_bookings;
describe hotel_bookings;

-- What is the total number of reservations in the dataset?
SELECT COUNT(*) AS total_reservations
FROM hotel_bookings;

-- Which meal plan is the most popular among guests?
SELECT type_of_meal_plan, COUNT(*) AS popular_mealplan 
FROM hotel_bookings
GROUP BY type_of_meal_plan
ORDER BY popular_mealplan DESC
LIMIT 1;

-- What is the average price per room for reservations involving children?
SELECT ROUND(AVG(avg_price_per_room),2) AS average_price 
FROM hotel_bookings
WHERE no_of_children > 0;

-- How many reservations were made for the year 20XX (replace XX with the desired year)? = 2018
-- AS THE DATE IS STORED AS TEXT/STRING-CHANGING IT TO DATE TO FETCH THE YEAR EASILY
SET SQL_SAFE_UPDATES =0;

update hotel_bookings
SET arrival_date= STR_TO_DATE(arrival_date,'%d-%m-%Y')
WHERE arrival_date IS NOT NULL;

SET SQL_SAFE_UPDATES =1;

ALTER TABLE hotel_bookings MODIFY column arrival_date DATE;

SELECT COUNT(*) AS year_reservations
FROM hotel_bookings
WHERE YEAR(arrival_date) = 2018;

-- What is the most commonly booked room type?
SELECT room_type_reserved, COUNT(*) AS common_type
FROM hotel_bookings
GROUP BY room_type_reserved
ORDER BY common_type DESC
LIMIT 1;

-- How many reservations fall on a weekend (no_of_weekend_nights > 0)?
SELECT COUNT(*) AS weekend
FROM hotel_bookings
WHERE no_of_weekend_nights>0;

-- What is the highest and lowest lead time for reservations?
SELECT MAX(lead_time) AS Highest_lead_time, MIN(lead_time) AS lowest_lead_time
FROM hotel_bookings;

-- What is the most common market segment type for reservations?
SELECT market_segment_type, COUNT(*) AS common_MarketSegment
FROM hotel_bookings
GROUP BY market_segment_type
ORDER BY common_MarketSegment DESC
LIMIT 1;

-- How many reservations have a booking status of "Confirmed"?
SELECT COUNT(*) AS confirmed_status
FROM hotel_bookings
WHERE booking_status !='Canceled';

--  What is the total number of adults and children across all reservations?
SELECT SUM(no_of_adults) AS adults, SUM(no_of_children) AS children,
SUM(no_of_adults + no_of_children) AS Total
FROM hotel_bookings;

-- Rank room types by average price within each market segment.
SELECT market_segment_type, room_type_reserved, average_Price,
RANK() OVER(PARTITION BY market_segment_type ORDER BY average_Price DESC) AS rank_segment 
FROM(
SELECT market_segment_type, room_type_reserved, AVG(avg_price_per_room) AS average_Price
FROM hotel_bookings
GROUP BY market_segment_type, room_type_reserved
) AS derived_table;

-- Find the top 2 most frequently booked room types per market segment
WITH ranked_rooms AS (
  SELECT 
    market_segment_type,
    room_type_reserved,
    COUNT(*) AS bookings_count,
    RANK() OVER (
      PARTITION BY market_segment_type 
      ORDER BY COUNT(*) DESC
    ) AS room_rank
  FROM hotel_bookings
  GROUP BY market_segment_type, room_type_reserved
)
SELECT *
FROM ranked_rooms
WHERE room_rank <= 2
ORDER BY market_segment_type, room_rank;


-- . What is the average number of nights (both weekend and weekday) spent by guests for each room type?
SELECT room_type_reserved,
ROUND(AVG(no_of_weekend_nights),2) AS weekend,
ROUND(AVG(no_of_week_nights),2) AS week, 
ROUND(AVG(no_of_weekend_nights+no_of_week_nights),2) AS Together
FROM hotel_bookings
GROUP BY room_type_reserved;

-- For reservations involving children, what is the most common room type, and what is the average price for that room type?
SELECT room_type_reserved, COUNT(*) AS booking_rooms, ROUND(AVG(avg_price_per_room),2) AS avg_price
FROM hotel_bookings
WHERE no_of_children != 0
GROUP BY room_type_reserved
ORDER BY booking_rooms DESC
LIMIT 1;

-- Find the market segment type that generates the highest average price per room
SELECT market_segment_type, ROUND(AVG(avg_price_per_room),2) AS averagePrice
FROM hotel_bookings
GROUP BY market_segment_type
ORDER BY averagePrice DESC
LIMIT 1;
