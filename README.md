# Cyclistic Bike Share Analysis

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
![Screenshot 2022-11-28 160855](https://user-images.githubusercontent.com/100311796/204298744-3bca5a84-835b-422f-9bbf-2d26edd04684.png)

### Ride Length Analysis

```
df_cyc.groupby(['member_casual'])['ride_length_min'].describe()
```
![Screenshot 2022-11-28 161539](https://user-images.githubusercontent.com/100311796/204299642-df985e2d-85ca-4cb6-b4a9-99e90952ad2e.png)
- The longest journey for a casual rider was **678.5 hours**, whereas the longest trip for a member rider was **26 hours**. Both of these figures are quite high. Such journeys should be categorised as outliers. To decrease outlier bias, I decided to **Delete** the highest quantile of data (the top 25% percentile)

```
cont = df_cyc[(df_cyc['ride_length_min'] > 16.0) & (df_cyc['member_casual'] == 'member')].index 
df_cyc.drop(cont, inplace= True)
cont = df_cyc[(df_cyc['ride_length_min'] > 26.0) & (df_cyc['member_casual'] == 'casual')].index 
df_cyc.drop(cont, inplace= True)
```

```
palette = {"casual":"#EBF869","member":"#4095A4"}
sns.boxplot(data=df_cyc, x='member_casual', y='ride_length_min', palette=palette)
plt.xlabel("")
plt.ylabel("Ride Minutes")
plt.title("Member and Casual Riders Distribution",fontweight ='bold', fontsize = 14, loc='left')
```
![image](https://user-images.githubusercontent.com/100311796/204300379-8baf6822-b5f6-4dcb-a0ea-84954c0881bc.png)
- Since the mean & the median values are **Near**, and the std is dramaticaly **Lowered** therefore this is expected to lead to more logical analysis 

```
ax = df_cyc.groupby(['member_casual','day_of_week']).agg(ride_length=('ride_length_min','sum'))
ax = ax.reset_index()
palette = {"casual":"#EBF869",
           "member":"#4095A4"}

sns.barplot(x="day_of_week",
           y="ride_length",
           hue="member_casual",
           palette=palette,
           data=ax)

current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.legend(bbox_to_anchor=(1,1))
plt.xlabel("")
plt.ylabel('Ride Minutes',fontsize=13)
plt.title("Total Ride Minutes",fontweight ='bold', fontsize = 18, loc='left')
```
![image](https://user-images.githubusercontent.com/100311796/204303399-e84659f6-ef64-42ce-bfa1-b6b90a729b79.png)

- The ride minutes in weekends for casual riders is nearly **Double** the number compared to member riders

- the member riders are more **Consistent** through the day its more likely that the reason is, member riders uses their bikes for going to work. which explains why they are less active at the weekends

### Number of Rides Analysis

```
ax1 = df_cyc.groupby(['member_casual','rideable_type']).agg(ride_count=('ride_id','count'))
ax1 = ax1.reset_index()

sns.barplot(x="rideable_type",
           y="ride_count",
           hue="member_casual",
           palette=palette,
           data=ax1)
           
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.legend(bbox_to_anchor=(1,1))
plt.xlabel("")
plt.ylabel("No. Of Rides")
plt.title("Rides by bike type",fontweight ='bold', fontsize = 18, loc='left')
```
![image](https://user-images.githubusercontent.com/100311796/204303637-cb0ce6f6-0dd7-4c96-89b9-e74135bedef0.png)

- Member riders made nearly **Double** the no. of rides with classic bikes compared to casual riders

- member riders didn't record any docked bike rides

```
sns.countplot(data=df_cyc, x='member_casual', palette=palette)
# after plotting the data, format the labels
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.ylabel("")
plt.xlabel("")
plt.xticks(fontsize=16)
plt.title("Total Number of Riders", fontsize=20, fontweight='bold', loc='left')
```
![image](https://user-images.githubusercontent.com/100311796/204304005-5b70717a-2743-4ec2-9182-ddcb3e653674.png)

```
ax = df_cyc.groupby(['member_casual','day_of_week'])['ride_id'].count().unstack(0)
ax.plot.bar(figsize=(10,6), color= palette)
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.legend(bbox_to_anchor=(1,1))
plt.xlabel("")
plt.ylabel('Total Rides',fontsize=15)
plt.title("Riders Activity During the Week",fontweight ='bold', fontsize = 20, loc='left')
```
![image](https://user-images.githubusercontent.com/100311796/204304129-0908b555-a563-4763-8476-bdf2e65daabb.png)

 Member riders usually take more rides during the week except on **Weekends**
 
 ```
 ax = df_cyc.groupby(['member_casual','month_year'])['ride_id'].count().unstack(0)
#sns.countplot(data=df_cyc, x='month_year', hue='member_casual')
ax.plot(figsize=(10,6), color={"#e2f428","#4095A4"})
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.legend(bbox_to_anchor=(1,1))
plt.xlabel("Months(Sep2021-Aug2022)")
plt.ylabel('Total Rides',fontsize=15)
plt.title("Total Rides in Month ",fontweight ='bold', fontsize = 20, loc='left')
 ```
 ![image](https://user-images.githubusercontent.com/100311796/204304260-6033223e-8c40-4e39-82ca-975c5c95b4f1.png)

- It shows that the total number of rides **Decrease** in winter & **Increase** in summer

- Casual & member riders have nearly the **Same** behaviour 

```
ax = df_cyc.groupby(['member_casual','hour'])['ride_id'].count().unstack(0)
ax.plot(figsize=(10,6), color=palette)
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.xticks(np.arange(min(df_cyc['hour']), max(df_cyc['hour'])+1, 1.0))
plt.xlabel("Hours")
plt.ylabel('Total Rides',fontsize=15)
plt.title("Rides per Hour ",fontweight ='bold', fontsize = 20, loc='left')
```
![image](https://user-images.githubusercontent.com/100311796/204304420-692ec57e-a3e3-4cc6-8765-66b9ff8e8638.png)

- it is noticable that most member riders are most likely using their bikes to travel from/to workplace, as the no. of rides increase from 4 a.m to 8 a.m then it start to drop untill 10 a.m. on the other side, casual members no. of rides didn't decrease from 8 a.m and it increased from 9 a.m to 5 p.m

- the sudden increase from 2 p.m to 5 p.m reinforces my claims about using the bike for travelling from/to workplace when it comes to member Riders  


### Conclusion

- Casual Riders Make **Less Rides** Than Members but, Spend **More Riding Minutes**

- The Ride Minutes in Weekends for Casual Riders is Nearly **Double** the Number Compared to Member Riders

- the Member Riders are more Likely Using their Bikes for **Travelling to/from Workplace** on a Daily Basis

- Docked bike type is **not a preffered option** for the Riders 

- the Riders tend to Take More Rides in **Spring & Summer**
