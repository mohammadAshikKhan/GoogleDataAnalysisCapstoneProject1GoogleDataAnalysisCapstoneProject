#install requirement packages 
install.packages('tidyverse')
install.packages('lubridate')
install.packages('sqldf')
install.packages('janitor')
install.packages('skimr')
install.packages('plotrix')
#Load packages
library(tidyverse) #packages
library(lubridate) #Time and date
library(ggplot2)   #Data viz
library(dplyr)     #data manipulation
library(skimr)     #data summarizing 
library(sqldf)     #using sql
library(plotrix)   #3D data viz pie chat
library(janitor)   

#Load data from my local computer
setwd("C:/Users/M R Computer/Downloads/Compressed/GoogleDataAnalysisCapstoneProject2/Fitabase Data 4.12.16-5.12.16")

daily_activity  <- read_csv('dailyActivity_merged.csv')
daily_sleep  <-read_csv('dailySleep_summary.csv')
weight_log   <-read_csv('dailyWeightLog_summary.csv')

#check null or missing values  using the following commands.

#below commands only for daily_activity
str(daily_activity)
skim(daily_activity)
head(daily_activity)
View(daily_activity)
#below commands only for daily_sleep
str(daily_sleep)
skim(daily_sleep)
head(daily_sleep)
#below commands only for weight_log
str(weight_log)
skim(weight_log)
head(weight_log)
#I have also created month and day of
#week column as we need them in analysis
daily_activity <- daily_activity  %>% 
  mutate(Rec_Date = as.Date(ActivityDate,"%m/%d/%y")) %>% 
  mutate(month = format(Rec_Date,"%B")) %>% 
  mutate(day_of_week = format(Rec_Date,"%A"))

View(daily_activity)
#n_distinct id in daily_activity
n_distinct(daily_activity$Id)
#we need to summarize the data. So that 
#we can find some insights about the data.
daily_activity  %>% 
  select(TotalSteps,TotalDistance,SedentaryMinutes,VeryActiveMinutes) %>% 
  summary()
weight_log %>% 
  select(WeightKg,BMI) %>% 
  summary()
#To find insights from sleep data we need to run the following queries:

Avg_minutes_asleep <- sqldf("SELECT SUM(TotalSleepRecords),SUM(TotalMinutesAsleep)/SUM(TotalSleepRecords) as avg_sleeptime
                            FROM daily_sleep")
Avg_minutes_asleep

avgTimeInBad <- sqldf("select SUM(TotalTimeInBed)/SUM(TotalSleepRecords) as avg_timeInBed
                      from daily_sleep")
avgTimeInBad 

n_distinct(daily_sleep$Id)
n_distinct(weight_log$Id)  

#In this step, we will create some visualizations based on our analysis and goal of project.
daily_activity$day_of_week <- ordered(daily_activity$day_of_week,levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))  
ggplot(data=daily_activity,mapping = aes(x=day_of_week,fill=day_of_week)) +
  geom_bar() +
  labs(x="day of week",y="Count",title="No. of times users used tracker across week")

mean_steps <- mean(daily_activity$TotalSteps)
mean_steps

mean_calories <- mean(daily_activity$Calories)
mean_calories  

ggplot(data=daily_activity,mapping = aes(x=TotalSteps, y=Calories, color=Calories)) +
  geom_point() +
  geom_hline(mapping = aes(yintercept=mean_calories),color="yellow",lwd=1.0) +
  geom_vline(mapping = aes(xintercept=mean_steps),color="red",lwd=1.0) +
  geom_text(mapping = aes(x=10000,y=500,label="Average Steps",srt=-90)) +
  geom_text(mapping = aes(x=29000,y=2500,label="Average Calories")) +
  labs(x="Steps Taken",y="Calories Burnes",title="Calories burrnes for every step taken")

ggplot(data=daily_activity,mapping = aes(x=TotalSteps, y=SedentaryMinutes,color=Calories)) +
  geom_point() +
  geom_smooth(method = 'loess',color="green") +
  labs(x="Total Steps",y="Sedentary Minutes",title = "Total Steps vs Sedentary Minutes")
 
ggplot(data=daily_sleep,mapping = aes(x=TotalMinutesAsleep, y=TotalTimeInBed))+
  geom_point() +
  geom_smooth() +
  labs(x="Total minutes a sleep",y="Total time in bad",title = "Total time vs total sleep")
ggplot(data=daily_activity,aes(x=SedentaryMinutes,y=Calories,color=Calories))+
  geom_point() +
  geom_smooth(method='loess',color='red')+
  labs(y="Calories", x="Sedentary Minutes", title="Calories vs. Sedentary Minutes")

activity_min <- sqldf("SELECT SUM(VeryActiveMinutes),SUM(FairlyActiveMinutes),
      SUM(LightlyActiveMinutes),SUM(SedentaryMinutes)
      FROM daily_activity")
activity_min  

# I have uploaded image for the code that's why i have commented the code
x <- c(19895,12751,181244,931738)
x
piepercent <- round(100*x / sum(x), 1)
colors = c("red","blue","green","yellow")

pie3D(x,labels = paste0(piepercent,"%"),col=colors,main = "Percentage of Activity in Minutes")
legend("bottomright",c("VeryActiveMinutes","FairlyActiveMinutes","LightlyActiveMinutes","SedentaryMinutes"),cex=0.5,fill = colors)
  
activity_dist <- sqldf("SELECT SUM(ModeratelyActiveDistance),SUM(LightActiveDistance),
      SUM(VeryActiveDistance),SUM(SedentaryActiveDistance)
      FROM daily_activity")
activity_dist  

# I have uploaded image for the code that's why i have commented the code
y <- c(533.49,3140.37,1412.52)
y
piepercent <- round(100*y / sum(y), 1)
colors = c("orange","green","blue")
pie3D(y,labels = paste0(piepercent,"%"),col=colors,main = "Percentage of Activity in Distance")
legend("bottomright",c("ModeratelyActiveDistance","LightlyActiveDistance","VeryActiveDistance"),cex=0.5,fill = colors)  

count_overweight <- sqldf("SELECT COUNT(DISTINCT(Id))
                          FROM weight_log
                          WHERE BMI > 24.9")
count_overweight  

# I have uploaded image for the code that's why i have commented the code
z <- c(5,3)
piepercent <- round(100*z / sum(z),1)
colors = c("red","green")
pie3D(z,labels=paste0(piepercent,"%"),explode=0.1,col=colors,radius=1,main="Percentage of people with Over Weight 
     vs Healthy Weight")
legend("bottomright",c("OverWeight","HealthyWeight"),cex=0.5,fill=colors)  
  
