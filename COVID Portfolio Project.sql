SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of the Population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2;


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC;


-- Showing Countries with the Highest Death Count

SELECT Location, Max(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



-- Showing continents with the highest death count

SELECT location, Max(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Global Totals
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations, 

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--Using CTE

WITH PopvsVax (Continent, location, date, population, new_vaccinations, RollingVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinations/population)*100
FROM PopvsVax;

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
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date

SELECT *, (RollingVaccinations/population)*100
FROM #PercentPopulationVaccinated;


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(int,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;
