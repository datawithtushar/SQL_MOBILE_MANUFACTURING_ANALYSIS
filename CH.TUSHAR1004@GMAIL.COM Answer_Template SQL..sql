--SQL Advance Case Study


--Q1--BEGIN 
	
	SELECT LO.State from DIM_LOCATION as LO
join FACT_TRANSACTIONS as fa on LO.IDLocation=fa.IDLocation
join DIM_DATE as da on fa.Date=da.DATE
WHERE YEAR>=2005
GROUP BY State;




--Q1--END

--Q2--BEGIN
	
select top 1 lo.State, count(state) as NO_OF_MOBILES_BOUGHT from DIM_MANUFACTURER as ma join DIM_MODEL as mo on ma.IDManufacturer=mo.IDManufacturer
join FACT_TRANSACTIONS as fa on mo.IDModel=fa.IDModel 
join DIM_LOCATION as lo on fa.IDLocation=lo.IDLocation
where Manufacturer_Name='Samsung' and Country='US'
group by state;


--Q2--END

--Q3--BEGIN      
	
	SELECT count(mo.IDModel) as NO_OF_TRANSCTION, mo.Model_Name, lo.ZipCode AS PER_ZIPCODE,lo.State AS PER_STATE from DIM_MODEL as mo
join FACT_TRANSACTIONS as fa on
mo.IDModel=fa.IDModel join DIM_LOCATION as lo 
on  fa.IDLocation=lo.IDLocation
group by mo.IDModel,mo.Model_Name,lo.ZipCode,lo.State;


--Q3--END

--Q4--BEGIN

SELECT TOP 1 Model_Name AS CHEAPEST_CELLPHONE,MIN(UNIT_PRICE) AS PRICE,Manufacturer_Name FROM DIM_MODEL AS
 MO JOIN DIM_MANUFACTURER AS MA
ON MO.IDManufacturer=MA.IDManufacturer
GROUP BY Model_Name,Manufacturer_Name
ORDER BY PRICE ASC ;


--Q4--END

--Q5--BEGIN

select mu.Manufacturer_Name,AVERAGE_PRICEPER_MODEL from DIM_MANUFACTURER as mu
join (SELECT TOP 5 sUM(quantity) AS QUANTITY_SOLD,Manufacturer_Name, avg(unit_price) as AVERAGE_PRICEPER_MODEL FROM DIM_MANUFACTURER 
as ma join DIM_MODEL as mo on ma.IDManufacturer=mo.IDManufacturer 
join FACT_TRANSACTIONS as fa on  mo.IDModel=fa.IDModel
group by Manufacturer_Name
ORDER BY QUANTITY_SOLD DESC) AS AVG_UNI on mu.Manufacturer_Name=AVG_UNI.Manufacturer_Name
group by mu.Manufacturer_Name,AVERAGE_PRICEPER_MODEL
order by AVERAGE_PRICEPER_MODEL desc;

--Q5--END

--Q6--BEGIN
select cs.Customer_Name as CUSTOMER_NAME_WITH_AVERAGE_GREATER_THEN_500,avg_s.Average from DIM_CUSTOMER as cs join
(SELECT Customer_Name,avg(TotalPrice) as Average FROM FACT_TRANSACTIONS AS fa
join DIM_CUSTOMER as cu on 
fa.IDCustomer=cu.IDCustomer join DIM_DATE as da on fa.Date=da.DATE
where YEAR=2009
group by Customer_Name) as avg_s on cs.Customer_Name=avg_s.Customer_Name
 and avg_s.Average>500 
group by cs.Customer_Name,avg_s.Average;

--Q6--END
	
--Q7--BEGIN  
	
SELECT* FROM(select TOP 5  Model_Name from DIM_MODEL as mo
join FACT_TRANSACTIONS as fa on
mo.IDModel=fa.IDModel join DIM_DATE as da on fa.Date=da.DATE
WHERE YEAR=2008 
group by Model_Name
ORDER BY SUM(Quantity) DESC
INTERSECT

select TOP 5 Model_Name from DIM_MODEL as mo
join FACT_TRANSACTIONS as fa on
mo.IDModel=fa.IDModel join DIM_DATE as da on fa.Date=da.DATE
WHERE YEAR=2009
group by Model_Name
ORDER BY sum(Quantity) DESC
INTERSECT

select TOP 5 Model_Name from DIM_MODEL as mo
join FACT_TRANSACTIONS as fa on
mo.IDModel=fa.IDModel join DIM_DATE as da on fa.Date=da.DATE
WHERE YEAR=2010
group by Model_Name
ORDER BY sum(Quantity) DESC) as a

--Q7--END	
--Q8--BEGIN

select top 2 mu.Manufacturer_Name AS MANUFACTURE_WITH_2ND_TOP_SALE,sales,YEAR from DIM_MANUFACTURER  as mu join
(select TOP 4  Manufacturer_Name,sum(totalprice) as sales,DA.YEAR from DIM_MANUFACTURER as ma
join DIM_MODEL as mo on ma.IDManufacturer=mo.IDManufacturer
join FACT_TRANSACTIONS as fa on mo.IDModel=fa.IDModel join DIM_DATE as da on fa.Date=da.DATE
WHERE YEAR=2009 OR YEAR=2010
group by Manufacturer_Name,DA.YEAR
order by sales desc) as sa on
mu.Manufacturer_Name=sa.Manufacturer_Name
group by mu.Manufacturer_Name,sales,YEAR
order by sales asc;

--Q8--END
--Q9--BEGIN
	
	select * from (SELECT 
     Manufacturer_name
    FROM Fact_Transactions T1
    LEFT JOIN DIM_Model D1 ON T1.IDModel = D1.IDModel
    LEFT JOIN DIM_MANUFACTURER D2  ON D2.IDManufacturer = D1.IDManufacturer
    Where DATEPART(Year,date)='2010' 
    group by Manufacturer_name 	
    EXCEPT
SELECT   Manufacturer_name
    FROM Fact_Transactions T1
    LEFT JOIN DIM_Model D1 ON T1.IDModel = D1.IDModel
    LEFT JOIN DIM_MANUFACTURER D2  ON D2.IDManufacturer = D1.IDManufacturer
    Where DATEPART(Year,date)='2009' 
    group by Manufacturer_name) AS A

--Q9--END

--Q10--BEGIN
	
	
if OBJECT_ID('tempdb..#all_customers') is not null
    drop table #all_customers;

select  Customer_Name,  AVG(TotalPrice) as Average_Spend,  AVG(Quantity) as Avg_Qty, YEAR(Date) as [YEAR],
ROW_NUMBER() over(PARTITION by YEAR(Date)order by AVG(TotalPrice) desc) as rn
into #all_customers
from DIM_CUSTOMER as c 
inner join FACT_TRANSACTIONS as t
    on c.IDCustomer = t.IDCustomer
Group By Customer_Name, YEAR(Date);

if OBJECT_ID('tempdb..#top_customers') is not null
    drop table #top_customers;
select *
into #top_customers
from #all_customers

select top 100 L.Customer_Name, L.Year, L.Average_Spend, R.Year as [Year_next],R.Average_Spend as Average_Spend_next, R.rn as rn_next,
    1.0 * R.Average_Spend / L.Average_Spend - 1.0 as diff
from #top_customers as L
left join #all_customers as R
    on L.Customer_Name = R.Customer_Name
    and R.[YEAR] = L.[YEAR] + 1
	ORDER BY L.Average_Spend DESC;

--Q10--END
	