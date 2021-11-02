USE PortfolioProject;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
ORDER BY 1,2;

#Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, new_cases, total_deaths, ROUND((total_deaths/total_cases)*100,1) AS 'Death_Percentage'
FROM Covid_Deaths
where location LIKE '%states%'
ORDER BY 1,2;

#Looking at Total Cases vs Population. 
#Shows what percentage of population got Covid
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,1) AS 'Percent_Population_Infected'
FROM Covid_Deaths
where location LIKE '%states%'
ORDER BY 1,2;

#Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS 'Highest_Infection_Count', ROUND(MAX((total_cases/population))*100,1) AS 'Percent_Population_Infected'
FROM covid_deaths
group by location, population
ORDER BY Percent_Population_Infected DESC;

#Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as SIGNED)) as 'Total_Death_Count'
FROM covid_deaths
WHERE continent IS NOT NULL
group by location
ORDER BY Total_Death_Count DESC;

#Showing Continents with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as SIGNED)) as 'Total_Death_Count'
FROM covid_deaths
WHERE continent IS NOT NULL
group by continent
ORDER BY Total_Death_Count DESC;

#Showing Global Numbers by date
SELECT date, SUM(new_cases) as 'Total_Cases', SUM(cast(new_deaths as SIGNED)) as 'Total_Deaths', 
ROUND(SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100,1) as 'Death_Percentage'
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

#Showing Global Number in Total, Across the World
SELECT SUM(new_cases) as 'Total_Cases', SUM(cast(new_deaths as SIGNED)) as 'Total_Deaths', 
ROUND(SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100,1) as 'Death_Percentage'
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

#USE CTE
WITH PopvsVac (continent, location, population, vew_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT d.continent, d.location, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as SIGNED)) OVER (Partition by d.location ORDER BY d.location) AS 'Rolling_People_Vaccinated'
#('Rolling_People_vaccinated'/population)*100
FROM covid_deaths d
JOIN covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
#ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopvsVac;

#Looking at Total Populations vs Vaccinations
WITH PopvsVac (continent, location, population, vew_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT d.continent, d.location, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as SIGNED)) OVER (Partition by d.location ORDER BY d.location) AS 'Rolling_People_Vaccinated'
#('Rolling_People_vaccinated'/population)*100
FROM covid_deaths d
JOIN covid_vaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
#ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopvsVac;

#TEMP TABLE
DROP Table if exists Percent_Population_Vaccinated;
CREATE table Percent_Population_Vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date varchar(255),
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
);
INSERT INTO Percent_Population_Vaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as SIGNED)) OVER (Partition by d.location order by d.location, d.date) as 'Rolling_People_Vaccinated'
#Rolling_People_Vaccinated/population)*100
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL;
#ORDER BY 2,3

#Creating View to store data for later visualizations
CREATE VIEW Percent_Population_Vaccinated as 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations as SIGNED)) OVER (Partition by d.location order by d.location, d.date) as 'Rolling_People_Vaccinated'
#Rolling_People_Vaccinated/population)*100
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL;
#ORDER BY 2,3

CREATE VIEW Continents_with_the_highest_Mortality_Rate as 
SELECT continent, MAX(cast(total_deaths as SIGNED)) as 'Total_Death_Count'
FROM covid_deaths
WHERE continent IS NOT NULL
group by continent
ORDER BY Total_Death_Count DESC;

CREATE VIEW Countries_with_the_highest_Mortality_Rate as
SELECT location, MAX(cast(total_deaths as SIGNED)) as 'Total_Death_Count'
FROM covid_deaths
WHERE continent IS NOT NULL
group by location
ORDER BY Total_Death_Count DESC;












