
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Project]..CovidDeaths
ORDER BY location, date;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in Singapore

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [Covid Project]..CovidDeaths
WHERE location = 'Singapore'
ORDER BY location, date;

-- Looking at Total Cases vs Population
-- Shows what percentage of population of Singapore contracted Covid

SELECT location, date, population,total_cases, (total_cases/population)*100 AS Infection_Rate
FROM [Covid Project]..CovidDeaths
WHERE location = 'Singapore'
ORDER BY location, date;

-- Looking at top 10 countries with highest infection rate compared to population

SELECT TOP (10) location, population,MAX(total_cases) AS Highest_Infection_Count, (MAX(total_cases)/population)*100 AS Infection_Rate
FROM [Covid Project]..CovidDeaths
GROUP BY location,population
ORDER BY Infection_Rate DESC ;

-- Looking at top 10 countries with highest death count

SELECT TOP (10) location,MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC ;

-- Looking at continents and their respective death count 

SELECT continent,MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC ;

-- Looking at total cases, total deaths and death percentage for the entire world with respect to dates

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Looking at total cases, total deaths and death percentage for the entire world in total up till 18 May 2022

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM [Covid Project]..CovidDeaths
WHERE continent IS NOT NULL;

-- Looking at Total Population vs Vaccinations in Singapore till 18 May 2022

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM [Covid Project].dbo.CovidDeaths dea
JOIN [Covid Project].dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL) 
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac
WHERE location = 'Singapore'