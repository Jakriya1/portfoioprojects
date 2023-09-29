select * from  Portfolioproject..CovidDeaths$
where continent is not null 
order by 3,4
--select * from  Portfolioproject..CovidVac$
--order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from  Portfolioproject..CovidDeaths$
order by 1,2
--looking at total cases vs deaths
select location, date, total_cases,total_deaths,(cast(total_deaths/total_cases as int))*100 as deathpercentage
from  Portfolioproject..CovidDeaths$
where location like '%india%'
order by 1,2

select location, new_cases,date,population, total_cases,total_deaths,(total_cases/population)*100 as deathpercentage
from  Portfolioproject..CovidDeaths$
where location like '%china%'
order by 1,2

--highest rate by countries
select location, max(total_cases) as Highinfectioncount,max(total_cases/population)*100 as percentpopinfected
from  Portfolioproject..CovidDeaths$

group by location, population
order by percentpopinfected desc
--
select location, max(cast(total_deaths as int)) as highdeaths
from Portfolioproject..CovidDeaths$
where continent is not null 
group by location
order by highdeaths desc
--by continent
select location, max(cast(total_deaths as int)) as highdeaths
from Portfolioproject..CovidDeaths$
where continent is not null 
group by location
order by highdeaths desc
--now looking at vacc
select * 
from Portfolioproject..CovidVac$

--joining both vac and death data
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date)
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVac$ vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3
---using CTE
with popvsVac (Continent,Location, Date, Population, New_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVac$ vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null

)
Select *,  (Rollingpeoplevaccinated/Population)*100
from popvsVac



--temp table
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert  into #percentpopulationvaccinated

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVac$ vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null

Select *,  (Rollingpeoplevaccinated/Population)*100
from #percentpopulationvaccinated


---Creating a view
Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as totaldeaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths$
where continent is not null
order by 1,2

--Creating a view to store data for late vizzes
select continent, Max(cast(total_deaths as int)) as total_deathcount
from Portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by total_deathcount
