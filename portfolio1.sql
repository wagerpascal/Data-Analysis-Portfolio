
select *
from PortfolioProject..coviddeaths
where continent = ''



select *
from PortfolioProject..covidvaccinations
order by 3,4

select location, date, total_cases, new_cases,total_deaths, population 
from PortfolioProject..coviddeaths
where population = 0
order by 1,2

-- total cases vs. total deaths
select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as death_percentage
from PortfolioProject..coviddeaths
--where location like '%states%'
order by 1,2

-- total cases vs. population 4.

select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/NULLIF(population,0)))*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location like '%states%'
Group by location, population, date
order by PercentPopulationInfected desc

-- countries with highest infection rates 3.
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/NULLIF(population,0)))*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected DESC

-- Countries with highest death count per population
select location, SUM(total_deaths) as totalDeathcount
from PortfolioProject..coviddeaths
where continent != '' and location not in ('World', 'European Union', 'International')
--where location like '%states%'
group by location
order by totalDeathcount DESC

-- breakdown by continent 2.
select continent, SUM(total_deaths) as totalDeathcount
from PortfolioProject..coviddeaths
where continent != '' and location not in ('World', 'European Union', 'International')
--where location like '%states%'
group by continent
order by totalDeathcount DESC

-- Global Numbers 1.
select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,(SUM(new_deaths)/NULLIF(SUM(new_cases),0)) * 100 as DeathPercentage--, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as death_percentage
from PortfolioProject..coviddeaths
where continent != ''
--group by date
--where location like '%states%'
order by 1,2

--total pop vs. vaccinations


With PopvsVac (Continent, Location , Date, Population, New_Vaccinations, RollVacs) 
AS(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER by dea.location,dea.date) as RollingVacs
from PortfolioProject..coviddeaths as dea
JOIN PortfolioProject..covidvaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
where dea.continent != ''
)

select *, (RollVacs/NULLIF(Population,0))*100 from PopvsVac


-- Creating temp table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVacs numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, CONVERT(bigint,vac.new_vaccinations), SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER by dea.location,dea.date) as RollingVacs
from PortfolioProject..coviddeaths as dea
JOIN PortfolioProject..covidvaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
where dea.continent != ''

select *, (RollingVacs/NULLIF(Population,0))*100 from #PercentPopulationVaccinated

--Creating View
Create View PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER by dea.location,dea.date) as RollingVacs
from PortfolioProject..coviddeaths as dea
JOIN PortfolioProject..covidvaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
where dea.continent != ''