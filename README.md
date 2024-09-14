### Project Overview

This repository contains SQL queries designed to extract insights from a 12-month dataset of Divvy bike share data. The  focus of these queries is practicing data engineering skills such as data cleaning, transformation, and aggregation with SQL

### Data Source
Data Source: (https://divvy-tripdata.s3.amazonaws.com/index.html)


Queries

1. Data Inspection and Union
Inspect Column Names and Data Types: Ensure consistency across all tables.
Union All Tables: Combine data from multiple monthly tables into a single table all_trips.

2. Data Cleaning
Edit Column Names and Data Types: Standardize data types for key columns such as started_at, ended_at, start_lat, start_lng, end_lat, and end_lng.
Create New Table with Additional Columns: Calculate trip duration and extract day, month, and year from the started_at column.
Remove Invalid Records: Delete records where ended_at is earlier than started_at.

3. Descriptive Analysis
Trip Duration Statistics: Determine the shortest, longest, and average trip durations for members and casual users.
Average Trip Duration by Day of Week: Calculate the average trip duration for users by day of the week.
Trip Frequency by Day of Week: Calculate the frequency of trips for members and casual users for each day of the week.
Total Rides: Calculate the total number of rides for casual users and members.

4. Station Analysis
Popular Start Stations: Identify the most popular start stations for members and casual users.
Popular End Stations: Identify the most popular end stations for members and casual users.
Cross-Reference Station Names: Find common station names used by both members and casual users.

5. Time-based Analysis
Peak Hours: Determine the peak hours for casual and member users.
Trips by Season: Group trips by season and calculate the average ride duration per season.
Trips by Day of Week: Calculate the number of trips for each day of the week, grouped by members and casual users.

6. Additional Analysis
Bike Preference: Analyse the preference of bike types among users.
Standard Deviation for Trip Duration: Calculate the standard deviation of trip durations for casual users.

### How to Use

1. Clone the repository
git clone https://github.com/yourusername/bike-share-data-engineering.git
cd bike-share-data-engineering

2. Run the SQL Script:

Open the bike_share_sql.sql file in your SQL editor.
Execute the script to perform data cleaning, transformation, and analysis.


### Conclusion
The SQL queries provided in this repository can be used as a reference for similar data analysis tasks, ensuring data consistency, cleaning, and deriving valuable insights from raw data.