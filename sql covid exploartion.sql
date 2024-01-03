select * 
from [portfolio sql 1]..CovidDeaths
order by 3,4

select * 
from [portfolio sql 1]..CovidVaccinations$
order by 3,4

select location,total_cases,date,new_cases,total_deaths,population
from [portfolio sql 1]..CovidDeaths

--total cases vs total deaths 
select location,total_cases,date,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [portfolio sql 1]..CovidDeaths

--likelihood of dying if u contract covid in your country 
select location,total_cases,date,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [portfolio sql 1]..CovidDeaths 
where location like '%states'

--total cases vs population
select location,total_cases,population ,(total_cases/population)*100 as death_percentage
from [portfolio sql 1]..CovidDeaths

--what percent of population got covid
select location,total_cases,population ,(total_cases/population)*100 as percentpopulationinfected
from [portfolio sql 1]..CovidDeaths
where location like '%states'

--countries with highest infectious rate than other population
select location,population,MAX(total_cases) as highinfectioncount,MAX((total_cases/population))*100 as percentpopulationinfected
from [portfolio sql 1]..CovidDeaths
group by location,population
order by percentpopulationinfected desc

--countries with highest death count per population
select location,MAX(cast(total_deaths as int)) as totaldeathcount
from [portfolio sql 1]..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc


--countries with highest death count per population by continent 
select continent,MAX(cast(total_deaths as int)) as totaldeathcount
from [portfolio sql 1]..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--continents with highest death count
select continent,MAX(cast(total_deaths as int)) as totaldeathcount
from [portfolio sql 1]..CovidDeaths
group by continent
order by totaldeathcount desc


-- global numbers
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/SUM(new_cases) *100 as deathpercentage
from [portfolio sql 1]..CovidDeaths


--total population vs new vaccination
select a.continent,a.location,a.date,a.population,b.new_vaccinations
from [portfolio sql 1]..CovidDeaths a
join [portfolio sql 1]..CovidVaccinations$ b
on a.location=b.location
and a.date=b.date
where b.new_vaccinations is not null


--using cte
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.Location Order by a.location, a.Date) as RollingPeopleVaccinated
From [portfolio sql 1]..CovidDeaths a
Join  [portfolio sql 1]..CovidVaccinations$ b
	On a.location = b.location
	and a.date = b.date
where a.continent is not null )
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



