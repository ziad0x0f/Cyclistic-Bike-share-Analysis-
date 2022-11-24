USE Cyclistics;
GO

--Combining all tables in one table to ease the analysis
SELECT *
	INTO cyc_12_mnth
	FROM
(SELECT * FROM dbo.[tripdata_09-2021]
UNION ALL
SELECT * FROM dbo.[tripdata_10-2021]
UNION ALL
SELECT * FROM dbo.[tripdata_11-2021]
UNION ALL
SELECT * FROM dbo.[tripdata_12-2021]
UNION ALL
SELECT * FROM dbo.[tripdata_01-2022]
UNION ALL
SELECT * FROM dbo.[tripdata_02-2022]
UNION ALL
SELECT * FROM dbo.[tripdata_03-2022]
UNION ALL
SELECT * FROM dbo.[tripdata_04-2022]
UNION ALL
SELECT * FROM dbo.[tripdata_05-2022]
UNION ALL
SELECT * FROM dbo.[tripdata_06-2022]
UNION ALL
SELECT * FROM dbo.[tripdata_07-2022]
UNION ALL
SELECT * FROM dbo.[tripdata_08-2022]
) t

-- Add Ride length Column
ALTER TABLE CYC_12_MNTH
ADD ride_length_min AS
ABS(DATEDIFF(mi, ended_at,started_at))

-- Add Day of Week Column
ALTER TABLE CYC_12_MNTH
ADD day_of_week AS DATENAME(WEEKDAY, started_at)

--Drop NUll unusable columns
ALTER TABLE CYC_12_MNTH
DROP COLUMN start_station_name, end_station_name, start_station_id, end_station_id, start_lat, start_lng, end_lat, end_lng

--Drop Ride length less than 1 minute
DELETE FROM dbo.cyc_12_mnth WHERE ride_length_min <= 1




