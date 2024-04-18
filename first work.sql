SELECT *
FROM PortfolioProject..coviddeaths
Where continent is not null
order by 3,4

SELECT *
FROM PortfolioProject..[covid-vacin]
Where continent is not null
and new_vaccinations is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..covidvaccination
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..coviddeaths
Where continent is not null
order by 1,2

--SELECT total_cases, total_deaths, CAST(total_deaths as decimal(12,0))/total_cases
--FROM PortfolioProject..coviddeaths
--order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, CAST(total_deaths as decimal(12,0))/total_cases*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
where location like '%states'
order by date


SELECT location, date, total_cases, total_deaths, CAST(total_deaths as decimal(12,0))/total_cases*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
where location like '%NIGERIA%'
order by date


--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
 SELECT location, date, total_cases, population, (total_cases/population)* 100 as Percentpopulationinfected
FROM PortfolioProject..coviddeaths
--where location like '%states'
order by 1,2

--looking at countries with highest infection rate compared to population
 SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))* 100 as Percentpopulationinfected
FROM PortfolioProject..coviddeaths
--where location like '%states'
GROUP BY location, population
order by Percentpopulationinfected desc



--looking at countries with highest death count per population
--SELECT location, MAX(total_deaths) as HighestdeathCount, population, MAX((total_deaths/population))* 100 as Percentpopulationdead
--FROM PortfolioProject..coviddeaths
----where location like '%states'
--GROUP BY location, population
--order by Percentpopulationdead desc


SELECT location, MAX(cast(total_deaths as int)) as HighestdeathCount
FROM PortfolioProject..coviddeaths
--where location like '%states'
Where continent is not null
GROUP BY location
order by HighestdeathCount desc

--by continent
SELECT location, MAX(cast(total_deaths as int)) as HighestdeathCount
FROM PortfolioProject..coviddeaths
--where location like '%states'
Where continent is null
GROUP BY location
--group by location
order by HighestdeathCount desc

SELECT continent, MAX(cast(total_deaths as int)) as HighestdeathCount
FROM PortfolioProject..coviddeaths
--where location like '%states'
Where continent is not null
GROUP BY continent
--group by location
order by HighestdeathCount desc


--continent with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as HighestdeathCount
FROM PortfolioProject..coviddeaths
--where location like '%states'
Where continent is null
GROUP BY location
--group by location
order by HighestdeathCount desc


---global number
SELECT date, SUM(new_cases),  SUM(new_deaths) --, total_cases, total_deaths, CAST(total_deaths as decimal(12,0))/total_cases*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
--where location like '%states'
Where continent is not null
group by date
order by 1,2

--SELECT date, SUM(CAST(new_cases as decimal(12,0))),  SUM(CAST(new_deaths as decimal(12,0))), SUM(CAST(new_deaths as decimal(12,0)))/SUM(CAST(new_cases as decimal(12,0)))*100 AS DEATHPERCENTAGE
--FROM PortfolioProject..coviddeaths
----where location like '%states'
--Where continent is not null
--group by date
--order by 1,2

--total population vs vaccination

select covidvaccination.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccination.new_vaccinations
, SUM(CAST(covidvaccination.new_vaccinations as int)) OVER (Partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Vaccinetotal
, (Vaccinetotal/population)*100
from covidvaccination
--from [covid-vacin]
join coviddeaths
    on covidvaccination.location = coviddeaths.location
	and covidvaccination.date = coviddeaths.date
Where coviddeaths.continent is not null
 and covidvaccination.new_vaccinations is not null
order by  2, 3


---USE CTE
with popvsvac (continent, location, date, population, new_vaccinations, Vaccinetotal)
as 
(
select covidvaccination.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccination.new_vaccinations
, SUM(CAST(covidvaccination.new_vaccinations as int)) OVER (Partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Vaccinetotal
--, (Vaccinetotal/population)*100
from covidvaccination
--from [covid-vacin]
join coviddeaths
    on covidvaccination.location = coviddeaths.location
	and covidvaccination.date = coviddeaths.date
Where coviddeaths.continent is not null
 and covidvaccination.new_vaccinations is not null
--order by  2, 3
)
SELECT *, (Vaccinetotal/population)*100
FROM popvsvac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Vaccinetotal numeric
)

insert into #PercentPopulationVaccinated
select covidvaccination.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccination.new_vaccinations
, SUM(CAST(covidvaccination.new_vaccinations as int)) OVER (Partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Vaccinetotal
--, (Vaccinetotal/population)*100
from covidvaccination
--from [covid-vacin]
join coviddeaths
    on covidvaccination.location = coviddeaths.location
	and covidvaccination.date = coviddeaths.date
Where coviddeaths.continent is not null
 and covidvaccination.new_vaccinations is not null
--order by  2, 3

SELECT *, (Vaccinetotal/population)*100
FROM #PercentPopulationVaccinated