
--Useful queries.
select *
from [dbo].[2019_cancelled_flights]
where Airline in ('Envoy Air', 'Alaska Airlines Inc.', 'Allegiant Air', 'American Airlines Inc.', 'Delta Air Lines Inc.', 'Frontier Airlines Inc.' , 
'Hawaiian Airlines Inc.', 'JetBlue Airways', 'Southwest Airlines Co.', 'Spirit Air Lines', 'United Air Lines Inc.')

UPDATE [dbo].[2022_cancelled_flights]
SET Cancelled = CASE WHEN Cancelled = 'True' THEN 1 ELSE 0 END

alter table [dbo].[2022_cancelled_flights]
alter column Cancelled int

----------------------------------------------------------------------------------------------------------------------------------------------------
--1. Which airports had the highest flight cancellation percentage per year? This data only accounts for airports with a minimum of 3000 flights per year.
-----Missing data for months: January, March and November.

select a.Departure_Airport, num_cancelled, total_flights, (cast(num_cancelled as float) / cast(total_flights as float)) * 100 as percentage_cancelled
from (
select Departure_Airport, count(*) as total_flights
from [dbo].[2022_cancelled_flights]
group by Departure_Airport
having count(*) >= '3000'
) a
join (
select Departure_Airport, count(Cancelled) num_cancelled
from [dbo].[2022_cancelled_flights]
where Cancelled = 1
Group by Departure_Airport, Cancelled
) b on a.Departure_Airport = b.Departure_Airport
order by percentage_cancelled desc
---------------------------------------------------------------------------------------------------------------------------------------------------
--2. Which airports had the highest flight cancellation percentage per Quarter? This data only accounts for airports with a minimum of 600 flights per Quarter.
-----Missing data for months: January, March and November.

select f.Quarter, f.Departure_Airport, count(*) total_flights, sum(Cancelled) as cancelled_q, 
cast(sum(Cancelled) as float)/count(*)*100 as can_percentage
from [dbo].[2022_cancelled_flights] as f
Group by f.Quarter, f.Departure_Airport
having count(*) > '600'
order by Quarter, can_percentage desc
---------------------------------------------------------------------------------------------------------------------------------------------------
--3. Which airports had the highest flight cancellation percentage per Month? This data only accounts for airports with a minimum of 200 flights per Month.
-----Missing data for months: January, March and November.


select month(date) month, Departure_Airport, count(*) total_flights, sum(Cancelled) as cancelled_q, 
cast(sum(Cancelled) as float)/count(*)*100 as can_percentage
from [dbo].[2022_cancelled_flights]
Group by month(Date), Departure_Airport
having count(*) > '200' and sum(Cancelled) > 0
order by month(Date), can_percentage desc
----------------------------------------------------------------------------------------------------------------------------------------------------
--4. Which Airline had the highest cancelled flight percentage per quarter?
-----Missing data for months: January, March and November.


select Quarter, Airline, count(*) as total_flights, sum(Cancelled) as flights_cancelled,
cast(sum(Cancelled) as float)/count(*)*100 as cancelled_percent
from [dbo].[2022_cancelled_flights]
where Airline in ('Envoy Air', 'Alaska Airlines Inc.', 'Allegiant Air', 'American Airlines Inc.', 'Delta Air Lines Inc.', 'Frontier Airlines Inc.' , 
'Hawaiian Airlines Inc.', 'JetBlue Airways', 'Southwest Airlines Co.', 'Spirit Air Lines', 'United Air Lines Inc.')
Group by Quarter, Airline
Having count(*) > '600'
Order by Quarter, cancelled_percent desc
----------------------------------------------------------------------------------------------------------------------------------------------------



