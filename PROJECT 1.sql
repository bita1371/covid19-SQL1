select *
from portfolioproject..coviddeath

-- select * 
--from portfolioproject..covidvaccination$
--order by 3,4
-- selecting data 

select location,date, total_cases, new_cases, total_deaths,population
from portfolioproject..coviddeath$
order by 1,2

--looking at total cases vs total deaths
-- probability of dying in country 

select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..coviddeath$
where location like 'Turkey'
order by 1,2

-- looking at total cases vs population 
-- percentage of population got Covid 
select location,date,total_cases, population,(total_cases/population)*100 as Covidpopulationpercentage
from portfolioproject..coviddeath$
where location like 'Turkey'
order by 1,2

-- looking at countries with highest infection rate compared to population 
select location, population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..coviddeath$
--where location like 'Turkey'
group by population,location
order by percentpopulationinfected desc

-- looking at countries with highest Death Count
select location,Max(cast(total_deaths as int))  as TotalDeathCount
from portfolioproject..coviddeath$
--where location like 'Turkey'
where continent is not null 
group by location
order by TotalDeathCount desc

--breakdown with continent

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeath$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

select date,sum(new_cases),sum(cast(new_deaths as int)) ,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeath$
--where location like 'Turkey'
where continent is not null
group by date
order by 1,2

--looking at total death vs vaccination 

select dea.continent, dea.location , dea.date , dea.population , 
vac.new_vaccinations,
sum(CAST(vac.new_vaccinations as numeric )) OVER (partition by dea.location order by dea.location, dea.Date) as RollingpeopleVaccinated
from portfolioproject..coviddeath$   dea
join portfolioproject..covidvaccination$   vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- use CTE
WITH
  PopvsVac (continent, location, date, population,new_vaccinations, RollingpeopleVaccinated) 
  as
  (
  select dea.continent, dea.location , dea.date , dea.population, 
  vac.new_vaccinations,
  sum(CAST(vac.new_vaccinations as numeric )) OVER 
  (partition by dea.location order by dea.location, dea.Date) as RollingpeopleVaccinated
  from portfolioproject..coviddeath$   dea
  join portfolioproject..covidvaccination$   vac
    on dea.location = vac.location
    and dea.date = vac.date
  WHERE dea.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS NUMERIC)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated