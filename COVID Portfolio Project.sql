SELECT * FROM CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT * FROM CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(decimal,total_deaths)/CONVERT(decimal,total_cases))*100 as DeathPercentage
From CovidDeaths
Where location like '%colombia'
and continent is not null
Order by 1,2


-- Looking at Total cases vs population
-- Shows what percentage of population got Covid
Select Location, date, population, total_cases, (CONVERT(decimal,total_cases)/CONVERT(decimal,population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%colombia'
Order by 1,2



-- Looking at Countries with Highest Infection Rate compared to population
Select Location, population, MAX(CONVERT(decimal,total_cases)) as HighestInfectionCount, MAX((CONVERT(decimal,total_cases)/CONVERT(decimal,population)))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%colombia'
Group by Location, population
Order by PercentPopulationInfected desc


-- Looking at countries with highest deathcount per population
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From CovidDeaths
--Where location like '%colombia'
where continent is not null
Group by Location
Order by TotalDeathCount desc


-- Lets break things down by continent


-- Showing continent with highest death count per population

Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From CovidDeaths
--Where location like '%colombia'
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, 
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From CovidDeaths
--Where location like '%colombia'
Where continent is not null
--Group by date
--Having SUM(cast(new_deaths as float)) > 0
Order by 1,2



-- Looking at total population vs Vaccinations

Select de.continent, de.location, de.date, population, va.new_vaccinations,
SUM(CONVERT(float,va.new_vaccinations)) OVER (Partition by de.location Order by de.location, de.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths de
Join CovidVaccinations va
	ON de.location = va.location
	and de.date = va.date
Where de.continent is not null
order by 2,3


-- USE CTE
With PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select de.continent, de.location, de.date, population, va.new_vaccinations,
SUM(CONVERT(float,va.new_vaccinations)) OVER (Partition by de.location Order by de.location, de.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths de
Join CovidVaccinations va
	ON de.location = va.location
	and de.date = va.date
Where de.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac



-- Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select de.continent, de.location, de.date, population, va.new_vaccinations,
SUM(CONVERT(float,va.new_vaccinations)) OVER (Partition by de.location Order by de.location, de.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths de
Join CovidVaccinations va
	ON de.location = va.location
	and de.date = va.date
Where de.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select de.continent, de.location, de.date, population, va.new_vaccinations,
SUM(CONVERT(float,va.new_vaccinations)) OVER (Partition by de.location Order by de.location, de.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths de
Join CovidVaccinations va
	ON de.location = va.location
	and de.date = va.date
Where de.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated