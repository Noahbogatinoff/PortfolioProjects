USE PortfolioProject_COVID;


-- Change date column to a date data type for both tables

UPDATE covid_death
SET date = STR_TO_DATE(date, '%m/%d/%Y');

UPDATE covid_vac
SET date = STR_TO_DATE(date, '%m/%d/%Y');


-- Select the intial data we want to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_death
ORDER BY 1,2;


-- COMPARING COUNTRIES -- 

-- View Total Cases vs Total Deaths
-- Shows likeliehood of dying if COVID is contracted

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM covid_death
WHERE location LIKE '%states%'
ORDER BY 1,2;


-- View Total Cases vs Population
-- Shows what percentage of the population contracted COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS ContractionRate
FROM covid_death
-- WHERE location LIKE '%states%'
ORDER BY 1,2;


-- View what countries have the highest Contraction Rate

SELECT location, population, MAX(total_cases) AS HighestCaseCount, 
	MAX((total_cases/population)*100) AS ContractionRate
FROM covid_death
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY ContractionRate DESC;


-- View what countries have the highest Death count per population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount, 
	MAX((total_deaths/population)*100) AS DeathRatePop
FROM covid_death
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- COMPARING CONTINENTS -- 


-- View continents with highest death count

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount, 
	MAX((total_deaths/population)*100) AS DeathRatePop
FROM covid_death
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS --

SELECT SUM(new_cases) AS 'Total Cases', 
	SUM(CAST(new_deaths AS SIGNED)) AS 'Total Deaths' ,
    SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathRate
FROM covid_death
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;


-- View Total Population vs Total Vaccinations
-- Shows percentage of people in each country who have received the COVID vaccine

SELECT dea.continent, 
	dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinated
FROM covid_death dea
JOIN covid_vac vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- Create CTE to display rolling count of the total number of vaccinated people per population

WITH PopvsVac (continent, location,date,population,new_vaccinations,RollingVaccinated)
AS (SELECT dea.continent, 
	dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinated
FROM covid_death dea
JOIN covid_vac vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinated/population)*100 AS 'Percentage of Population Vaccinated'
FROM PopvsVac;


-- Create table to perform calculations on 'RollingVaccinated' from previous query

DROP TABLE IF EXISTS percent_pop_vac;
CREATE TABLE percent_pop_vac
	(continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingVaccinated NUMERIC
    );
    
INSERT INTO percent_pop_vac
SELECT dea.continent, 
	dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinated
FROM covid_death dea
JOIN covid_vac vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2,3

SELECT *, (RollingVaccinated/population)*100 AS 'Percent Vaccinated'
FROM percent_pop_vac;


-- Create view to store data for later visualizations in Tableau

CREATE VIEW percent_pop_vac_v AS 
SELECT dea.continent, 
	dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinated
FROM covid_death dea
JOIN covid_vac vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2,3

CREATE VIEW continent_death_count AS
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount, 
	MAX((total_deaths/population)*100) AS DeathRatePop
FROM covid_death
WHERE continent IS NULL
GROUP BY location;
-- ORDER BY TotalDeathCount DESC;

CREATE VIEW country_dc_pop AS
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount, 
	MAX((total_deaths/population)*100) AS DeathRatePop
FROM covid_death
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
