

--Select the data we are going to be using
select * 
from[dbo].[CovidDeaths]

select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths]
order by 1,2

--Looking at Total Cases vs Total Deaths and change Change Data Types

alter table [dbo].[CovidDeaths]
alter column population float

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 deathpercentage 
from [dbo].[CovidDeaths]
where location = 'Canada'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what % of the Population got COVID

select location, date, total_cases, population, (total_cases/population)*100 covidpercentage 
from [dbo].[CovidDeaths]
where location = 'Canada'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) highest_infection_count, max((total_cases/population))*100 max_covid_percentage 
from [dbo].[CovidDeaths]
group by location, population
order by 4 desc

--Countries with the highest Death Count 

select location, max(cast(total_deaths as int)) total_death_count
from [dbo].[CovidDeaths]
where continent is not null
group by location
order by 2 desc

--Breaking it down by Continent

select location, max(cast(total_deaths as int)) total_death_count
from [dbo].[CovidDeaths]
where continent is null
group by location
order by 2 desc

--GLOBAL NUMBERS

select sum(cast(new_cases as float)) total_cases, sum(cast(new_deaths as float)) total_deaths
     , sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 deathpercentage 
from [dbo].[CovidDeaths]
where continent is not null
order by 1,2

--Total Cases in Canada Dec 11th to Dec 17th

select sum(cast(new_cases as float)) new_cases, sum(cast(new_deaths as float)) new_deaths
from [dbo].[CovidDeaths]
where location = 'Canada' and date >= '2022-12-11' and date <= '2022-12-16'

--Looking at Total Population versus Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location, dea.date) rolling_people_vaxxed
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
order by 2,3

--Use a CTE

with PopvsVac  (continent, location, date, population, new_vaccinations, rolling_people_vaxxed)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location, dea.date) rolling_people_vaxxed
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 and dea.location = 'Canada'
where dea.continent is not null and new_vaccinations is not null
)
select * , (rolling_people_vaxxed/population)*100 as vaxxed_population
from PopvsVac
order by 2,3

--Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaxxed numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) 
over (partition by dea.location order by dea.location, dea.date) rolling_people_vaxxed
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 and dea.location = 'Canada'
where dea.continent is not null and new_vaccinations is not null

select * , (rolling_people_vaxxed/population)*100 as vaxxed_population
from #PercentPopulationVaccinated
order by 2,3