SELECT * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what Percentage of population got covid

SELECT Location, date, population, total_cases,(total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
--Where location like'%egypt%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
--Where location like'%egypt%'
Group by Location, population
order by CasesPercentage desc



-- Showing Countries with Higest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%egypt%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%egypt%'
Where continent is null
Group by location
order by TotalDeathCount desc

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%egypt%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%egypt%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int)) /SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like'%states%'
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3 
)
select * , (RollingPeopleVaccinated/Population)*100 as RollPerct
from PopvsVac





-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select * , (RollingPeopleVaccinated/Population)*100 as RollPerct
from #PercentPopulationVaccinated


-- Creating View To Store data for later Visualizations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select * 
from PercentPopulationVaccinated
