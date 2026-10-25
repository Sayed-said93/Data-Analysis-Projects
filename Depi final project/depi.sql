-- Customer Recency Segmentation

WITH recency_data AS (
    SELECT
        "ID",
        "Recency",
        MAX("Recency") OVER () AS max_recency
    FROM "Fact"
    WHERE "Recency" IS NOT NULL
),

segmented_customers AS (
    SELECT
        "ID",
        CASE
            WHEN "Recency" <= max_recency * 0.25 THEN 'A'
            WHEN "Recency" <= max_recency * 0.50 THEN 'B'
            WHEN "Recency" <= max_recency * 0.75 THEN 'C'
            ELSE 'D'
        END AS recency_segment
    FROM recency_data
)

SELECT
    recency_segment,
    COUNT(*) AS number_of_customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percent_from_total
FROM segmented_customers
GROUP BY recency_segment
ORDER BY recency_segment;
  
---------------------------------------------------------------------------------------
--Average recency  by customer age group
SELECT 
    CASE
    WHEN Age < 28 THEN 'Young'
    WHEN Age BETWEEN 28 AND 46 THEN 'Middle-Aged'
    ELSE 'Aged'
END AS age_group, Round(AVG("Recency"),2) AS avg_recency
FROM ( 
       select  2014 - cast("Year_Birth" as integer)  as Age,"Recency"
        from "Fact"
)
GROUP BY age_group
ORDER BY avg_recency

--------------------------------------------------------------------------------------------------------
--Knowing the buying behaviors of each age group and the number of customers in each age group
select age_group ,total_customer,"Product",total_Amount,ranking
from(
select age_group ,total_customer,"Product",total_Amount,row_number() over(partition by age_group order by total_Amount desc) as ranking
from(
SELECT 
    CASE
    WHEN Age < 28 THEN 'Young'
    WHEN Age BETWEEN 28 AND 46 THEN 'Middle-Aged'
    ELSE 'Aged'
  END AS age_group, count("ID") as total_customer,"Product" ,sum("Amount") as total_Amount 
FROM ( 
       select  2014 - cast("Year_Birth" as integer)  as Age,"Product","Amount",f."ID"
        from "Fact" f inner join "Dim Product" p
    on f."ID"=p."ID" 
)
GROUP BY age_group,"Product" 
order by  age_group
)
)
where ranking  <= 2
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--Total Amount spent of product and percent from total  via different kidhome
select "Kidhome",  "Product",total_Amount_spent ,
round(total_Amount_spent/total_Amount_spent_in_each_Kidhome,4) *100 as percent_Amount_spent_from_total
from(
SELECT "Kidhome",  "Product",total_Amount_spent ,
SUM( total_Amount_spent ) over(partition by "Kidhome" ) as total_Amount_spent_in_each_Kidhome
from(
SELECT "Kidhome",  "Product", SUM("Amount") AS total_Amount_spent
FROM "Fact" f inner join "Dim Product" p
on f."ID"=p."ID"
GROUP BY "Kidhome", "Product"
ORDER BY "Kidhome" ASC,total_Amount_spent Desc
)
)
-------------------------------------------------------------------------------------------
-- Correlation between marital status and amounts (total amount by each marital status)
select distinct FF."Marital_Status",sum(PP."Amount") over (partition by FF."Marital_Status")  Amount_spent
from "Fact" FF inner join public."Dim Product" PP 
on FF."ID"=PP."ID" 
order by FF."Marital_Status"

------------------------------------------------------------------------------------------------
--Each product with total sold amounts  by each marital status
select distinct FF."Marital_Status" , PP."Product", sum(PP."Amount")
from "Fact" FF inner join "Dim Product" PP 
on FF."ID"=PP."ID"
group by FF."Marital_Status", PP."Product"
order by FF."Marital_Status"

----------------------------------------------------------------------------------------------
---Amount _spent in each product
select "Product" , Sum("Amount") "Total Amount" 
from "Dim Product"
group by "Product"
order by "Total Amount" desc

---------------------------------------------------------------------------------
--Total amount spent by each customer on different products only two most spent
SELECT "ID", "Product",total_Amount,ranking
from(
SELECT f."ID", "Product", SUM("Amount") AS total_Amount,row_number() over(partition by f."ID" order by SUM("Amount") desc) as ranking
FROM "Fact" f inner join "Dim Product" p
    on f."ID"=p."ID" 
GROUP BY f."ID", "Product"
ORDER BY "ID",total_Amount DESC
)
where ranking<3
------------------------------------------------------------------------------------------------
-- Average income and spending per customer by marital status

WITH customer_spending AS (
    SELECT
        "ID",
        SUM("Amount") AS total_spent
    FROM "Dim Product"
    GROUP BY "ID"
)

SELECT
    f."Marital_Status",
    ROUND(AVG(f."Income"), 2) AS avg_income,
    ROUND(AVG(COALESCE(cs.total_spent, 0)), 2)
        AS avg_spending_per_customer
FROM "Fact" f
LEFT JOIN customer_spending cs
    ON f."ID" = cs."ID"
GROUP BY f."Marital_Status"
ORDER BY avg_income DESC;


----------------------------------------------------------------------------------------------

-- Total purchases by purchase channel

SELECT
    "Purchase",
    SUM("Number of Purchase") AS total_purchases
FROM "Dim Purchase"
GROUP BY "Purchase"
ORDER BY total_purchases DESC;


-- Total amount spent by product

SELECT
    "Product",
    SUM("Amount") AS total_amount
FROM "Dim Product"
GROUP BY "Product"
ORDER BY total_amount DESC;
-----------------------------------------------------------------------------------------------
--- correlation between Num of kids and num of purchases 
select distinct FF."Kidhome",
 sum(PP."Number of Purchase")over(partition by FF."Kidhome" order by FF."Kidhome" )"Num of purchases" 
from "Dim Purchase" PP inner join "Fact"FF 
on FF."ID"=PP."ID"
order by "Num of purchases" desc

----------------------------------------------------------------------------------------------------
--vip 10 customer by num of purchases
 select FF."ID", sum(PP."Number of Purchase")  "Num_of_Purchases" 
 from "Dim Purchase" PP inner join "Fact" FF 
 on FF."ID"=PP."ID"
 group by FF."ID"
 order by  "Num_of_Purchases" desc
 limit 10

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Number of interactions with Compaigns
select "Compaign",sum("Accepted the compaign") as total_accepted
from "Dim Compaign"
group by "Compaign"
order by total_accepted DESC

-----------------------------------------------------------------------------------------------------
-- correlation between marital_status and campaings acceptance
select distinct FF."Marital_Status" , sum(CC."Accepted the compaign") over(partition by FF."Marital_Status" order by FF."Marital_Status") "Num of campaign acceptance" 
from "Fact"FF inner join "Dim Compaign" CC 
on CC."ID"=FF."ID"
-------------------------------------------------------------------------------------
--education level  and total number of accepted campaigns
SELECT "Education", SUM("Accepted the compaign") AS total_accepted
FROM "Fact" f inner join "Dim Compaign" c
    on f."ID"=c."ID" 
GROUP BY "Education"
ORDER BY total_accepted DESC
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--TOTAL number of Accepted the compaign and Number of Purchases by income range
SELECT income_range,  SUM("Accepted the compaign") AS total_accepted ,SUM("Number of Purchase") AS "Number of Purchase"
FROM (
    SELECT 
            CASE
            WHEN "Income" BETWEEN 0 AND MAX("Income") OVER () / 3 THEN 'Low Income'
            WHEN "Income" BETWEEN MAX("Income") OVER () / 3 + 1 AND MAX("Income") OVER () / 3 * 2 THEN 'Middle Income'
            ELSE 'High Income'
            END AS income_range, "Accepted the compaign" ,"Number of Purchase"
    FROM "Fact" f inner join "Dim Purchase" p
    on f."ID"=p."ID"  inner join "Dim Compaign" c
    on f."ID"=c."ID" 
) AS tt
GROUP BY income_range
order by total_accepted DESC

------------------------------------------------------------------------------------------------------
--TOTAL number of web visits and Number of Purchases by income range
SELECT income_range, SUM("NumWebVisitsMonth" ) AS "NumWebVisitsMonth" 
FROM (
    SELECT 
	        CASE
    WHEN "Income" <= 50000 THEN 'Low Income'
    WHEN "Income" BETWEEN 50001 AND 80000
        THEN 'Middle Income'
    WHEN "Income" > 80000 THEN 'High Income'
    ELSE 'Unknown'
END AS income_range , "NumWebVisitsMonth" 
    FROM "Fact" f
) AS tt
GROUP BY income_range

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
