select *from PortfolioProjet..covidmort$
order by 3,4

--select * from PortfolioProjet..covidvaccin$
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProjet..covidmort$
order by 1,2

--total de cas vs  total décès au Canada
--cela montre le pourcentage de risque de décès  si tu as le covid au canada
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Pourcentage_décès
from PortfolioProjet..covidmort$
where location like '%Canada%'
order by 1,2

--total_cases vs population 
--Pourcentage de la population infecter par le covid 19 
select location,date,population,total_cases,(total_cases/population)*100 as Pourcentage_infecter
from PortfolioProjet..covidmort$
where location like '%canada%'
order by 1,2

--pays avec le plus grand pourcentage de la population infecter
select location,population,max (total_cases) as max_nb_infecter,max ((total_cases/population))*100 as Pourcentage_infecter
from PortfolioProjet..covidmort$
group by location ,population
order by Pourcentage_infecter desc

--pays avec le plus grand déces par population
select location,max(cast(Total_deaths as int)) as max_nb_déces 
from PortfolioProjet..covidmort$
	-- il faut  enlevé les continent ,car nous regardons les pays 
where continent is not null
group by location
order by max_nb_déces  desc

--continent avec nb de deces

select continent,max(cast(Total_deaths as int)) as max_nb_déces 
from PortfolioProjet..covidmort$
where continent is  not null
group by continent
order by max_nb_déces  desc

--globalement 
select date, sum(new_cases) as tolal_newcas ,sum(cast(new_deaths as int)) as total_deces, sum(cast(new_deaths as int))/SUM(new_cases )*100 as Pourcentage_décès
from PortfolioProjet..covidmort$
--where location like '%Canada%'
where continent is not null
group by date
order by 1,2

--vaccination
--ici on va mettre les 2 tables ensemble
select *
from PortfolioProjet..covidmort$ deces
join PortfolioProjet..covidvaccin$ vac
on deces.location=vac.location
and deces.date=vac.date

--total population vs vacciner
select deces.continent ,deces.location, deces.date,deces.population,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over (partition by deces.location
	order by deces.location, deces.date) as gensVaccinerAccumuler
	--le over partition permet dajouter les new_vaccinations et de faire un total
from PortfolioProjet..covidmort$ deces
join PortfolioProjet..covidvaccin$ vac
on deces.location=vac.location
and deces.date=vac.date
where deces.continent is not null
order by 2,3

--CTE (Common Table Expression) is a temporary result set 

with popVSvac (continent,location, date,population ,new_vaccinations, gensVaccinerAccumuler)
as (
select deces.continent ,deces.location, deces.date,deces.population,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over (partition by deces.location
	order by deces.location, deces.date) as gensVaccinerAccumuler
	--le over partition permet d ajouter les new_vaccinations et de faire un total accumuler
from PortfolioProjet..covidmort$ deces
join PortfolioProjet..covidvaccin$ vac
on deces.location=vac.location
and deces.date=vac.date
where deces.continent is not null
--order by 2,3)
)
select *,(gensVaccinerAccumuler /population)*100
from popVSvac

--temps taple 
drop table if exists #PourcentageDesGensVacciner 
create table #PourcentageDesGensVacciner   
(
continent nvarchar (255),
location nvarchar (255),
date datetime ,
population numeric,
new_vaccinations numeric ,
gensVaccinerAccumuler numeric ,
)
insert into #PourcentageDesGensVacciner   

select deces.continent ,deces.location, deces.date,deces.population,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over (partition by deces.location
	order by deces.location, deces.date) as gensVaccinerAccumuler
	--le over partition permet d ajouter les new_vaccinations et de faire un total accumuler
from PortfolioProjet..covidmort$ deces
join PortfolioProjet..covidvaccin$ vac
on deces.location=vac.location
and deces.date=vac.date
where deces.continent is not null
--order by 2,3)

select *,(gensVaccinerAccumuler /population)*100
from #PourcentageDesGensVacciner  

--creation de view  pour tableau 
create view  PourcentageDesGensVacciner as  
select deces.continent ,deces.location, deces.date,deces.population,vac.new_vaccinations,sum(convert (int,vac.new_vaccinations)) over (partition by deces.location
	order by deces.location, deces.date) as gensVaccinerAccumuler
	--le over partition permet d ajouter les new_vaccinations et de faire un total accumuler
from PortfolioProjet..covidmort$ deces
join PortfolioProjet..covidvaccin$ vac
on deces.location=vac.location
and deces.date=vac.date
where deces.continent is not null
--order by 2,3)

select *
from  PourcentageDesGensVacciner
