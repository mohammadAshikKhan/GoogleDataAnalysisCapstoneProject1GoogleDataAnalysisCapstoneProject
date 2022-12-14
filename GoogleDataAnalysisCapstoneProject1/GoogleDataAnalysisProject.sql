WITH

----------------------------> Combine 12 monthly dataset to 1 yearly dataset <-------------------------
year_data AS 
(
SELECT * 
FROM ['202101-divvy-tripdata']
UNION ALL
SELECT *
FROM ['202102-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202103-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202004-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202005-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202006-divvy-tripdata']
UNION ALL
SELECT *
FROM ['202007-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202008-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202009-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202010-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202011-divvy-tripdata']
UNION ALL 
SELECT * 
FROM ['202012-divvy-tripdata']
),

---------------------------> Clear empty cells from the dataset <----------------------------------------
null_cleaned AS
(
SELECT *
FROM year_data
WHERE start_station_name IS NOT NULL 
                      AND end_station_name IS NOT NULL 
						AND start_lat IS NOT NULL 
						  AND start_lng IS NOT NULL 
						   AND end_lat IS NOT NULL 
						     AND end_lng IS NOT NULL

),

-----------> Aggregated rider length as Minutes, and assign respective day of the week <----------
aggre_data AS (
SELECT *,
   DATEDIFF(MINUTE,started_at, ended_at) TotalMinute
  -- CASE
  --    WHEN day_of_week = 1 THEN 'Sunday'
  --    WHEN day_of_week = 2 THEN 'Monday'
  --    WHEN day_of_week = 3 THEN 'Tuesday'
  --    WHEN day_of_week = 4 THEN 'Wednesday'
  --    WHEN day_of_week = 5 THEN 'Thursday'
  --    WHEN day_of_week = 6 THEN 'Friday'
  --  ELSE
  --  'Saturday'
  --END
  --  AS Day_Week
FROM null_cleaned
),
---------------------------> Remove Ride_id with characters more than 16 <---------------------------------
clean_ride_id_data AS(
SELECT *
FROM aggre_data
WHERE LEN(ride_id) = 16 AND TotalMinute >= 1
),
---------------------------> TRIM station name to ensure no extra space, and to replace (*), (Temp), filter out row with(LBS-WH-TEST) in start station name <------------------
cstart_station_name_data AS
(
	SELECT ride_id,
	TRIM(REPLACE
		(REPLACE
			(start_station_name, '(*)',''),
				'(TEMP)','')) AS start_station_name_clean
	

	FROM clean_ride_id_data
	WHERE start_station_name NOT LIKE '%(LBS-WH-TEST)%' 
),
cend_station_name_data AS
(
	SELECT ride_id,
	TRIM(REPLACE
		(REPLACE
			(end_station_name, '(*)',''),
				'(TEMP)','')) AS end_station_name_clean
	

	FROM clean_ride_id_data
	WHERE end_station_name NOT LIKE '%(LBS-WH-TEST)%'
),
station_name AS
(
	SELECT ss.ride_id, ss.start_station_name_clean, es.end_station_name_clean 
	FROM cstart_station_name_data ss
	  JOIN cend_station_name_data es
	  ON ss.ride_id = es.ride_id
),
---------------------------> JOIN clean station columns to the main dataset ON ride_id <---------------------------------------------------------
final_table AS
(
	Select	sn.ride_id, crid.rideable_type, crid.member_casual, 
		CAST(crid.started_at AS date) AS Date_ofYear, crid.ended_at, crid.TotalMinute,
		sn.start_station_name_clean, sn.end_station_name_clean,
		crid.start_lat, crid.start_lng, 
		crid.end_lat, crid.end_lng 
	FROM clean_ride_id_data crid
	  JOIN station_name sn
	  ON crid.ride_id = sn.ride_id
),

-------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------->> DATA EXPLORATION & ANALYSIS <<------------------------------------------------------------
casual_depart_station AS
(
	SELECT COUNT(member_casual) AS Casual, start_station_name_clean
	FROM final_table
	WHERE member_casual = 'casual' 
	GROUP BY start_station_name_clean 
),

member_depart_station AS
(
	SELECT COUNT(member_casual) AS Member, start_station_name_clean
	FROM final_table
	WHERE member_casual = 'member' 
	GROUP BY start_station_name_clean 
),
depart_station AS
(
	SELECT cds.start_station_name_clean, cds.Casual, mds.Member
	FROM casual_depart_station cds
	  JOIN member_depart_station mds
	  ON cds.start_station_name_clean = mds.start_station_name_clean
),
depart_latlng AS
(
	SELECT DISTINCT start_station_name_clean, ROUND(AVG(start_lat),4) AS dep_lat, Round(AVG(start_lng),4) AS dep_lng
	FROM final_table
	GROUP BY start_station_name_clean
),
---------------------------> Join location coordinate data with ridership count <---------------------------------------------------------------------
---------------------------- (Export to excel & import to tableau for geo-visualisation)--------------------------------------------------------------
locationviz_depart AS
(
	SELECT dl.start_station_name_clean, ds.Casual, ds.Member, dl.dep_lat, dl.dep_lng
	FROM depart_station ds
	  JOIN depart_latlng dl
	  ON ds.start_station_name_clean = dl.start_station_name_clean
),
---------------------------> 2. Find out total numbers of member or casual riders ARRIVING for respective stations <----------------------------------
casual_arrive_station AS
(
	SELECT COUNT(member_casual) AS Casual, end_station_name_clean
	FROM final_table
	WHERE member_casual = 'casual' 
	GROUP BY end_station_name_clean 
),
member_arrive_station AS
(
	SELECT COUNT(member_casual) AS Member, end_station_name_clean
	FROM final_table
	WHERE member_casual = 'member' 
	GROUP BY end_station_name_clean 
),
---------------------------> Join member & casual riders ON arriving bike stations <------------------------------------------------------------------
arrive_station AS
(
	SELECT cas.end_station_name_clean, cas.Casual, mas.Member
	FROM casual_arrive_station cas
	  JOIN member_arrive_station mas
	  ON cas.end_station_name_clean = mas.end_station_name_clean
),
---------------------------> GROUP arriving station name with distinct Latitude and Altitude <------------------------------------------------------
arrive_latlng AS
(
	SELECT DISTINCT end_station_name_clean, ROUND(AVG(end_lat),4) AS arr_lat, Round(AVG(end_lng),4) AS arr_lng
	FROM final_table
	GROUP BY end_station_name_clean
),
---------------------------> Join location coordinate data with ridership count <---------------------------------------------------------------------
---------------------------- (Export to excel & import to tableau for geo-visualisation)--------------------------------------------------------------
locationviz_arrive AS
(
	SELECT al.end_station_name_clean, ast.Casual, ast.Member, al.arr_lat, al.arr_lng
	FROM arrive_station ast
	  JOIN arrive_latlng al
	  ON ast.end_station_name_clean = al.end_station_name_clean
),
-----------> 3. To find out trips taken by casual & members respectively group by days <---------------------------------

day_trips_casual AS
(
	SELECT count(member_casual) AS casual, Date_ofYear
	FROM final_table
	WHERE member_casual = 'casual'
	GROUP BY Date_ofYear
),
day_trips_member AS
(
	SELECT count(member_casual) AS member, Date_ofYear
	FROM final_table
	WHERE member_casual = 'member'
	GROUP BY Date_ofYear
),
day_trip_year AS
(
	SELECT dtc.casual, dtm.member, dtm.Date_ofYear 
	FROM day_trips_casual dtc
	  JOIN day_trips_member dtm
	  ON dtc.Date_ofYear = dtm.Date_ofYear
),

------------------------------> 4. To find the AVERAGE ride time for Casual & Member Riders <----------------------------------------------------------
data_totalmin_casual AS
(
	SELECT AVG(TotalMinute) AS AVG_ride_casual
	FROM final_table
	WHERE member_casual = 'casual'
),
data_totalmin_member AS
(
	SELECT AVG(TotalMinute) AS AVG_ride_member
	FROM final_table
	WHERE member_casual = 'member'
),
----------------------------> 5. To find the Overall Rider Count for Casual & Member riders <-----------------------------------------------------------
totalride_casual AS
(
	SELECT count(member_casual) AS ridership_casual
	FROM final_table
	WHERE member_casual = 'casual'
),
totalride_member AS
(
	SELECT count(member_casual) AS ridership_member
	FROM final_table
	WHERE member_casual = 'member'
)
SELECT *
FROM totalride_member