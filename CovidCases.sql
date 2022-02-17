SELECT
Location, date, total_cases, new_cases, total_deaths, population
FROM 
PortfolioProject..CovidDeaths$
Order by
1,2

--Total Cases vs Total Deaths Germany & USA (Wie wahrscheinlich ist es im Erkrankungsfall zu sterben)
SELECT 
Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE
Location LIKE '%states'
OR Location = 'Germany'
AND continent is not null
ORDER BY
1,2

--Total Cases vs Population Germany & USA (infection percentages)
SELECT
Location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
FROM 
PortfolioProject..CovidDeaths$
WHERE 
Location LIKE '%states'
OR Location = 'Germany'
AND continent is not null
ORDER BY
1,2

--Countries with Highest Infection Rate compared to Population 
SELECT
Location, MAX(total_cases) as HighestTotalCases, population, MAX((total_cases/population))*100 AS infection_percentage
FROM 
PortfolioProject..CovidDeaths$
WHERE 
continent is not null
GROUP BY 
Population, Location
ORDER BY
infection_percentage DESC

--Countries with Most deaths due to Covid compared to population 
SELECT
Location, MAX(cast(total_deaths as int)) as TotaldeathCount, population, MAX((total_deaths/population))*100 AS death_percentage
FROM 
PortfolioProject..CovidDeaths$
WHERE 
continent is not null
GROUP BY
Population, Location
ORDER BY
TotaldeathCount DESC

--Continents with Most deaths due to Covid BY CONTINENT

SELECT
continent, MAX(cast(total_deaths as int)) as TotaldeathCount
FROM 
PortfolioProject..CovidDeaths$
WHERE 
continent is not null
GROUP BY
continent
ORDER BY
TotaldeathCount DESC

-- Global Numbers per date

SELECT 
date, SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE
continent is not null
GROUP BY
date
ORDER BY
1,2

-- Total population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, SumOfVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS SumOfVaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

)
SELECT *, (SumOfVaccinations/Population)*100 AS PercentageOfPopulationVaccinated
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumOfVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS SumOfVaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
SELECT *, (SumOfVaccinations/Population)*100 AS PercentageOfPopulationVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store Data for later Visualizations
CREATE VIEW PercentageOfPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS SumOfVaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentageOfPopulationVaccinated
