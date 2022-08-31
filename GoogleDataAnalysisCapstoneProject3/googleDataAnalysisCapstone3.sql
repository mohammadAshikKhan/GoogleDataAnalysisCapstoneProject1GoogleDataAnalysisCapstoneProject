--create database call GoogleDataAnalysisCapstoneProject3
--using sql server
--use GoogleDataAnalysisCapstoneProject3
CREATE DATABASE GoogleDataAnalysisCapstoneProject3

--check null and distinct values from all data set
SELECT *
FROM [dbo].['2015']

SELECT *
FROM [dbo].['2016']

SELECT *
FROM [dbo].['2017']

SELECT *
FROM [dbo].['2018']


SELECT *
FROM [dbo].['2019']

SELECT distinct Region
FROM [dbo].['2015']


SELECT  distinct Region
FROM [dbo].['2016']


select * 
from [dbo].['2015']
where happiness_rank is null

--count each region include country
select region, count(happiness_rank) total_rank_each_region
from [dbo].['2015']
group by region
order by 1 DESC

--max happiness score each region
select happiness_score, country,region
from [dbo].['2015']
where region = 'Western Europe' and happiness_score = (select max(happiness_score) from [dbo].['2015'])

select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Australia and New Zealand')

select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Central and Eastern Europe')

select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Eastern Asia')

select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Latin America and Caribbean')


select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Middle East and Northern Africa')



select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'North America')


select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Southeastern Asia')

select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Southern Asia')

select happiness_score, country,region
from [dbo].['2015']
where happiness_score = (select max(happiness_score) from [dbo].['2015'] where region = 'Sub-Saharan Africa')

--max gdp per region

select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Western Europe')

select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Australia and New Zealand')

select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Central and Eastern Europe')

select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Eastern Asia')

select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Latin America and Caribbean')


select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Middle East and Northern Africa')



select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'North America')


select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Southeastern Asia')

select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Southern Asia')

select Economy_GDP_per_Capita, country,region
from [dbo].['2015']
where Economy_GDP_per_Capita = (select max(Economy_GDP_per_Capita) from [dbo].['2015'] where region = 'Sub-Saharan Africa')
