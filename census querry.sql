Use census
SELECT * FROM census.dataset1;
SELECT * FROM census.dataset2;
------NO OF ROWS----
SELECT COUNT(*) FROM dataset1
-----Data for up and bihar-----
select * from dataset1 where State in ('Bihar','Uttar Pradesh')
----Removing comma between the population and area-----
UPDATE dataset2
SET Population = REPLACE(Population, ',', '');
UPDATE dataset2
SET Area_km2 = REPLACE(Area_km2, ',', '');
-----find total population----
select sum(Population) as 'total Population' from dataset2

-----avg growth by state
select State,avg(Growth) as 'avg_growth' from dataset1 group by State 
order by 2 desc limit 5

-----Populaytion State wise
select State,sum(Population) as 'state wise population' from dataset2
group by State 
order by 2 desc limit 5

-------lowest sex ratio state 
select State,District,avg(Sex_Ratio) as 'sex ratio' from dataset1 group by 1,2
order by 3  limit 5 
select State,avg(Sex_Ratio) as 'sex ratio' from dataset1 group by 1
order by 2

--------TOP 2 Avg literacy rate greater than 90
Select State,avg(Literacy) as 'Avg Literacy' from dataset1
 group by state having avg(Literacy) >90  order by 2
 Select State,avg(Literacy) as 'Avg Literacy' from dataset1
 group by state order by 2
 
 ------Crete temp table 
 CREATE Temporary TABLE topstates (
  Select State,avg(Literacy) as 'Avg Literacy' from dataset1
 group by state having avg(Literacy) >90  order by 2
 )
 
 -----state starts with A or endind with letter d
 SELECT  distinct State from dataset1 where state like 'A%' or state like '%d'
 
 -----JOINING BOTH TABLE
 select a.district,a.state,a.sex_ratio,b.population,b.Area_km2 from dataset1 a inner join dataset2 as b 
 on a.district=b.district
 
 /* FIND NO OF MALE AND FEMALE HAVING BASED ON THE POPULATION AND SEX RATIO
 NO OF MALE=POPULATION/(SEXRATIO+1)
 NO OF FEMALE=Population-POPULATION/(SEXRATIO+1)  */
 
 WITH CTE AS (
 select district,state,round(Population/(sex_ratio+1)) as Males,
 round(Population-(Population/(sex_ratio+1)))as Females from
 (select a.district,a.state,(a.sex_ratio/1000) as sex_ratio,b.population,b.Area_km2 
 from dataset1 a inner join dataset2 as b 
 on a.district=b.district)c)
 
 select state,SUM(Males) total_males,SUM(Females) total_females from cte group by 1
 
 /* calculate literate people and illitrate people state wise
 totle literate people=Literacy*Population
 total illitrate people=(1-Literacy)*100   */
 
 
 SELECT y.state, SUM(Total_Literate_people), SUM(total_Illiterate_people)
FROM (
    SELECT district, state, ROUND(Literacy*population) AS Total_Literate_people,
    ROUND((1-Literacy)*population) AS total_Illiterate_people
    FROM (
        SELECT a.district, a.state, ROUND((a.Literacy)/100, 4) AS Literacy, b.population
        FROM dataset1 a
        INNER JOIN dataset2 b ON a.district = b.district
    ) x
) y
GROUP BY y.state;

/*Population in prevoious census  previous population= population/(1+growth) */

select sum(g.Current_population) total_population,sum(g.Previous_population) Previous_total_population
 from (

select f.state,sum(f.population) Current_population,sum(f.previous_population) Previous_population from
(
select d.district,d.state,d.population,round(population/(1+growth)) AS previous_population from
(
select a.district,a.state,(a.growth/100) AS growth,b.population 
from dataset1 a inner Join dataset2 b 
on a.district=b.district )d
)f
group by 1 ) g

---Population vs Area----

select  m.total_area/m.Previous_total_population previous_population_vs_area 
,m.total_area/m.total_population Current_population_vs_area from
(
select k.*,l.* from
(
SELECT '1' as keyy_no, h.* from
(
select sum(g.Current_population) total_population,sum(g.Previous_population) Previous_total_population
 from (

select f.state,sum(f.population) Current_population,sum(f.previous_population) Previous_population from
(
select d.district,d.state,d.population,round(population/(1+growth)) AS previous_population from
(
select a.district,a.state,(a.growth/100) AS growth,b.population 
from dataset1 a inner Join dataset2 b 
on a.district=b.district )d
)f
group by 1 ) g
) h
)k inner join 

(select '1' AS key_no ,j.* from
(
select sum(area_km2) as total_area from dataset2
) j
)l on k.keyy_no=l.key_no
)m

-----top 3 district of each state where literacy rate is high-----
select n.* from 
(select state,district,literacy,rank() over (Partition by state order by literacy desc) rnk
 from dataset1
 )n
 where n.rnk in (1,2,3)