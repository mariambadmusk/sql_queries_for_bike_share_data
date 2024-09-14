/*Import data files
set the data type to be consistent across all files and columns
join the data files
perform descriptive analysis*/


---1. Inspect the column_names and datatypes of each table

---2. Join all tables usuing UNION ALL

SELECT *
INTO all_trips
FROM 
(
SELECT *
FROM [divvy_trips].[dbo].[2021_06_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2021_07_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2021_08_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2021_09_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2021_10_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2021_11_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2021_12_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2022_01_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2022_01_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2022_02_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2022_03_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2022_04_divvy_tripdata]
UNION ALL

SELECT *
FROM [divvy_trips].[dbo].[2022_05_divvy_tripdata]

) a;


---2.Edit column names and datatypes  

ALTER TABLE divvy_trips.dbo.all_trips
ALTER COLUMN started_at datetime;

ALTER TABLE divvy_trips.dbo.all_trips
ALTER COLUMN ended_at datetime;

ALTER TABLE divvy_trips.dbo.all_trips
ALTER COLUMN start_lat real;

ALTER TABLE divvy_trips.dbo.all_trips
ALTER COLUMN start_lng real;

ALTER TABLE divvy_trips.dbo.all_trips
ALTER COLUMN end_lat real;

ALTER TABLE divvy_trips.dbo.all_trips
ALTER COLUMN end_lng real;


---3. create a new table with new columns specifiying the trip duration between started at and ended at; and also extracting the day, month and year  

SELECT ride_id, rideable_type
			  ,started_at
			  ,ended_at
			  ,start_station_name
			  ,start_station_id
			  ,end_station_name
			  ,end_station_id
			  ,start_lat
			  ,start_lng
			  ,end_lat
			  ,end_lng
			  ,member_casual 
			  ,DATEDIFF(second, started_at, ended_at) AS 'trip_duration' 
			  ,DATENAME(weekday, started_at) as 'day_of_week'
			  ,DATEPART(DAY, started_at) AS 'week_day'
			  ,DATEPART(month, started_at) AS 'month'
			  ,DATEPART(year, started_at) AS 'year'

INTO all_trips_1

FROM divvy_trips.dbo.all_trips;


---3. Check if there are rows where ended_at(time) are less than started_at (time)

SELECT trip_duration, started_at, ended_at

FROM divvy_trips.dbo.all_trips_1

WHERE ended_at < started_at; 


---4. Delete records where ended_at is less than started_at to avoid errors 

DELETE

FROM divvy_trips.dbo.all_trips_1

WHERE ended_at < started_at;



---5. Determine the shortest duration, longest ride and average ride for members and casual users

SELECT member_casual, MIN(trip_duration) as min_ride
	 ,max(trip_duration) as max_ride
	 ,AVG(CAST(trip_duration AS FLOAT)) AS avg_ride

FROM divvy_trips.dbo.all_trips_1
	
GROUP BY member_casual;


---6. Calculate the average trip_duration for users by day_of_week.

SELECT member_casual, day_of_week
		,AVG(CAST(trip_duration AS FLOAT)) AS avg_ride

FROM divvy_trips.dbo.all_trips_1

GROUP BY member_casual, day_of_week

ORDER BY member_casual;


---7. Calculate the frequency of trips for members and casual users for each day of the week

SELECT member_casual, day_of_week, 
	count(day_of_week) as freq_trips

	FROM divvy_trips.dbo.all_trips_1

	GROUP BY member_casual, day_of_week
	
	ORDER BY member_casual, freq_trips DESC; 


---8.Total rides for casual users and members

SELECT member_casual, count(ride_id) as total_ride

FROM divvy_trips.dbo.all_trips_1

GROUP BY member_casual;


---9. popular start station; for members and casual users and look at the type of rides; I wrapped the query rank CTE to be able to filter it WITH

WITH popular_strstation AS
	(SELECT member_casual,start_lat, start_lng,  start_station_name, count (start_station_name) as total,
	RANK () over (partition by member_casual ORDER BY count (start_station_name) DESC) as rankresult

	FROM divvy_trips.dbo.all_trips_1

	GROUP BY member_casual, start_station_name, start_lat, start_lng
	)

SELECT *
FROM popular_strstation
WHERE rankresult <= 30;


--popular end station; for members and casual users and look at the type of rides;
WITH popular_endstation AS
	(SELECT member_casual, end_station_name, count (end_station_name) as total,
		RANK () over (partition by member_casual ORDER BY count (end_station_name) DESC) as rankresult ---ranking the result from the count by the rows in  member_casual, ordering by count

	FROM divvy_trips.dbo.all_trips_1

	GROUP BY member_casual, end_station_name

	)

SELECT *
FROM popular_endstation
WHERE rankresult <= 6;            ---to limit the result of the count


---Determine the peak hours for casuals and members

WITH phs AS

		(SELECT  member_casual, DATEPART(HOUR, started_at) as time_stamp

			FROM divvy_trips.dbo.all_trips_1),	
peak AS
(SELECT member_casual, time_stamp, count(time_stamp) as ct_time

	FROM phs
	GROUP BY time_stamp, member_casual)

SELECT *, RANK () OVER (PARTITION BY member_casual ORDER BY time_stamp ASC) as rankresult

FROM peak;


---cross reference staion names in common with both users = 973 results

WITH a AS

		(SELECT member_casual, start_station_name, count(ride_id) as acount
		FROM divvy_trips.dbo.all_trips_1
		WHERE  member_casual = 'casual'
		GROUP BY start_station_name, member_casual),

b  AS

		(SELECT member_casual, start_station_name, count(ride_id) as bcount
		FROM divvy_trips.dbo.all_trips_1
		WHERE  member_casual = 'member'
		GROUP BY start_station_name, member_casual)

SELECT DISTINCT a.start_station_name, a.member_casual, a.acount, b.start_station_name, b.member_casual, b.bcount
FROM a, b
WHERE a.start_station_name  =  b.start_station_name
	AND a.acount <= 3000
		AND b.bcount <= 3000

	
ORDER BY b.bcount DESC;



---Number of stations =1106 stations

SELECT DISTINCT start_station_name
		
FROM divvy_trips.dbo.all_trips_1

WHERE start_station_name IS NOT NULL;


SELECT member_casual, count(member_casual) as bcount
		FROM divvy_trips.dbo.all_trips_1

		GROUP BY  member_casual
	

---preference of bikes amongst users

SELECT rideable_type, count(rideable_type) as r_bikes, member_casual
		
FROM divvy_trips.dbo.all_trips_1

GROUP BY member_casual, rideable_type

ORDER BY member_casual




---Standard Deviation for Casual Users

SELECT member_casual, STDEV(CAST(trip_duration AS FLOAT)) AS stdev

FROM divvy_trips.dbo.all_trips_1

GROUP BY member_casual


---Grouping Trips by Season

WITH season_trip as

	(SELECT member_casual, count(month) as  sum_trip, CASE 
		WHEN month = 6 THEN 'summer'
		WHEN month =  7  THEN 'summer'
		WHEN month = 8 THEN 'summer'
		WHEN month = 9 THEN 'autumn'
		WHEN month = 10  THEN 'autumn'
		WHEN month = 11 THEN 'autumn'
		WHEN month = 12 THEN 'winter'
		WHEN month = 1 THEN 'winter'
		WHEN month = 2 THEN 'winter'
		WHEN month = 3 THEN 'spring'
		WHEN month = 4 THEN 'spring'
		WHEN month = 5 THEN 'spring'
		ELSE 'na'
		END AS season

	FROM divvy_trips.dbo.all_trips_1
	GROUP BY month, member_casual)

SELECT member_casual, sum(sum_trip) as sum_trips, season

FROM season_trip

GROUP BY member_casual, season
ORDER BY member_casual;


---Grouping Trips by Season and then calculating the average ride per season
WITH season_trip as

	(SELECT AVG(CAST(trip_duration AS FLOAT)) AS avg_ride, member_casual, CASE 
		WHEN month = 6 THEN 'summer'
		WHEN month =  7  THEN 'summer'
		WHEN month = 8 THEN 'summer'
		WHEN month = 9 THEN 'autumn'
		WHEN month = 10  THEN 'autumn'
		WHEN month = 11 THEN 'autumn'
		WHEN month = 12 THEN 'winter'
		WHEN month = 1 THEN 'winter'
		WHEN month = 2 THEN 'winter'
		WHEN month = 3 THEN 'spring'
		WHEN month = 4 THEN 'spring'
		WHEN month = 5 THEN 'spring'
		ELSE 'na'
		END AS season

	FROM divvy_trips.dbo.all_trips_1
	GROUP BY month, member_casual)

SELECT member_casual, season, sum(avg_ride) as sum_avg

FROM season_trip

GROUP BY  season, member_casual
ORDER BY member_casual;



---Calculating the number of trips for each day of the weke and grouping accordinto members and casuals

SELECT day_of_week, member_casual, count(member_casual) as sum_trips

FROM divvy_trips.dbo.all_trips_1

GROUP BY member_casual, day_of_week
ORDER BY member_casual ASC;














