SELECT *
FROM portfolioproject.dbo.CovidDeaths
ORDER BY 3, 4


SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3, 4

--Select the crucial Columns that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date

--Calculating the Death Percentage Against the total cases
--This shows the probability of deaths amongst the people who contracted Covid-19 in Kenya

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kenya%'
ORDER BY location, date

--Calculating the Total Covid-19 cases against the Country's popualation
--This outputs the percenatge Kenyan population that contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 As Contracted_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kenya%'
and Continent IS NOT NULL
ORDER BY location, date
--Countries with highest Covid infection rates Against the population

SELECT location, population, MAX (total_cases) AS HighestInfectionCount, MAX ((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY 4 DESC

--Countries with the highest Death Count Per population

SELECT location, MAX (total_deaths) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2  DESC

--The above Query outputs an error (The HighestDeathCount) does not appear in DESC order as required
--On the next Step I Cast the aggregate function (MAX (total_deaths) As an integer (CAST as Int)

SELECT location, MAX(CAST (total_deaths as Int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2  DESC


--Finding the Continents with the highest death count

SELECT continent, MAX(CAST (total_deaths as Int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2  DESC

---EXPLORING GLOBAL NUMBERS
--This is per day (I grouped by date)
SELECT date, SUM(new_cases) As Total_Cases, SUM (CAST(new_deaths AS int)) As Total_deaths, SUM(CAST(new_deaths AS int))/SUM (new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

---NUMBERS ACCROSS THE GLOBE (The Total without grouping by Date)

SELECT SUM(new_cases) As Total_Cases, SUM (CAST(new_deaths AS int)) As Total_deaths, SUM(CAST(new_deaths AS int))/SUM (new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


---COVID VACCINATIONS TABLE
SELECT *
FROM PortfolioProject.dbo.CovidVaccinations 

---JOINING THE COVID DEATHS TABLE AND COVID VACCINATIONS TABLE
SELECT *
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vaccs
	ON dea.location = Vaccs.location
	AND dea.date = Vaccs.date

--Looking at the Total Global Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,Vaccs.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vaccs
	ON dea.location = Vaccs.location
	AND dea.date = Vaccs.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3

---USING PARTITION BY

SELECT dea.continent, dea.location, dea.date, dea.population,Vaccs.new_vaccinations, SUM(CONVERT (int, Vaccs.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingCount
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vaccs
	ON dea.location = Vaccs.location
	AND dea.date = Vaccs.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3


---TO CALCULATE Total Global Population VS Vaccinations 

---(USING A TEMP TABLE)

DROP TABLE if EXISTS #PercentPopVaccs
CREATE TABLE #PercentPopVaccs
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingCount numeric
)
INSERT INTO #PercentPopVaccs
SELECT dea.continent, dea.location, dea.date, dea.population,Vaccs.new_vaccinations, SUM(CONVERT (int, Vaccs.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingCount
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vaccs
	ON dea.location = Vaccs.location
	AND dea.date = Vaccs.date
WHERE Dea.continent IS NOT NULL

SELECT *, (RollingCount/population)*100
FROM #PercentPopVaccs

--The Temporaty Table name is (#PercentPopVaccs)

---(USING A CTE)

With PopVaccs (Continent, location, date, population, new_vaccinations, RollingCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,Vaccs.new_vaccinations, SUM(CONVERT (int, Vaccs.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingCount
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vaccs
	ON dea.location = Vaccs.location
	AND dea.date = Vaccs.date
WHERE Dea.continent IS NOT NULL
)
SELECT *, (RollingCount/population)*100
FROM PopVaccs

--The new CTE is PopVaccs

---CREATE VIEW TO STORE USEFUL DATA FOR VISUALIZATION

CREATE VIEW PercentPopVaccs 
AS
SELECT dea.continent, dea.location, dea.date, dea.population,Vaccs.new_vaccinations, SUM(CONVERT (int, Vaccs.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingCount
FROM PortfolioProject.dbo.CovidDeaths AS Dea
JOIN PortfolioProject.dbo.CovidVaccinations AS Vaccs
	ON dea.location = Vaccs.location
	AND dea.date = Vaccs.date
WHERE Dea.continent IS NOT NULL

