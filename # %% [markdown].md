# %% [markdown]
# 
# # Analysis Process Using Python

# %%
# Importing used libraries for analysis 
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import seaborn as sns
sns.set()

# %%
# Importing the combined df_cyc table
df_cyc = pd.read_csv("D:\Courses\Data Analysis\Projects\Cyclistics\DATA\cleaned\cleaned_data.csv")
df_cyc.head()

# %%
# Coverting df_cyctypes of each columns.
df_cyc = df_cyc.astype({'ride_id':'string', 'rideable_type':'category','started_at': 'datetime64','ended_at': 'datetime64', 'member_casual':'category','day_of_week':'category'})
df_cyc.info()

# %%
# Trim whitespace in member_casual & rideable_type columns
df_cyc['member_casual'] = df_cyc['member_casual'].str.replace(' ', '')
df_cyc['rideable_type'] = df_cyc['rideable_type'].str.replace(' ', '')
df_cyc[['day_of_week','rideable_type']].nunique()

# %%
# Adding year, months & hours columns
df_cyc['year'] = df_cyc['started_at'].dt.year
df_cyc['hour'] = df_cyc['started_at'].dt.hour
df_cyc['month'] = df_cyc['started_at'].dt.month_name()
df_cyc['month_year'] = df_cyc['started_at'].dt.to_period('M')

df_cyc.head()

# %%
# convert month to category
df_cyc = df_cyc.astype({'month':'category'})
df_cyc.info()

# %%
# no. of rows & columns
df_cyc.shape

# %% [markdown]
# #### Check for unique values

# %%
# Check for unique values
df_cyc.nunique()

# %% [markdown]
# ### Ride Length Analysis

# %%
df_cyc.groupby(['member_casual'])['ride_length_min'].describe()

# %% [markdown]
# - The longest journey for a casual rider was **678.5 hours**, whereas the longest trip for a member rider was **26 hours**. Both of these figures are quite high. Such journeys should be categorised as outliers. To decrease outlier bias, I decided to **Delete** the highest quantile of data (the top 25% percentile).

# %%
cont = df_cyc[(df_cyc['ride_length_min'] > 16.0) & (df_cyc['member_casual'] == 'member')].index 
df_cyc.drop(cont, inplace= True)
cont = df_cyc[(df_cyc['ride_length_min'] > 26.0) & (df_cyc['member_casual'] == 'casual')].index 
df_cyc.drop(cont, inplace= True)
df_cyc

# %%
palette = {"casual":"#EBF869","member":"#4095A4"}
sns.boxplot(data=df_cyc, x='member_casual', y='ride_length_min', palette=palette)
plt.xlabel("")
plt.ylabel("Ride Minutes")
plt.title("Member and Casual Riders Distribution",fontweight ='bold', fontsize = 14, loc='left')

# %% [markdown]
# - Since the mean & the median values are **Near**, and the std is dramaticaly **Lowered** therefore this is expected to lead to more logical analysis 

# %%
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


# %% [markdown]
# - The ride minutes in weekends for casual riders is nearly **Double** the number compared to member riders
# 
# - the member riders are more **Consistent** through the day its more likely that the reason is, member riders uses their bikes for going to work. which explains why they are less active at the weekends

# %% [markdown]
# ### Number of Rides Analysis

# %%
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



# %% [markdown]
# - Member riders made nearly **Double** the no. of rides with classic bikes compared to casual riders
# 
# - member riders didn't record any docked bike rides

# %%
sns.countplot(data=df_cyc, x='member_casual', palette=palette)
# after plotting the data, format the labels
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.ylabel("")
plt.xlabel("")
plt.xticks(fontsize=16)
plt.title("Total Number of Riders", fontsize=20, fontweight='bold', loc='left')

# %%
ax = df_cyc.groupby(['member_casual','day_of_week'])['ride_id'].count().unstack(0)
ax.plot.bar(figsize=(10,6), color= palette)
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.legend(bbox_to_anchor=(1,1))
plt.xlabel("")
plt.ylabel('Total Rides',fontsize=15)
plt.title("Riders Activity During the Week",fontweight ='bold', fontsize = 20, loc='left')

# %% [markdown]
#  Member riders usually take more rides during the week except on **Weekends**

# %%
ax = df_cyc.groupby(['member_casual','month_year'])['ride_id'].count().unstack(0)
#sns.countplot(data=df_cyc, x='month_year', hue='member_casual')
ax.plot(figsize=(10,6), color={"#e2f428","#4095A4"})
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.legend(bbox_to_anchor=(1,1))
plt.xlabel("Months(Sep2021-Aug2022)")
plt.ylabel('Total Rides',fontsize=15)
plt.title("Total Rides in Month ",fontweight ='bold', fontsize = 20, loc='left')

# %% [markdown]
# - It shows that the total number of rides **Decrease** in winter & **Increase** in summer
# 
# - Casual & member riders have nearly the **Same** behaviour 

# %%
ax = df_cyc.groupby(['member_casual','hour'])['ride_id'].count().unstack(0)
ax.plot(figsize=(10,6), color=palette)
current_values = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.0f}'.format(y) for y in current_values])
plt.xticks(np.arange(min(df_cyc['hour']), max(df_cyc['hour'])+1, 1.0))
plt.xlabel("Hours")
plt.ylabel('Total Rides',fontsize=15)
plt.title("Rides per Hour ",fontweight ='bold', fontsize = 20, loc='left')

# %% [markdown]
# - it is noticable that most member riders are most likely using their bikes to travel from/to workplace, as the no. of rides increase from 4 a.m to 8 a.m then it start to drop untill 10 a.m. on the other side, casual members no. of rides didn't decrease from 8 a.m and it increased from 9 a.m to 5 p.m
# 
# - the sudden increase from 2 p.m to 5 p.m reinforces my claims about using the bike for travelling from/to workplace when it comes to member Riders  

# %% [markdown]
# ### Conclusion

# %% [markdown]
# - Casual Riders Make **Less Rides** Than Members but, Spend **More Riding Minutes**
# 
# - The Ride Minutes in Weekends for Casual Riders is Nearly **Double** the Number Compared to Member Riders
# 
# - the Member Riders are more Likely Using their Bikes for **Travelling to/from Workplace** on a Daily Basis
# 
# - Docked bike type is **not a preffered option** for the Riders 
# 
# - the Riders tend to Take More Rides in **Spring & Summer**


