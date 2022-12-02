USE	PortfolioProject

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 AS Death_percentage
FROM CovidDeaths
WHERE location LIKE '%States'
ORDER BY 1,2; 

SELECT location, date, total_cases, population,ROUND((total_cases/population)* 100, 2) AS Cases_per_capita
FROM CovidDeaths
WHERE location LIKE '%States'
ORDER BY 1,2; 

-- Countries with the highest infection rates.

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))* 100 AS Cases_per_capita
FROM CovidDeaths
GROUP BY location, population
ORDER BY Cases_per_capita desc

-- Countries with the highest deaths by population.

SELECT location, population, MAX(cast(total_deaths as int)) AS total_deaths, MAX((cast(total_deaths as int)/population))* 100 AS Deaths_per_capita
FROM CovidDeaths
GROUP BY location, population
ORDER BY Deaths_per_capita desc

-- Countries with the highest deaths by population.

SELECT location, MAX(cast(total_deaths as int)) AS total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths desc

-- BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL and location NOT LIKE '%income'
GROUP BY continent
ORDER BY total_deaths desc

-- LIKELIHOOD OF DYING IF CONTRACTED COVID

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 AS Death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--SUM OF NEW CASES

SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

SELECT *
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date 


SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- SUM OF NEW VACCINATIONS WITH PARTITION BY

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/cd.population
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

-- USE A CTE

With PopVsVac (Continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/cd.population)*100
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- TEMP TABLE

DROP TABLE if Exists #PercentPopulationVaccinated

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
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/cd.population)*100
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Create view

CREATE VIEW PercentPopulationVaccinated as

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/cd.population)*100
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated