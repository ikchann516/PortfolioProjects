SELECT * 
FROM PortfolioProject..MyCovidDeaths
--Where continent is not null
ORDER BY 3, 4

SELECT * 
FROM PortfolioProject..MyCovidVaccinations
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..MyCovidDeaths
ORDER BY 1, 2

--Total Cases vs Total Deaths
--Chances of dying if contract covid
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS deaths_percentage
FROM PortfolioProject..MyCovidDeaths
Where location = 'Malaysia'
ORDER BY 1, 2

--Total Cases vs Population
--Chances to getting covid in Malaysia
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS covid_percentage
From PortfolioProject..MyCovidDeaths
WHERE location = 'Malaysia'
ORDER BY 1, 2

--Countries with the highest covid rate
SELECT location, population, MAX(total_cases) AS highest_covid_count, MAX(ROUND((total_cases/population)*100,2)) AS covid_percentage
FROM PortfolioProject..MyCovidDeaths
GROUP BY location, population
ORDER BY covid_percentage DESC

--Countries with the highest death count
SELECT location, MAX(cast(total_deaths AS int)) AS highest_total_deaths_count
FROM PortfolioProject..MyCovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY highest_total_deaths_count DESC

--Death count by continent #The numbers is incorrect for this
SELECT continent, MAX(cast(total_deaths AS int)) AS highest_total_deaths_count
FROM PortfolioProject..MyCovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY highest_total_deaths_count DESC

--This is the correct one
SELECT location, MAX(cast(total_deaths AS int)) AS highest_total_deaths_count
FROM PortfolioProject..MyCovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY highest_total_deaths_count DESC

--Global Numbers
--Daily Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, ROUND(SUM(cast(new_deaths AS int))/SUM(new_cases)*100,2) AS deaths_percentage
FROM PortfolioProject..MyCovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--Total Numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, ROUND(SUM(cast(new_deaths AS int))/SUM(new_cases)*100,2) AS deaths_percentage
FROM PortfolioProject..MyCovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS people_vaccinated
--, (people_vaccinated/dea.population) as population_vaccinated #can't use column that was just created
FROM PortfolioProject..MyCovidDeaths dea
JOIN PortfolioProject..MyCovidVaccinations vac
	ON dea.location = vac .location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--Use CTE
With PopVsVac(Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM PortfolioProject..MyCovidDeaths dea
JOIN PortfolioProject..MyCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date	
WHERE dea.continent is not null
)
SELECT *, ROUND((People_Vaccinated/Population) * 100,2) AS Percent_People_Vaccinated
FROM PopVsVac
WHERE Location = 'Malaysia'

--TEMP Table
DROP TABLE IF EXISTS #PercentPeopleVaccinated --In case the table already exists
CREATE TABLE #PercentPeopleVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
People_Vaccinated NUMERIC
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM PortfolioProject..MyCovidDeaths dea
JOIN PortfolioProject..MyCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date	
WHERE dea.continent is not null

SELECT *, ROUND((People_Vaccinated/Population) * 100,2) AS Percent_People_Vaccinated
FROM #PercentPeopleVaccinated
Where Location = 'Malaysia'

--Create View to store data for visualizations
DROP VIEW IF EXISTS PercentPeopleVaccinated

CREATE VIEW PercentPeopleVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM PortfolioProject..MyCovidDeaths dea
JOIN PortfolioProject..MyCovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date	
WHERE dea.continent is not null

SELECT *
FROM PercentPeopleVaccinated
Where Location = 'Malaysia'

CREATE VIEW DeathCountByContinent
as
SELECT location, MAX(cast(total_deaths AS int)) AS highest_total_deaths_count
FROM PortfolioProject..MyCovidDeaths
WHERE continent is null
GROUP BY location

SELECT *
FROM DeathCountByContinent
ORDER BY 2 DESC

CREATE VIEW DailyCovidNumbers
as
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, ROUND(SUM(cast(new_deaths AS int))/SUM(new_cases)*100,2) AS deaths_percentage
FROM PortfolioProject..MyCovidDeaths
WHERE continent is not null
GROUP BY date

SELECT *
FROM DailyCovidNumbers
ORDER BY 1, 2

CREATE VIEW CountriesCovidRate
as
SELECT location, population, MAX(total_cases) AS highest_covid_count, MAX(ROUND((total_cases/population)*100,2)) AS covid_percentage
FROM PortfolioProject..MyCovidDeaths
GROUP BY location, population

SELECT *
FROM CountriesCovidRate
ORDER BY covid_percentage DESC
