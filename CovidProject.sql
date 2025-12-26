SELECT DB_NAME() AS CurrentDatabase;
USE portfolioproject;
GO

select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4;


-- Data I'll be using
select 
location, 
date, 
total_cases, 
new_cases, 
total_deaths, 
population
from PortfolioProject.dbo.CovidDeaths
order by 1,2;

-- Total Cases vs Total Deaths
-- Likelihood of dying of Covid in US
select location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2;

-- Total Cases vs Population
-- Percentage of population that got Covid
select location,
date,
population,
total_cases,
(total_cases/population)*100 as percent_population_infected
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries w/highest infection rate compared to population.
select location,
population, 
max(total_cases) as highest_infection_count,
max((total_cases/population))*100 as percent_population_infected
from PortfolioProject.dbo.CovidDeaths
-- Where location like '%states%'
group by location, population
order by percent_population_infected desc

-- Countries w/highest death count per population
select location,
max(cast(total_deaths as int)) as total_death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by total_death_count desc


-- By Continent
-- Continents w/highest death counts
select continent,
max(cast(total_deaths as int)) as total_death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by total_death_count desc;

-- Global numbers
select
date,
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


-- Population vs Vaccinations (temp table vs cte)

-- Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated

select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *,
(rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated;

-- Cte
with PopvsVac (continent,
location,
date,
population,
newvaccinations,
rollingpeoplevaccinated
)
as
(select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null) 

select *,
(rollingpeoplevaccinated/population)*100
from PopvsVac;



-- Creating a view
GO
drop view if exists PercentPopulationVaccinated;
GO
	
GO
create view PercentPopulationVaccinated as 
select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
GO
	
select * from PercentPopulationVaccinated

select * from INFORMATION_SCHEMA.columns
where table_name =  'PercentPopulationVaccinated';

SELECT * 
FROM INFORMATION_SCHEMA.TABLES;
