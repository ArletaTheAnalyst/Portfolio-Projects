SELECT *
FROM PortfolioProject..Covid_deaths
order by 3,4

--SELECT *
--FROM PortfolioProject..Covid_vaccinations
--order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_deaths
WHERE continent is not NULL
order by 1,2


SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..Covid_deaths
WHERE location like 'Poland'
order by 1,2

SELECT location, date, population, total_cases, (total_cases/population)*100 as GotCovidpercentage
FROM PortfolioProject..Covid_deaths
WHERE location like 'Poland'
order by 1,2


SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 as GotCovidpercentage
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Poland'
WHERE continent is not NULL
GROUP BY Location, Population
order by GotCovidpercentage desc


SELECT Location, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Poland'
WHERE continent is not NULL
GROUP BY Location
order by totaldeathcount desc



SELECT location, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Poland'
WHERE continent is NULL
GROUP BY location
order by totaldeathcount desc


SELECT continent, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Poland'
WHERE continent is not NULL
GROUP BY continent
order by totaldeathcount desc




SELECT SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 as deathpercentage
FROM PortfolioProject..Covid_deaths
--WHERE location like 'Poland'
--and new_deaths > '0' 
WHERE continent is not NULL 
--GROUP BY Date
order by 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3


WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

 
DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated