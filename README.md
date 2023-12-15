--SELECTING TABLES
SELECT * from project.dbo.Data1;
SELECT * from project.dbo.Data2;

-- number of rows into our dataset
select count(*) from project..Data1;
select count(*) from project..Data2;

-- dataset for jharkhand and bihar
select * from project..Data1 where state in('Jharkhand','Bihar');

-- population of India
select sum(population) AS population from project..Data2;

-- avg growth 
select state, AVG(Growth)*100 AS average_growth from project..Data1 group by State;

-- avg sex ratio
select state, round(AVG(Sex_Ratio),0) AS average_sex_ratio from project..Data1 group by state ;

-- avg literacy rate
select state, round(AVG(literacy),0) AS average_literacy_ratio from project..Data1 
group by state having round(AVG(literacy),0)>90 order by average_literacy_ratio asc ;

-- top 3 state showing highest growth ratio
select top 3 state, AVG(Growth)*100 AS average_growth from project..Data1 group by State order by average_growth desc;

--bottom 3 state showing lowest sex ratio
select top 3 state, round(AVG(Sex_Ratio),0) AS average_sex_ratio from project..Data1 group by state order by average_sex_ratio asc;

-- top and bottom 3 states in literacy state
drop table if exists #topstates
create table #topstates 
(state nvarchar(255),
topstates float
)
select top 3 state, round(AVG(literacy),0) AS average_literacy_ratio  from project..Data1 group by state order by  average_literacy_ratio   asc;
select top 3 state, round(AVG(literacy),0)  AS average_literacy_ratio  from project..Data1 group by state order by average_literacy_ratio desc;
select * from #topstates order by #topstates.topstates desc;

SELECT * FROM project..Data1
WHERE state LIKE 'A%';

--joining table
select a.district,a.state,a.Sex_ratio,b.population from project..Data1 a inner join project..Data2 b on a.district=b.district

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males , round((c.population*c.sex_ratio)/(c.sex_ratio+1),0)females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project..Data1 a inner join project..Data2 b on a.district=b.district)c)d
group by d.state;

-- total literacy rate
select c.state,sum(literate_people)total_literate_population,sum(illiterate_people) from
(select d.district,d.state,ROUND(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)*d.population ,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from project..Data1 a inner join project..Data2 b on a.district=b.district) d) c
group by c.state

--total males and females
select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males , round((c.population*c.sex_ratio)/(c.sex_ratio+1),0)females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from project..Data1 a inner join project..Data2 b on a.district=b.district)c)d
group by d.state;



--previous census
select e.state, sum(e.previous_census_population) previous_census_population ,sum(e.current_census_population)current_census_population from
(select d.district,d.state,ROUND(d.population /(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth ,b.population from project..Data1 a inner join project..Data2 b on a.district=b.district)d) e
group by e.state

select e.state, sum(e.previous_census_population) previous_census_population ,sum(e.current_census_population)current_census_population from
(select d.district,d.state,ROUND(d.population /(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth ,b.population from project..Data1 a inner join project..Data2 b on a.district=b.district)d) e
group by e.state

--top3 districts from each state with highest literacy rate
select a.*from
(select district,state,literacy,rank() over (partition by state order by literacy desc)
rnk from project..Data1)a
where a.rnk in (1,2,3) order by state
