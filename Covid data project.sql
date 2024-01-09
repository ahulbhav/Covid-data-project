select * from CovidDeaths

select Location, Date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--total cases vs total deaths (death percentage)
select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'india'

--total cases vs population (population that is infected)
select Location, Date, Population, total_cases, (total_cases/population)*100 as InfectedPopulation
from CovidDeaths
where location = 'india'

--countries with higher infected population
select Location, Population, max(total_cases) as HighestCases, max(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths 
group by Location, Population
order by PercentagePopulationInfected desc

--countries with highest death count
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by Location
order by HighestDeathCount desc

--continents with highest death count
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is null
group by Location
order by HighestDeathCount desc

-- global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

select * from CovidVaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingNewVaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE
with PopVsVac(Continent, Location, date, Population, new_vaccinations, RollingNewVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingNewVaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingNewVaccinations/Population)*100 as VaccinationPercentage
from PopVsVac;