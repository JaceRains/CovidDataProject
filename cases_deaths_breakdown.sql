SELECT * FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
ORDER BY 3, 4


-- Total Cases for United States

SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_percentage
FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
WHERE location LIKE '%states%'
ORDER BY 1, 2


-- Percentage of U.S. population that contracted Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS case_percentage
FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Ordering by highest rate of infection 

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS case_percentage
FROM [Covid-Data-Exploration].dbo.['Covid Deaths'] 
GROUP BY location, population 
ORDER BY case_percentage DESC

-- Countries by Highest death count

SELECT location, population, MAX((total_deaths/population))*100 AS death_percentage, MAX(cast(total_deaths AS int)) AS death_count
FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY death_count DESC


-- By Continent

SELECT continent, MAX((total_deaths/population))*100 AS death_percentage, MAX(cast(total_deaths AS int)) AS death_count
FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
WHERE continent IS NOT NULL AND population IS NOT NULL
GROUP BY continent
ORDER BY death_count DESC


-- Cases per population and deaths per population by continent 

SELECT continent, MAX(CAST(total_cases AS int)) AS cases, MAX(CAST(total_deaths AS int)) AS deaths, MAX((total_cases/population))*100 AS case_percentage, MAX((total_deaths/population))*100 AS death_percentage
FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY cases DESC


-- Total cases by country

SELECT location,  MAX(CAST(total_cases AS int)) AS cases
FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY cases DESC


-- Total deaths by country

SELECT location,  MAX(CAST(total_deaths AS int)) AS deaths
FROM [Covid-Data-Exploration].dbo.['Covid Deaths']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY deaths DESC


-- Global Statistics 

SELECT * 
FROM [Covid-Data-Exploration].dbo.['Covid Deaths'] dea
JOIN [Covid-Data-Exploration].dbo.['Covid Vaccinations'] vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Covid-Data-Exploration].dbo.['Covid Deaths'] dea
JOIN [Covid-Data-Exploration].dbo.['Covid Vaccinations'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_total
FROM [Covid-Data-Exploration].dbo.['Covid Deaths'] dea
JOIN [Covid-Data-Exploration].dbo.['Covid Vaccinations'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- TEMP TABLE

Create Table #PerOfPopVaccinated
( 
	Continent nvarchar(255), 
	Location nvarchar(255), 
	Date datetime, 
	Population numeric,
	New_vaccinations numeric, 
	rolling_vaccination_total numeric
)
	Insert into #PerOfPopVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination_total
FROM [Covid-Data-Exploration].dbo.['Covid Deaths'] dea
JOIN [Covid-Data-Exploration].dbo.['Covid Vaccinations'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT * FROM 
#PerOfPopVaccinated

