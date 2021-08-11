/*
Covid 19 Data Exploration 

Skills used: Import tables with the correct data type, Aggregate Functions, Joins, CTE's, Temp Tables, Creating Views
*/

-- Check with Deaths table
SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

-- Select Data that we want to start 
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
AND location ILIKE '%states%'
ORDER BY 1,2


-- Checking US Death rate status
SELECT location, date, total_cases, total_deaths, MAX((total_deaths/total_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
AND location ILIKE '%states%'
GROUP BY location, date, total_cases, total_deaths
ORDER BY DeathPercentage DESC

/* Death rate rised rapidly in 2020 in US, reached the highest point (6.25%) in May and begin to fall back, 
and stabilize at around 1.7% at the end of 2020
*/

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL 
AND location ILIKE '%states%'
order by 1,2

/* US population is around 331 million, total cases is around 35.9 million
The percentage of the population currently infected totals about 10.8% in US 
*/

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing location with the highest cases count and death count per population
SELECT continent, location, MAX(total_cases) AS TotalCasesCount, MAX(Total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent, location
ORDER BY 1,4


-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND(SUM(new_deaths)/SUM(New_Cases)*100,4) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 

-- review the Vaccinations table
SELECT * 
FROM CovidVaccinations
ORDER BY 3,4

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5


-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated(
Continent VARCHAR(255),
Location VARCHAR(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
From PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3,4,5

-- Check the View
SELECT * FROM PercentPopulationVaccinated





