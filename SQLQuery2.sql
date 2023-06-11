select * from [portfolio project]..covid
select location, date, total_cases, new_cases,total_deaths,population
 from [portfolio project]..covid order by 1,2

 ----Looking at total cases vs total deaths

 select location, date, total_cases,total_deaths, cast(total_deaths AS int)/cast (total_cases as int) as total_death
 from [portfolio project]..covid 
 -- where location like '%states%' 
  where continent is not null
 order by 1,2	
 
 select location, date, population,total_cases, (total_cases /population)* 100 as percent_population_infected
 from [portfolio project]..covid 
 where continent is not null
 where location like '%states%' 
 order by 1,2	
 


 ---looking at countries highest infection rate compared to population.

 select location, population,max(total_cases) as highest_infection_count, max((total_cases /population))* 100 as percent_population_infected
 from [portfolio project]..covid 
 --where location like '%states%' 
 where continent is not null
 group by population,location
 order by percent_population_infected desc


 --- Showing Countries with highest death count population.

 select location,max(cast(total_deaths AS int)) as Total_death_count
 from [portfolio project]..covid 
 --where location like '%states%' 
 where continent is null
 group by location
 order by Total_death_count desc

 --- lets breakdown by continent
 select continent,max(total_deaths) as Total_death_count
 from [portfolio project]..covid 
 --where location like '%states%' 
 where continent is not null
 group by continent
 order by Total_death_count desc


 ---Showing Continent with the heighest death count per population


 select continent,max(cast(total_deaths as int)) as Total_death_count
 from [portfolio project]..covid 
 --where location like '%states%' 
 where continent is not null
 group by continent
 order by Total_death_count desc



 ---Global Numbers

 select sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
 case 
 when sum(new_cases)= 0 then null 
 else SUM(cast(new_deaths as decimal))/SUM(cast (new_cases as decimal))*100 end as deathPercentage
 from [portfolio project]..covid 
 where continent is not null
 ---where location like '%states%' 
 --group by date
 order by 1,2	

 --looking at total population vs vaccination
 --use CTE

 with PopvsVac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
 as
 (
 select continent , location, date,population,new_vaccinations,
 SUM(cast(new_vaccinations as bigint)) over (partition by location order by location , date) as rolling_people_vaccinated
 from [portfolio project]..covid
 where continent is not null
--- order by 1,2,3
 )
 select  *,(rolling_people_vaccinated / population) *100
 from PopvsVac

 ---Temp table

 drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
 (
 continent varchar(255),
 location varchar(255),
 date datetime,
 population numeric,
 New_vaccinations numeric, Rolling_people_vaccinated numeric
)

insert into #PercentPeopleVaccinated

select continent , location, date,population,new_vaccinations,
 SUM(cast(new_vaccinations as bigint)) over (partition by location order by location , date) as rolling_people_vaccinated
 from [portfolio project]..covid
 where continent is not null
--- order by 1,2,3
 
 select  *,(rolling_people_vaccinated / population) *100
 from #PercentPeopleVaccinated

 --create a view to store data for later  visualizations


 create view PercentPeopleVaccinated as 
 select continent , location, date,population,new_vaccinations,
 SUM(cast(new_vaccinations as bigint)) over (partition by location order by location , date) as rolling_people_vaccinated
 from [portfolio project]..covid
 where continent is not null
--- order by 1,2,3

select * from PercentPeopleVaccinated