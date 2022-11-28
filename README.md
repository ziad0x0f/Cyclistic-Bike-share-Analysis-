# Cyclistic-Bike-share-Analysis

##### Author: Ziad Zakaria 

##### Date: 2022-11-24
#

#### The case study follows the six step data analysis process: ####

* [Ask](#1-ask)
* [Prepare](#2-prepare)
* [Process](#3-process)
* [Analyze](#4-analyze)
* [Share](#5-share)
* [Act](#6-act)
#

## Scenario
You are a junior data analyst working in the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director
of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore,
your team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights,
your team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives
must approve your recommendations, so they must be backed up with compelling data insights and professional data
visualizations.
#

## 1. Ask
:red_circle: **GOAL: Design marketing strategies aimed at converting casual riders into annual members**

Primary stakeholders: Lily Moreno & Cyclistic executive team

Secondary stakeholders: Cyclistic marketing analytics team

## 2. Prepare 
Data Source: [Cyclistic’s Historical Trip Data](https://divvytripdata.s3.amazonaws.com/index.html)

Dataset made available through [Motivate International Inc.](https://ride.divvybikes.com/data-license-agreement) 

The dataset follows the **ROCCC** approach
- Reliability ✅
- Original ✅ 
- Comprehensive? 🤔 I Think That if The Dataset Included the Price of the Bikes and The age of the Users, It Could Have Lead To a Better Analysis and More Informative Insights.  
- Current ✅   Data is from September 2021 to August 2022(Past 12 Months)
- Cited ✅ 

## 3. Process
### SQL Data Processing
#### Combining All Tables in One Table to Ease the Analysis After Creating Cyclistics Database 
```
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
```

#### Add Ride length Column
```
ALTER TABLE CYC_12_MNTH
ADD ride_length_min AS
ABS(DATEDIFF(mi, ended_at,started_at))
```

#### Add Day of Week Column
```
ALTER TABLE CYC_12_MNTH
ADD day_of_week AS DATENAME(WEEKDAY, started_at)
```

#### Drop NUll unusable columns
```
ALTER TABLE CYC_12_MNTH
DROP COLUMN start_station_name, end_station_name, start_station_id, end_station_id, start_lat, start_lng, end_lat, end_lng
```

#### Drop Ride length less than 1 minute
```
DELETE FROM dbo.cyc_12_mnth WHERE ride_length_min <= 1
```

### Python Data Processing

#### Loading used libraries
```
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import seaborn as sns
sns.set()
```
#### Importing used libraries for analysis 
```
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import seaborn as sns
sns.set()
```

#### Importing the combined df_cyc table
```
df_cyc = pd.read_csv("D:\Courses\Data Analysis\Projects\Cyclistics\DATA\cleaned\cleaned_data.csv")
df_cyc.head()
```

#### Coverting df_cyctypes of each column
```
df_cyc = df_cyc.astype({'ride_id':'string', 'rideable_type':'category','started_at': 'datetime64','ended_at': 'datetime64', 'member_casual':'category','day_of_week':'category'})
df_cyc.info()
```

#### Trim whitespace in member_casual & rideable_type columns
```
df_cyc['member_casual'] = df_cyc['member_casual'].str.replace(' ', '')
df_cyc['rideable_type'] = df_cyc['rideable_type'].str.replace(' ', '')
df_cyc[['day_of_week','rideable_type']].nunique()
```
- day_of_week      7
- rideable_type    3
- dtype: int64

#### Adding year, months & hours columns
```
df_cyc['year'] = df_cyc['started_at'].dt.year
df_cyc['hour'] = df_cyc['started_at'].dt.hour
df_cyc['month'] = df_cyc['started_at'].dt.month_name()
df_cyc['month_year'] = df_cyc['started_at'].dt.to_period('M')
```
#### Convert month to category
```
df_cyc = df_cyc.astype({'month':'category'})
df_cyc.info()
```       
