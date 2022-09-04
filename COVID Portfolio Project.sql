select * 
from PortfolioProject..CovidDeaths
order by 3,4;

select * 
from PortfolioProject..CovidVaccinations
order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the Population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC


-- Showing Countries with the Highest Death Count

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Showing continents with the highest death count

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Numbers

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY date
order by 1,2

-- Global Totals
Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinations, 

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
ORDER BY 2,3


--Using CTE

WITH PopvsVax (Continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
)
SELECT *, (RollingVaccinations/population)*100
FROM PopvsVax

-- Using TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

INSERT #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date

SELECT *, (RollingVaccinations/population)*100
FROM #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated