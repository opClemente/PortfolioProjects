

SELECT *
FROM PortfolioProjects.dbo.CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProjects.dbo.CovidVaccinations
ORDER BY 3,4

-- SELECT DATA I'LL BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects.dbo.CovidDeaths
ORDER BY 1, 2

-- look at total cases vs total deaths.
-- likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- total cases vs population f
-- shows percent of pop that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProjects.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- showing countries with highest death count per population
SELECT location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotaldeathCount desc;

-- SHOWING CONTINENTS WITH HGIHEST DEATHCOUNT PER POPULATION
SELECT location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotaldeathCount desc

SELECT continent, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount desc

-- global numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, SUM(CAST(New_deaths AS INT))/SUM(New_cases) AS DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;


-- looking at total population vs vaccinations 


SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location order by DEA.LOCATION, DEA.dATE) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths AS dea
Join PortfolioProjects.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location order by DEA.LOCATION, DEA.dATE) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths AS dea
Join PortfolioProjects.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location order by DEA.LOCATION, DEA.dATE) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths AS dea
Join PortfolioProjects.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--order by 2,3

-- Creating view to store data for later visualizations
USE PortfolioProjects
GO
CREATE VIEW PercentPopulationVaccinated AS

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location order by DEA.LOCATION, DEA.dATE) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths AS dea
Join PortfolioProjects.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated

