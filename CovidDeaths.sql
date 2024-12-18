SELECT *
FROM `CovidPortfolioProject`.`coviddeaths`
WHERE continent is not null
ORDER BY 3,4;

SELECT *
FROM `CovidPortfolioProject`.`covidvaccinations`;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `CovidPortfolioProject`.`coviddeaths`
ORDER BY 1,2;

# Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM `CovidPortfolioProject`.`coviddeaths`
WHERE location LIKE '%states%'
ORDER BY 1,2;

# Looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS PercentPopulationInfected
FROM `CovidPortfolioProject`.`coviddeaths`
WHERE location LIKE '%states%'
ORDER BY 1,2;

# Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM `CovidPortfolioProject`.`coviddeaths`
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

# Looking at countries with highest death count per population

UPDATE `CovidPortfolioProject`.`coviddeaths`
SET total_deaths = NULLIF(total_deaths, '');

ALTER TABLE `CovidPortfolioProject`.`coviddeaths`
MODIFY COLUMN total_deaths INT;

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `CovidPortfolioProject`.`coviddeaths`
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

# Breaking things down by continent

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM `CovidPortfolioProject`.`coviddeaths`
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

# Global numbers

UPDATE `CovidPortfolioProject`.`coviddeaths`
SET new_deaths = NULLIF(new_deaths, '');

ALTER TABLE `CovidPortfolioProject`.`coviddeaths`
MODIFY COLUMN new_deaths INT;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `CovidPortfolioProject`.`coviddeaths`
ORDER BY 1,2;

# Looking at total population vs vaccinations

UPDATE `CovidPortfolioProject`.`covidvaccinations`
SET new_vaccinations = NULLIF(new_vaccinations, '');

ALTER TABLE `CovidPortfolioProject`.`covidvaccinations`
MODIFY COLUMN new_vaccinations INT;

# Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `CovidPortfolioProject`.`coviddeaths` dea
JOIN `CovidPortfolioProject`.`covidvaccinations` vac
	ON dea.location = vac.location
    AND dea.date = vac.date
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVAC;

# Temp table

CREATE TABLE `CovidPortfolioProject`.`PercentPopulationVaccinated`
(
continent nvarchar(255),
location nvarchar(255),
date text,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO `CovidPortfolioProject`.`PercentPopulationVaccinated`
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `CovidPortfolioProject`.`coviddeaths` dea
JOIN `CovidPortfolioProject`.`covidvaccinations` vac
	ON dea.location = vac.location
    AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM `CovidPortfolioProject`.`PercentPopulationVaccinated`;

# Creating view to store data for later visualizations

Create VIEW PercentPopulationVaccinatedView as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `CovidPortfolioProject`.`coviddeaths` dea
JOIN `CovidPortfolioProject`.`covidvaccinations` vac
	ON dea.location = vac.location
    AND dea.date = vac.date;
























