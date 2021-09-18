
/*Ask Sara on Sep 14:
 * 1. Why do I get error with comparison operator: and searches > 80000? >Solved with HAVING
 * 2. What does negative RPT mean? > Ask pricing team, maybe Malte
 * 3. Case statement give me an error
 * 
 * 
 * Get data from clickhouse into pandas - get python client for clickhouse to ingest the data
 * 
 * LOOKINTO ProfitPerPax: understand relationship between this data point, cost and margin (did we split profit vs cost?)
 * Max Murskov and Eric
 * 
 * 3. Clarify converting datatypes with CAST with Sara
 * 4. Why does INTERVAL not work? Ask Sara
 * 5. Entering the time adding NOW()
 * 6. STRPOS gives error, ask Sara
 * 7. 
 * 8. Concat gives error, ask Sara
 * 9. Extract gives error, ask Sara
 * 10. select CURRENT_DATE date,
		CURRENT_TIME AS time
        CURRENT_TIMESTAMP timestamp
       	LOCALTIME  localtime
       LOCALTIMESTAMP localtimestamp
       all seem not to work, ask Sara
   11. What we did was running subqueries correct?Ask Sara
   12. Window Functions: sum over order by gives error - Ask Sara
   13. RANK() and DENSE_RANK() - Give errors, ask Sara
   14: Are these fuctions useful to know? NTILE, LAG, LEAD*/


/* Q&A 
1. Where do I find the Sherpa levels? 
It's under DataScience > SherpaData

2. I want to see what are the most searched countries for our Company

3. I want to find countries with high search and low CR

4. I want to look at the RPT

5. I want to compare this week versus last week

6. I want to compare how many searchesee what the search_From_To table looks like

7. Why clickhouse is good:
a. Column Oriented DB
b. Processes data fast

8. Why clickhouse is not good
a. Not great for joins

*/

/*START AUGUST DEMO FOR GLENN*/
select today() today  -- to see what day is today

select now() -- to see what time it is

select *
from datascience.BookingDetails bd
WHERE BookDate = today()

/*BREAKING DOWN THE MODE TUTORIAL - SEP 11 2021 - OREDER BY
The order of column names in your GROUP BY clause doesn't matter—the results will be the same regardless. If you want to
control how the aggregations are grouped together, use ORDER BY. Columns in the ORDER BY clause must be separated by commas. 
Second, the DESC operator is only applied to the column that precedes it. Finally, the results are sorted by the first 
column mentioned (rpt), then by double_rpt afterward. You can see the difference the order makes by running the 
following query*/

/*What does negative RPT mean? This may be related to some cases like refunds, coupon, discounts. Ask pricing team */


select top 10 DestCountry country, DestCountryName name, DestRegion region, DestContinentName continent, RPT_USD rpt, rpt*2 double_rpt 
from datascience.BookingDetails bd
where region != continent
order by rpt desc, double_rpt


select top 10 DestCountry country, DestCountryName name, DestRegion region, DestContinentName continent, RPT_USD rpt,
rpt*2 double_rpt, Pax 
from datascience.BookingDetails bd
where region != continent
order by rpt, double_rpt desc

/*BREAKING DOWN THE MODE TUTORIAL - SEP 11 2021 - AGGREGATE FUNCTIONS: count. COUNT counts how many rows are in a 
 * particular column. Typing COUNT(1) has the same effect as COUNT(*). Which one you use is a matter of personal
 *  preference. You can use count on non-numerical columns, as shown in the second query below
 * 
 * 
 * BREAKING DOWN THE MODE TUTORIAL - SEP 12 2021 - GROUP BY
 * GROUP BY allows you to separate data into groups, which can be aggregated independently of one another
 * HAVING CLAUSE: HAVING is the "clean" way to filter a query that has been aggregated, but this is also commonly done
 * using a subquery*/


select DestCountry country, DestCountryName name, count(1) bookings, avg(RPT_USD) rpt
from datascience.BookingDetails bd 
where BookDate = today() 
group by country, name 
order by bookings desc

select DestCountry country, DestCountryName name, count(country) country_count, count(name) country_name
from datascience.BookingDetails bd 
where BookDate = today() 
group by country, name 


/*Here's a useful way to use group by. Find out how many searches we had this week at FP for all countries globally. 
To match the data in our PowerBI we need to look at the data for the current week. 
I find 4M, higher than 1M in powerBI report 
Note on functions: COUNT works with any data type, but SUM only works for numerical data. This is actually more complicated than it appears:
in order to use SUM, the data must appear to be numeric, but it must also be stored in the database in a numeric form*/


select top 10 SearchDepartureToCountry ToCountry, count(1) searches -- count(1) num removes the duplicates
from searches.searchlog s 
-- Note: s is an alias
--where SearchDate >= '2021-08-21' and SearchDate <='2021-08-28'
where SearchDate >= today() - 7 -- You can chose either one, today() - 7 or write specific dates as above
and IsCheapestGlobal = 1
group by ToCountry 
order by searches desc

select top 10 SearchDepartureToCountry to_country, Pax_Adults adults, Pax_Children children-- count(1) num removes the duplicates
from searches.searchlog s 
where SearchDate >= today() 
group by to_country, adults, children
having children = 1 
order by adults desc

/*The CASE statement is SQL's way of handling if/then logic. The CASE statement is followed by at least one pair of WHEN
 and THEN statements—SQL's equivalent of IF/THEN in Excel. Because of this pairing, you might be tempted to call this
 SQL CASE WHEN, but CASE is the accepted term.
Every CASE statement must end with the END statement. The ELSE statement is optional, and provides a way to capture
values not specified in the WHEN/THEN statements. CASE is easiest to understand in the context of an example:*/

/*CASE statement gives me an error: in clickhouse I need to use if, see syntax here
 https://clickhouse.tech/docs/en/sql-reference/functions/conditional-functions*/

select top 10 SearchDepartureToCountry to_country, Pax_Adults adults, Pax_Children children, -- count(1) num removes the duplicates
if(to_country = 'DZ', 'yes', NULL)
--else null end not_dz
from searches.searchlog s

--(cond, then, else)

select top 10 SearchDepartureToCountry to_country, Pax_Adults adults, Pax_Children children-- count(1) num removes the duplicates
case when adults = 1 then 'yes'
else null end not_1
from searches.searchlog s 


select top 10 CountryCode code, CountryName name, FullyVaccinated vax
--case when vax = 1 then 'yes'
--else null end as 'not-vaccinated'
from datascience.SherpaData sherpa
group by CountryCode,CountryName, FullyVaccinated 

/*Remove and IsCheapestGlobal = 1, since that is not a condition in the PowerBI, and only search for today.
 * I still get a higher number than in the PowerBI. Speak with Manish Negi about this to clarify discrepancy*/

 
select top 10 SearchDepartureToCountry ToCountry, count(1) searches 
from searches.searchlog s 
--where SearchDate >= '2021-08-15' and SearchDate <='2021-08-28'
where SearchDate = today()
--and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by searches desc

/*END AUGUST DEMO FOR GLENN*/

/*BREAKING DOWN THE MODE TUTORIAL - AUGUST 29 2021
 * 
 * SQL is used for accessing, cleaning, and analyzing data that's stored in databases
 * (Structured Query Language) is a programming language designed for managing data in a relational database. 
 * It's been around since the 1970s and is the most common method of accessing data in databases today. 
 * SQL has a variety of functions that allow its users to read, manipulate, and change data.
 * within databases, tables are organized in schemas. Table are referenced as schema.table
 * 
 * 
 * BREAKING DOWN THE MODE TUTORIAL - AUGUST 30 2021
 * Basic syntax: SELECT, FROM and naming columns: always name columns in lower case with underscores to avoid spaces.
 * If you want to capitalize you can do so using double quotes as should belo
 * 
 * The WHERE clause filters based on values in one column, you'll limit the results in all columns to rows that satisfy
 * the condition. The idea is that each row is one data point or observation, and all the information contained 
 * in that row belongs together.*/


select top 10 SearchDepartureToCountry "To Country" -- you can use top 10 or limit 10
from searches.searchlog s 
where SearchDate = today()

select SearchDepartureToCountry "To Country"
from searches.searchlog s 
where SearchDate = today()
limit 10 -- you can use top 10 or limit 10, if you use limit you must place it at the bottom

/*BREAKING DOWN THE MODE TUTORIAL - AUGUST 31 2021
 * COMPARISON OPERATORS: they make more sense if applied to numerical values
 * Why am I getting an error? Ask Sara*/













SELECT top 10 SearchDepartureToCountry ToCountry, count(1) searches, AVG(ProfitPerPax) avg_profit --Talk to Erica bout profit vs margin
from searches.searchlog s 
where SearchDate = today() 
group by SearchDepartureToCountry 
having searches > 80000 and searches < 5000000000000 and avg_profit > 15
order by searches desc


 /**BREAKING DOWN THE MODE TUTORIAL - SEP 11 2021 - AGGREGATE FUNCTIONS: SUM and logical operator NOT.
  * This query which includes a subquery works.
  * NOT is a logical operator in SQL that you can put before any conditional statement to select rows for which that 
  * statement is false.
  * NOT is also frequently used to identify non-null rows, but the syntax is somewhat special—you
  * need to include IS beforehand. Here's how that looks.
  * AVG is a SQL aggregate function that calculates the average of a selected group of values. It's very useful, 
  * but has some limitations. First, it can only be
  * used on numerical columns. Second, it ignores nulls completely.*/

select *
from (SELECT MIN(IsBooked) AS min,
       MAX(IsBooked) AS max,
       SUM(IsBooked) AS sum,
       AVG(IsBooked) AS avg
FROM searches.searchlog s 
where SearchDate = today() AND IsBooked is not NULL) table1
where max > 1

/*SUM is a SQL aggregate function that totals the values in a given column. Unlike COUNT, you can only use SUM on
 *columns containing numerical values.*/
 
select top 100 SearchDepartureToCountry to_country, IsBooked, sum(IsBooked) total_bookings
from searches.searchlog s 
where SearchDate = today()
group by to_country, IsBooked 

/*MIN and MAX are SQL aggregation functions that return the lowest and highest values in a particular column.

They're similar to COUNT in that they can be used on non-numerical columns. Depending on the column type, 
MIN will return the lowest number, earliest date, or non-numerical value as close alphabetically to "A" as
 possible. */

select top 100 SearchDepartureToCountry to_country, IsBooked, sum(IsBooked) total_bookings, min(IsBooked) min, max(IsBooked) max
from searches.searchlog s 
where SearchDate = today()
group by to_country, IsBooked

/*Comparison Operators with non-numeric values*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches
from searches.searchlog s 
where SearchDate = today() and to_country > 'D'
group by to_country

/*You can perform arithmetic in SQL using the same operators you would in Excel: +, -, *, /.
 However, in SQL you can only perform arithmetic across columns on values in a given row. To clarify, 
 you can only add values in multiple columns from the same row together using +—if you want to add values across 
 multiple rows, you'll need to use aggregate functions, which are covered in the Intermediate SQL section of this 
 tutorial.*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, searches * bookings prod
from searches.searchlog s 
where SearchDate = today() and to_country > 'D'
group by to_country, bookings

/*You can chain arithmetic functions, including both column names and actual numbers*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate = today() and to_country > 'D'
group by to_country, bookings

/*BREAKING DOWN THE MODE TUTORIAL - SEP 8 - SQL Logical operators
 * LIKE allows you to match similar values, instead of exact values.
 * LIKE is case-sensitive, to ignore case when you're matching values, you can use the ILIKE command:*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate = today() and to_country LIKE '%D%'
group by to_country, bookings

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate = today() and to_country LIKE '%d%'
group by to_country, bookings

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate = today() and to_country ILIKE '%d%'
group by to_country, bookings

/*You can also use _ (a single underscore) to substitute for an individual character*/

/*IN allows you to specify a list of values you'd like to include.
 * As with comparison operators, you can use non-numerical values, but they need to go inside single quotes.*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate = today() and bookings IN (0, 1)
group by to_country, bookings

/*AND is a logical operator in SQL that allows you to select only rows that satisfy two conditions*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate = today() and to_country IN ('ZM', 'QA', 'GY')
group by to_country, bookings

/*BREAKING DOWN THE MODE TUTORIAL - SEP 11 2021
 * BETWEEN is a logical operator in SQL that allows you to select only rows 
 * that are within a specific range. It has to be paired with the AND operator*/

/*OR is a logical operator in SQL that allows you to select rows that satisfy either of two conditions. */

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate = today() /*and*/ or bookings between 1 and 5
group by to_country, bookings

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings, (searches * bookings) - 4 non_sense
from searches.searchlog s 
where SearchDate between today() and yesterday()
group by to_country, bookings

select yesterday()

/*Practice a combination of ant, not, ILIKE, is not NULL*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings
from searches.searchlog s 
where SearchDate = today() and to_country not ILIKE '%IR%'
group by to_country, bookings 

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings
from searches.searchlog s 
where SearchDate = today() and to_country is not NULL
group by to_country, bookings 

/*IS NULL is a logical operatorin SQL that allows you to exclude rows with missing data from your results.*/

SELECT top 10 SearchDepartureToCountry to_country, count(1) searches, IsBooked bookings
from searches.searchlog s 
--where SearchDate = today()
where to_country is NULL 
group by to_country, bookings

/*Understanding GROUP BY*/
select top 500 SearchDepartureToCountry ToCountry, count(1) searches
from searches.searchlog s 
where SearchDate = today() 
group by SearchDepartureToCountry
order by searches desc

/*You can group by multiple columns, separating with a comma*/

select top 500 SearchDepartureToCountry ToCountry, IsBooked, count(1) searches
from searches.searchlog s 
where SearchDate = today() 
group by SearchDepartureToCountry, IsBooked
order by searches desc

/*Practice sum - This doesn't tell me anything about countries*/
select top 100 SearchDepartureToCountry ToCountry, sum(IsBooked) totalbookings
from searches.searchlog s 
where SearchDate = today() 
group by SearchDepartureToCountry, IsBooked

order by searches desc

/*To get info about the countries add the values I want to select*/ 
select top 100 SearchDepartureToCountry ToCountry, count(1) searches, sum(IsBooked) totalbookings
from searches.searchlog s 
where SearchDate = today() 
group by SearchDepartureToCountry, IsBooked 

/*Practice min, max, AVG*/

SELECT MIN(IsBooked) AS min,
       MAX(IsBooked) AS max,
       SUM(IsBooked) AS sum,
       AVG(IsBooked) AS avg
FROM searches.searchlog s 
where SearchDate = today() AND IsBooked is not NULL 
--Interesting problem is find the most profitable country using this!




/*What happens if I remove count(1) */

select top 10 SearchDepartureToCountry ToCountry
from searches.searchlog s 
where SearchDate = today() 
group by SearchDepartureToCountry 
--order by num desc --I need to remove this because there is no longer a column called num

/*If I am only interested in counting, I will only see the count without the country it refers to*/
--select count(1) num
select count(*)
from searches.searchlog s 
where SearchDate = today()


/* ASK SARA: how do we get all the columns in one schot without typing each column name? */

SELECT top 100 AnonymousId, ApplicationID, Application, BotDetected, DeviceID, EnginesFound, MatchingItineraryCount, 
AirlinesFound, EnginesFoundNames, FpAffiliate, AffiliateGroup, FpSubAffiliate, HasSameDateSameOndResults, IsBooked, 
MachineName, Pax_Adults, Pax_Children, PersonGuid, Portal, PortalName, PortalCurrency, SearchClassOfService, 
SearchDepartureDate, SearchDepartureFrom, SearchDepartureFromCity, SearchDepartureFromState, SearchDepartureFromCountry, 
SearchDepartureTo, SearchDepartureToCity, SearchDepartureToState, SearchDepartureToCountry, SearchGuid, SearchReturnDate, 
SearchReturnFrom, SearchReturnFromCity, SearchReturnFromState, SearchReturnFromCountry, SearchReturnTo, SearchReturnToCity,
SearchReturnToState, SearchReturnToCountry, SearchSource, SearchDate, SearchTime, SearchTypeOfTrip, SessionId, 
TransactionID, TotalContractsSearch, Airlines, BestFor, BookingEngine, BookingEngineName, ContractBookedTIDs, 
ContractBookedIDs, ContractIDs, `FlightRecommender.Score`, `FlightRecommender.RescaledScore`, 
`FlightRecommender.Position`, NumberOfContractsRow, CostPerPax, CreditCardFeesPerPax, Discount, DisplayPrice, 
FareType, FareBasisCodes, FlightClass, DepartureFlightNumber, DepartureSeatAvailable, FlightDepartureAirlines, 
FlightDepartureArrivalTime, FlightDepartureDepTime, FlightDepartureDepDate, FlightDepartureDepTimeString, 
FlightDepartureFlightClass, FlightDepartureFlightDuration, FlightDepartureFrom, FlightDepartureFromCity, 
FlightDepartureFromState, FlightDepartureFromCountry, FlightDepartureLayoverDuration, FlightDepartureStops, 
FlightDepartureTo, FlightDepartureToCity, FlightDepartureToState, FlightDepartureToCountry, ReturnFlightNumber, 
ReturnSeatAvailable, FlightReturnAirlines, FlightReturnArrivalTime, FlightReturnDepTime, FlightReturnDepDate, 
FlightReturnDepTimeString, FlightReturnFlightClass, FlightReturnFlightDuration, FlightReturnFrom, FlightReturnFromCity, 
FlightReturnFromState, FlightReturnFromCountry, FlightReturnLayoverDuration, FlightReturnStops, FlightReturnTo, 
FlightReturnToCity, FlightReturnToState, FlightReturnToCountry, IsAlternateDate, IsCheapestAlt, IsCheapestAlternateDate,
IsCheapestDirect, IsCheapestGlobal, IsCheapestNearby, IsCheapestSameDateSameOnD, IsFastestAlt, IsFastestGlobal, 
IsFastestSameDateSameOnD, IsFastestAltPerContract, IsFastestGlobalPerContract, IsFastestSameDateSameOnDPerContract, 
IsNearbyAirport, IsOpaque, IsSRI, MatchingItineraryInfo, Markup, PriceTotal, ProfitPerPax, ServiceFee, SupplierCode, 
TotalFlightDuration_old, TotalFlightDuration, TotalLayoverDuration, TotalPax, TotalStops, TotalTravelDuration, 
ValidatingCarrier, YMSString
FROM searches.searchlog; 

/*can use the ; to separate queries, NOT really needed in DBeaver, because it ONLY executes WHERE the cursor is
's' is an alias - useful when you do a JOIN*/

/* Try different types of aggregations to understand the structure of clickhouse */

SELECT top 10 SearchGuid, SearchTime, SearchDate, PriceTotal, TotalFlightDuration, FlightDepartureDepTime, 
DepartureFlightNumber, ReturnFlightNumber, SearchDepartureToCountry, SearchDepartureFromCountry 
from searches.searchlog s 
-- The above query takes a long time. You can expedite it using where SearchDate = today() 
where SearchDate = today() 
-- because the data is partitioned on SearchDate, we can quickly limit the amount we have to load and sort
and IsCheapestGlobal = 1 -- this should give you one row per search, very useful to find the only ONE that's cheapest
order by SearchGuid, PriceTotal

--select SearchGuid,  FpAffiliate, count(1) num 
select top 100 SearchGuid, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchGuid, FpAffiliate  
--order by num desc -- the highest one is returned at the top 
order by num DESC


/*AGGREGATION: let's work with this aggregation for now*/

select top 100 SearchDepartureToCountry ToCountry, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

/*Look at Sherpa Data*/

select CountryCode, CountryName, FullyVaccinated, TravelOpenness, EntryRestrictions, Covid19Test, Quarantine,
				Response, UpdatedOn
from datascience.SherpaData s
where (TravelOpenness = 'LEVEL_1' or TravelOpenness = 'LEVEL_2')
AND FullyVaccinated = 1
AND Covid19Test = 'NOT_REQUIRED_COVID_19_TEST'


/*Aggregate Sherpa Data*/

select top 100 CountryCode, CountryName, FullyVaccinated, TravelOpenness, EntryRestrictions, Covid19Test, Quarantine,
				Response, UpdatedOn 
from datascience.SherpaData s
--WHERE CountryName = 'Aruba' AND FullyVaccinated = 1
WHERE TravelOpenness = 'LEVEL_1' or TravelOpenness = 'LEVEL_2'
--AND FullyVaccinated = 1
ORDER BY FullyVaccinated desc


/*BREAKING DOWN THE MODE TUTORIAL - SEP 13 2021 - JOIN*/
/*Homework: run this aggregation on different tables and join tables*/


select top 10 SearchDepartureToCountry, count(1) num, AVG(IsBooked) * 100 CR
from searches.searchlog s 
where SearchDate = today()
--where SearchDate >= '2021-07-30' and SearchDate <= '2021-08-12'
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

/*When I first try join I get an empty table because these is no SearchDeparturetoCountry in the sl that is equal to 
 * the CountryName in SherpaData*/
-- 1. I get an empty table
select top 100 SearchDepartureToCountry, count(1) searches, AVG(IsBooked) * 100 CR
from searches.searchlog sl 
--where SearchDate >= '2021-07-30' and SearchDate <= '2021-08-12'
JOIN datascience.SherpaData sherpa 
ON sherpa.CountryName = sl.SearchDepartureToCountry
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by searches desc


/*Let's understand why. This is because of the way I aggregated. I need to take a step back and learn 
 * about FRACTALS! The trick is to get the whole aggregation and call it an alias like we did below. Only THEN come back 
 * on top and start selecting from! 
 * One first obstacle is that the SearchDepartureToCountry column in the searchlog table has different codes than the Sherpa
 * table CountryCode column! That is why we need to create a DYI mapping as shown below.
 * Let's build the anatomy of JOIN:
 * after the FROM we have JOIN followed by a table. I'm interested in 2 tables: datascience.SherpaData
  and searches.searchlog. ON is followed by a couple column names separated by an equals sign (ON sherpa.CountryName = 
  cm.DestCountryName) 
  
  *You'll occasionally want to look at only the unique values in a particular column. 
  *You can do this using SELECT DISTINCT syntax. It's worth noting that using DISTINCT, particularly in aggregations,
  * can slow your queries down quite a bit*/

select SearchDepartureToCountry, num, CR, sherpa.*
FROM 
(
select top 100 SearchDepartureToCountry, count(1) num, AVG(IsBooked) * 100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc
) sa --LIFESAVER!!!
JOIN 
(
select distinct DestCountry, DestCountryName from datascience.BookingDetails -- DIY mapping table
) cm on sa.SearchDepartureToCountry = cm.DestCountry 
join datascience.SherpaData sherpa
ON sherpa.CountryName = cm.DestCountryName

/*First see what sa and cm look like*/

select SearchDepartureToCountry, num, CR
FROM 
(
select top 100 SearchDepartureToCountry, count(1) num, AVG(IsBooked) * 100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc
) sa

SELECT *
FROM (
select distinct DestCountry, DestCountryName from datascience.BookingDetails -- DIY mapping table
) cm

/*Now look at the SherpaData table in datascience schema*/
select *
from datascience.SherpaData

/*Now join the SherpaData table calling is sherpa*/
select SearchDepartureToCountry, num, CR, sherpa.*
from  
(
select top 100 SearchDepartureToCountry, count(1) num, AVG(IsBooked) *100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
JOIN 
(
select distinct DestCountry, DestCountryName
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName

/* Here below is the reasoning to create the DYI mapping table. Let's focus on Mexico for ex.
 * The query below tells me that Mexico is labeled MEX in the DataScience table: */

--order by num desc  
select top 100 * 
FROM datascience.SherpaData sd 
where CountryCode like 'M%'

/*  The query below tells me that Mexico is labeled MX in the datascience BookingDetails Table: that's why we need mapping
 * table!*/
select distinct DestCountry, DestCountryName
from datascience.BookingDetails -- DIY mapping table. It is very important to understand mapping.
where DestCountryName = 'Mexico'

SELECT COUNT(DISTINCT DestCountry) AS unique_country
  from datascience.BookingDetails
  where DestCountryName = 'Mexico'

/* This is what happens if you don't use distinct*/
select DestCountry, DestCountryName
from datascience.BookingDetails bd 
where DestCountryName = 'Mexico'

/*Homework - Try out left join see what happens. Go to mode later to learn different joins. The LEFT JOIN command tells
 the database to return all rows in the table in the FROM clause, regardless of whether or not they have matches in
 the table in the LEFT JOIN clause.*/


select SearchDepartureToCountry, num, CR, sherpa.*
from  
(
select top 100 SearchDepartureToCountry, count(1) num, AVG(IsBooked) *100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
LEFT JOIN 
(
select distinct DestCountry, DestCountryName
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName

 /*However I don't immediately see the difference when I perform a left join. Let's simplify my tables to understand 
 what's happening*/
select SearchDepartureToCountry, num, sherpa.*
from
(
select top 5 SearchDepartureToCountry, count(1) num, AVG(IsBooked) *100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
LEFT JOIN --After running the quesy below I realized this is not the right place where to perform the left join
(
select distinct DestCountry, DestCountryName
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa --The left join must be performed here
on sherpa.CountryName = cm.DestCountryName

select top 5 SearchDepartureToCountry, num, sherpa.*
from
(
select top 5 SearchDepartureToCountry, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
JOIN 
(
select distinct DestCountry, DestCountryName
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry
--LEFT JOIN datascience.SherpaData sherpa 
/*Now I see that US row also was added, even if there's no matches with 
the table in the LEFT JOIN clause*/
right join datascience.SherpaData sherpa 
on sherpa.CountryName = cm.DestCountryName

select *
from datascience.SherpaData sd 

select top 10 SearchDepartureToCountry, count(1) num 
from searches.searchlog s 
where SearchDate = today()
group by SearchDepartureToCountry 
order by num desc

select DestCountry, DestCountryName
from datascience.BookingDetails bd 

/* If I switch the tables after from and LEFT JOIN I get error ASK SARA*/
select top 5 SearchDepartureToCountry, num, sherpa.*
from datascience.SherpaData sherpa
LEFT JOIN 
(
select top 5 SearchDepartureToCountry, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
JOIN 
(
select distinct DestCountry, DestCountryName
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry /*Now I see that US row also was added, even if there's no matches with 
the table in the LEFT JOIN clause*/
on sherpa.CountryName = cm.DestCountryName
 

select top 5 SearchDepartureToCountry, num, sherpa.*
from
(
select top 5 SearchDepartureToCountry, count(1) num, AVG(IsBooked) *100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
JOIN 
(
select distinct DestCountry, DestCountryName
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry
RIGHT JOIN datascience.SherpaData sherpa --Now I see that GB row also was added, even if there's no matches with the table in the LEFT JOIN clause
on sherpa.CountryName = cm.DestCountryName

/*Right join: Right joins are similar to left joins except they return all rows from the table in the RIGHT JOIN 
 clause and only matching rows from the table in the FROM clause.*/



/*REFERENCE*/

select SearchDepartureToCountry, num, CR, sherpa.*
from  
(
select top 100 SearchDepartureToCountry, count(1) num, AVG(IsBooked) *100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
JOIN 
(
select distinct DestCountry, DestCountryName  /*cm is the DYI country mapping, necessary because country codes in the 
2 tables I'm interested in don't match*/
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName


/*What if we wanted to add RPT? Let's take a look*/ 
select DestCountry, DestCountryName, RPT_USD
from datascience.BookingDetails

/* How do I eliminate duplicates? ASK SARA */
select top 10 SearchDepartureToCountry, searches, bookings, rpt, sherpa.*
from
(
select top 10 SearchDepartureToCountry, count(1) searches
from searches.searchlog s
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry
order by searches desc
) sa
join 
(
select DestCountry, DestCountryName, count(1) bookings, avg(RPT_USD) rpt
from datascience.BookingDetails bd
where BookDate = today()
group by DestCountry, DestCountryName
order by bookings desc
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName

select top 10 *
from datascience.BookingDetails bd 


SELECT SearchDepartureToCountry, num, RPT_USD
FROM 
(
select top 10 SearchDepartureToCountry, num, RPT_USD
from
(
select top 10 SearchDepartureToCountry, count(1) num
from searches.searchlog s
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry
order by num desc
) sa
join 
(
select distinct DestCountry, DestCountryName, RPT_USD
from datascience.BookingDetails bd 
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName
) incl_RPT

/*Try the full join: LEFT JOIN and RIGHT JOIN each
  return unmatched rows from one of the tables—FULL JOIN returns unmatched rows from both tables*/
select SearchDepartureToCountry, num, CR, sherpa.*
from  
(
select top 100 SearchDepartureToCountry, count(1) num, AVG(IsBooked) *100 CR
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa
JOIN 
(
select distinct DestCountry, DestCountryName  /*cm is the DYI country mapping, necessary because country codes in the 
2 tables I'm interested in don't match*/
from datascience.BookingDetails  
) cm on sa.SearchDepartureToCountry = cm.DestCountry
FULL JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName

/*Try Union ASK SARA: is this why union doesn't work?
 * SQL has strict rules for appending data:

Both tables must have the same number of columns
The columns must have the same data types in the same order as the first table

**/
(select top 5 SearchDepartureToCountry
from searches.searchlog) destination
UNION ALL
(select distinct DestCountry, DestCountryName, RPT_USD
from datascience.BookingDetails) number

--Union: same column names and type

select SearchDepartureToCountry, num, sherpa.*
FROM 
(
select top 5 SearchDepartureToCountry, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa 
join
(
select distinct DestCountry, DestCountryName 
from datascience.BookingDetails 
) cm on sa.SearchDepartureToCountry = cm.DestCountry
RIGHT join datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName 

/*Look at antijoin look at where we don't have the same name
Find pieces where BookingDetails doesn't join sherpadata

*An anti-join is a form of join with reverse logic. Instead of returning rows when there is a match 
*(according to the join predicate) between the left and right side,
*an anti-join returns those rows from the left side of the predicate for which there is no match on the right.*/
-- can se
select distinct DestCountry, DestCountryName 
from datascience.BookingDetails

select *
from 
(
select distinct DestCountry, DestCountryName 
from datascience.BookingDetails 
) cm 
--left anti join datascience.SherpaData sherpa
right anti join datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName
order by CountryCode

select *
from datascience.SherpaData sd 
where CountryName like 'U%'

/*Right anti join change the order of the tables and it should work,, let's do this as a homework!
 * RPT: groupb by both dest country and country name, select both and run the aggregations so you always have it with you
 * */


/*Understanding full join, antijoin and union. Start from the right join. Replace right with full and see what happens*/

select top 5 SearchDepartureToCountry, num, sherpa.*
FROM 
(
select top 5 SearchDepartureToCountry, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa 
join
(
select distinct DestCountry, DestCountryName 
from datascience.BookingDetails 
) cm on sa.SearchDepartureToCountry = cm.DestCountry
--RIGHT join datascience.SherpaData sherpa
full join datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName 

/*To understan the difference between
  full join and union check out this video: https://www.geeksforgeeks.org/difference-between-join-and-union-in-sql/
  Basically with a Union the result is new rows (stacks the tables vertically*/


select top 5 SearchDepartureToCountry, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc

UNION 

select distinct DestCountry, DestCountryName 
from datascience.BookingDetails 

/*To understand antijoin: replace the word right with anti. Anti-join between two tables returns rows from the 
 * first table where no matches are found in the second table. It is opposite of a semi-join. 
 * An anti-join returns one copy of each row in the first table for which no match is found.
 * */
select top 5 SearchDepartureToCountry, num, sherpa.*
FROM 
(
select top 5 SearchDepartureToCountry, count(1) num
from searches.searchlog s 
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry 
order by num desc
) sa 
join
(
select distinct DestCountry, DestCountryName 
from datascience.BookingDetails 
) cm on sa.SearchDepartureToCountry = cm.DestCountry
anti join datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName 

/*Review Group By, what is each row, naming*/

 /*Leave these questions below for another day */
/* Move to question #3: I want to find countries with high search and low CR*/
select top 10 SearchDepartureToCountry, count(1) num, AVG(IsBooked) * 100
from searches.searchlog s 
-- where SearchDate => today()-1 - 7
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc
-- To calculate CR i'll have to find out how many flights where booked. IsBooked gives me an error
select top 100 IsBooked count(1) num
from searches.searchlog s 
where SearchDate > today() - 7
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

select DestCountry, DestCountryName, RPT_USD
from datascience.BookingDetails

/*AUG 28 
 * Using comparison operators with joins. In the lessons so far, you've only joined tables by exactly matching values 
 * from both tables. However, you can enter any type of conditional statement into the ON clause.*/

select top 10 SearchDepartureToCountry ToCountry, searches, bookings, RPT, sherpa.*
from
(
select top 10 SearchDepartureToCountry, count(1) searches
from searches.searchlog s
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry
order by searches desc
) sa
join 
(
select DestCountry, DestCountryName, count(1) bookings, avg(RPT_USD) RPT
from datascience.BookingDetails bd
where BookDate = today()
group by DestCountry, DestCountryName
order by bookings desc
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName 
/*and bookings > 30 Exception: JOIN ON inequalities are not supported. Unexpected 'bookings > 30
and sherpa.FullyVaccinated > 0 ASK SARA: why do I get this error? Exception: JOIN ON inequalities are not supported.  
and RPT > 40 Unexpected 'RPT > 40'*/
where sherpa.FullyVaccinated = 1 and (sherpa.TravelOpenness = 'LEVEL_1' or sherpa.TravelOpenness = 'LEVEL_2')

/*Joining on multiple keys to make the query go faster*/
select top 10 SearchDepartureToCountry ToCountry, searches, bookings, RPT, sherpa.*
from
(
select top 10 SearchDepartureToCountry, count(1) searches
from searches.searchlog s
where SearchDate = today()
and IsCheapestGlobal = 1
group by SearchDepartureToCountry
order by searches desc
) sa
join 
(
select DestCountry, DestCountryName, count(1) bookings, avg(RPT_USD) RPT
from datascience.BookingDetails bd
where BookDate = today()
group by DestCountry, DestCountryName
order by bookings desc
) cm on sa.SearchDepartureToCountry = cm.DestCountry
JOIN datascience.SherpaData sherpa
on sherpa.CountryName = cm.DestCountryName 
/*and bookings > 30 Exception: JOIN ON inequalities are not supported. Unexpected 'bookings > 30
and sherpa.FullyVaccinated > 0 ASK SARA: why do I get this error? Exception: JOIN ON inequalities are not supported.  
and RPT > 40 Unexpected 'RPT > 40'*/
--and sherpa.TravelOpenness = cm.DestCountry
--and sherpa.TravelOpenness != cm.DestCountry
--ASK SARA: why is != not working*/
where sherpa.TravelOpenness != cm.DestCountry

/* Self joining tables Sometimes it can be useful to join a table to itself.
  */
select *
from datascience.SherpaData sherpa
join datascience.SherpaData vax_level 
on sherpa.CountryCode = vax_level.CountryCode

select top 10 CountryCode code, CountryName name, FullyVaccinated vax
from datascience.SherpaData sherpa
join datascience.SherpaData vax_level 
on sherpa.CountryCode = vax_level.CountryCode





/*Datatypes AUG 29- CAST AS doesn't work
 * SELECT CAST(funding_total_usd AS varchar) AS funding_total_usd_string,
       founded_at_clean::varchar AS founded_at_string
  FROM tutorial.crunchbase_companies_clean_date*/
select *
cast (vax as varchar) vax_string,
--name:: varchar AS name_string
from datascience.SherpaData sherpa
group by CountryCode,CountryName, FullyVaccinated 

/*SQL Date Format - AUG  29* - Interval, NOW()*/
select *
INTERVAL '1 week' plus_one_week --  INTERVAL DOESN'T WORK - ASK SARA
from datascience.BookingDetails bd 
WHERE BookDate = today()

/*You can add the current time (at the time you run the query) into your code using the NOW()function:
 * */

select top 10 CountryCode code, CountryName name, FullyVaccinated vax,
NOW() - FullyVaccinated vax::timestamp time
--case when vax = 1 then 'yes'
--else null end as 'not-vaccinated'
from datascience.SherpaData sherpa
group by CountryCode,CountryName, FullyVaccinated 


/*SELECT companies.permalink,
       companies.founded_at_clean,
       NOW() - companies.founded_at_clean::timestamp AS founded_time_ago
  FROM tutorial.crunchbase_companies_clean_date companies
 WHERE founded_at_clean IS NOT NULL*/

 /*AUG 29 2021 - Data Wrangling with SQL: Data that is entered manually by humans is typically fraught with errors; 
  * data collected from websites is often optimized to be displayed on websites, not to be sorted and aggregated.
  * If you work with SQL regularly, you'll need to become really comfortable with these skills, as they are what will 
  * allow you to get to the fun stuff.*/
 
 /*AUG 29 - Using SQL String Functions to Clean Data
  *LEFT, RIGHT, and TRIM are all used to select only certain elements of strings,
  *  but using them to select elements of a number or date will treat them as strings for the purpose of 
  * the function.
  * You can use LEFT to pull a certain number of characters from the left side of a string and present them as a separate
  * string. The syntax is LEFT(string, number of characters). Similar reasoning for right*/

select top 10 CountryCode, 
	CountryName,
left(CountryName, 2)
from datascience.SherpaData sherpa
group by CountryCode,CountryName
 
select top 10 CountryCode, 
	CountryName,
right(CountryName, 3)
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*The LENGTH function returns the length of a string. */
select top 10 CountryCode, 
	CountryName,
left(CountryName, 5) lefty,
right(CountryName, length(CountryName) - 3) rightylengthy
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*AUG 30 - Using SQL String Functions to Clean Data - The TRIM function is used to remove characters from the beginning and end of a string.
 * The TRIM function takes 3 arguments. First, you have to specify whether you want to remove characters from the 
 * beginning ('leading'), the end ('trailing'), or both ('both', as used above). Next you must specify all characters 
 * to be trimmed. Any characters included in the single quotes will be removed 
 * from both beginning, end, or both sides of the string. Finally, you must specify the text you want to trim using
 *  FROM.*/

select top 10 CountryCode, 
	trim(both'()' from CountryCode)
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*AUG 31 - Using SQL String Functions to Clean Data - POSITION and STRPOS
POSITION allows you to specify a substring, then returns a numerical value equal to the character number (counting
 from left) where that substring first appears in the target string. For example, the following 
query will return the position of the character 'A' (case-sensitive) where it first appears in the descript field:*/

select top 10 CountryCode, 
	position('C' IN CountryCode) c_position
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*You can also use the STRPOS function to achieve the same results—just replace IN with a comma and switch the order 
 * of the string and substring. Looks like STRPOS doesn't work in Clickhouse.*/


select top 10 CountryCode, 
	STRPOS(CountryCode, 'C') c_position
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*SEP 1 - Using SQL String Functions to Clean Data: LEFT and RIGHT both create substrings of a specified length, but they only
 * do so starting from the sides of an existing string. If you want to start in the middle of a string, you can use SUBSTR.
 * The syntax is SUBSTR(*string*, *starting character position*, *# of characters*)*/

select top 10 CountryCode, 
	substr(CountryCode, 1, 2) c_position
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*CONCAT
You can combine strings from several columns together (and with hard-coded values) using CONCAT. Simply order the values
you want to concatenate and separate them with commas. If you want to hard-code values, enclose them in single quotes.
Looks like concat doesn't work for Clickhouse. Ask Sara.*/

select top 10 CountryCode, 
	CountryName,
	left(CountryCode, 2) lefty
	--concat(CountryName, ', ', left(CountryCode, 2)) c_oncat
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*Sep 3: Changing case with UPPER and LOWER*/
select top 10 CountryCode, 
	CountryName,
	upper(CountryName) u_pper,
	lower(CountryName) l_ower
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*Turning Strings Into Dates
Dates are some of the most commonly screwed-up formats in SQL. This can be the result of a few things:

The data was manipulated in Excel at some point, and the dates were changed to MM/DD/YYYY format or another format
that is not compliant with SQL's strict standards. The data was manually entered by someone who use whatever formatting 
convention he/she was most familiar with. The date uses text (Jan, Feb, etc.) intsead of numbers to record months.

In order to take advantage of all of the great date functionality (INTERVAL, as well as some others you will learn in 
the next section), you need to have your date field formatted appropriately. This often 
involves some text manipulation, followed by a CAST or use EXTRACT to pull the pieces apart one-by-one: */

  /*Extract doesn't work, ask Sara*/
select top 10 BookDate,
EXTRACT('year' from BookDate) year
from datascience.BookingDetails bd 

/*You can also round dates to the nearest unit of measurement. This is particularly useful if you don't care about an 
 * individual date, but do care about the week (or month, or quarter) that it occurred in. The DATE_TRUNC function 
 * rounds a date to whatever precision you specify. The value displayed is the first value in that period. 
 * So when you DATE_TRUNC by year, any value in that year will be listed as January 1st of that year:*/

select top 10 BookDate,
DATE_TRUNC('week', BookDate) trunc_week
from datascience.BookingDetails 

/*Only now() and today() seem to work in ClickHouse*/

SELECT --CURRENT_DATE date,
		--CURRENT_TIME AS time
        --CURRENT_TIMESTAMP timestamp
       	--LOCALTIME  localtime
       --LOCALTIMESTAMP localtimestamp
       NOW() now,
       today() today
    
/*at time_zone also seems not working*/      
select now(),
now() at time_zone 'PST' pst
 
/*MODE EXAMPLE: SELECT CURRENT_TIME AS time,
       CURRENT_TIME AT TIME ZONE 'PST' AS time_pst*/

/*COALESCE
Occasionally, you will end up with a dataset that has some nulls that you'd prefer to contain actual values. 
This happens frequently in numerical data (displaying nulls as 0 is often preferable), and when performing 
outer joins that result in some unmatched rows. In cases like this, you can use COALESCE to replace the null values:*/

select top 10 CountryCode, 
	CountryName,
	COALESCE(CountryName, 'No Description')
from datascience.SherpaData sherpa
group by CountryCode,CountryName

/*SEP 4:SQL Window Functions*/

 
 /*  From mode tutorial: SELECT duration_seconds,
       SUM(duration_seconds) OVER (ORDER BY start_time) AS running_total
  FROM tutorial.dc_bikeshare_q1_2012*/

select top 10 Channel channel, TransactionID TID, FP_TotalRevenueUSD tot_rev
sum(tot_rev) OVER (ORDER BY channel) running_total
from datascience.BookingDetails bd

/*ROW_NUMBER()
ROW_NUMBER() displays the number of a given row. It starts are 1 and numbers the rows according to the
 ORDER BY part of the window statement. ROW_NUMBER() does not require you to specify a variable within the parentheses:*/
  
/*From mode: 
 * SELECT start_terminal,
       start_time,
       duration_seconds,
       ROW_NUMBER() OVER (ORDER BY start_time)
                    AS row_number
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'*/

select top 10 Channel channel,
TransactionID tid,
FP_TotalRevenueUSD tot_rev,
ROW_NUMBER() over (order by tid) row_number
from datascience.BookingDetails bd
where tid > 1

/*RANK() and DENSE_RANK() - Give errors
RANK() is slightly different from ROW_NUMBER(). If you order by start_time, for example, it might be the case that
 some terminals have rides with two identical start times. In this case, they are given the same rank, 
 whereas ROW_NUMBER() gives them different numbers.*/

/* From mode
 * 
 *SELECT start_terminal,
       duration_seconds,
       RANK() OVER (PARTITION BY start_terminal
                    ORDER BY start_time)
              AS rank
  FROM tutorial.dc_bikeshare_q1_2012
 WHERE start_time < '2012-01-08'*/

select top 10 Channel channel,
TransactionID tid,
FP_TotalRevenueUSD tot_rev,
allow_experimental_window_functions = 1
rank() over (partition by channel
order by tid) r_ank
from datascience.BookingDetails bd
where tid > 40000000

/*You can use window functions to identify what percentile (or quartile, or any other subdivision) a given row falls
 *  into. The syntax is NTILE(*# of buckets*). In this case, ORDER BY 
 * determines which column to use to determine the quartiles (or whatever number of 'tiles you specify):*/

/*Performance Tuning SQL Queries*/

/*SEP 3rd:  WK would like to find out (a) whether our customers travel is in line with TSA market trend, 
 * (b) when do our customers book to travel, on which weekdays and (c) how can we use this data to increase sales?
 * Compare 2019, 2020, and 2021 */

select Year_BookDate y_ear, OutBoundDateTime outbound, BookingDayOfWeek booked_on
from datascience.BookingDetails bd 
where y_ear >= 2019
order by y_ear desc

select *
from datascience.BookingDetails bd 

show PROCESSLIST

kill query where query_id = '42'
