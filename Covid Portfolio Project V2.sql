Select *
From PortfolioProject.dbo.CovidDeaths$
order by 3,4;

--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

-- Select the data that will be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
order by 1,2

-- Total covid cases vs. Total Deaths
-- New Column "Death_percentage" shows how likely you are to die if you have covid depending on which country you live in (in this case specifically the United States)

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS Death_Percentage
From PortfolioProject.dbo.CovidDeaths$
Where location = 'United States'
order by 1,2

-- Total cases vs Population
-- How many people percentage wise got covid over time in the US

Select Location, date, total_cases, population, (total_cases/population)*100 AS covid_infection_rate
From PortfolioProject.dbo.CovidDeaths$
Where location = 'United States'
order by 1,2

-- Finding which countries have the highest infection rate when comparing it to their overall population

Select Location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 AS covid_infection_rate
From PortfolioProject.dbo.CovidDeaths$
group by population, location
order by covid_infection_rate desc

-- Countries with highest death count per Population

Select location, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by location
order by total_death_count desc

--Death Count by Continent

Select continent, MAX(cast(total_deaths AS int)) AS total_death_count
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by continent
order by total_death_count desc

-- Global rates

Select date, SUM(new_cases) as global_total_cases, SUM(cast(new_deaths as int)) as global_total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS global_death_percentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by date
order by 1,2


-- Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) AS rolling_vac
From PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Percentage of population vaccinted by country (USE CTE)
With percentpopvac (continent, location, date, population, new_vaccinations, rolling_vac)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) AS rolling_vac
From PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
) 
Select *, (rolling_vac/population)*100 AS percent_vaccinated
From percentpopvac

--Create Views for data visualization

Create View percentpopvac AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date) AS rolling_vac
From PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null;


Create View GlobalCovidRates AS
Select date, SUM(new_cases) as global_total_cases, SUM(cast(new_deaths as int)) as global_total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS global_death_percentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by date;

Create View infectionrate as
Select Location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 AS covid_infection_rate
From PortfolioProject.dbo.CovidDeaths$
group by population, location;