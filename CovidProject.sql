SELECT DB_NAME() AS CurrentDatabase;
USE portfolioproject;

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

-- data I'll be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- likelihood of dying of Covid in US

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
AND continent is not null
ORDER BY 1,2;

-- Total Cases vs Poplulation
-- Percentage of population that got Covid

SELECT location, date, total_cases, Population, (Total_Cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2;

-- Looking at Countries with Highest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, Population, Max((Total_Cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%state%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries w/highest death count per population

SELECT location, MAX(cast(Total_Deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- By Continent

-- continents w/highest death counts


SELECT location, MAX(cast(Total_Deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
----WHERE location like '%state%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- GLOBAL numbers

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.date) AS RollingPeopleVaccinated,
		--(rollingpeoplevaccinated/population)*100 AS
FROM PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- W/CTE

WITH PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.date) AS RollingPeopleVaccinated
		--(rollingpeoplevaccinated/population)*100 AS
FROM PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3
)

SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopvsVac


-- Temp Table



DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(25),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)




INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.date) AS RollingPeopleVaccinated
		--(rollingpeoplevaccinated/population)*100 AS
FROM PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated

ALTER TABLE #PercentPopulationVaccinated ALTER COLUMN Location NVARCHAR(255);

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view for data visualizations
DROP VIEW PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.date) AS RollingPeopleVaccinated
		--(rollingpeoplevaccinated/population)*100 AS
FROM PortfolioProject..CovidDeaths DEA
Join PortfolioProject..CovidVaccinations VAC
	on DEA.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PercentPopulationVaccinated';

SELECT * 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'PercentPopulationVaccinated';

select * from PercentPopulationVaccinated


