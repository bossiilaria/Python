
/* Q&A 
1. Where do I find the Sherpa levels? 
It's under DataScience > SherpaData

2. I want to see what are the most searched countries for our Company and for the market

3. I want to find countries with high search and low CR

4. I want to look at the RPT

5. I want to compare this week versus last week

3. I want to compare how many searchesee what the search_From_To table looks like

*/
select today() -- to see what day is today

select now() -- to see what time it is


/* Start with question # 2: Find out how many search we had this week at FP for all countries globally. 
To match the data in our PowerBI we need to look at the data for the current week. 
I find 9M, lower than 15M in powerBI report */

select top 10 SearchDepartureToCountry ToCountry, count(1) num -- count(1) num removes the duplicates
from searches.searchlog s -- Note: s is an alias
where SearchDate >= '2021-08-10' and SearchDate <='2021-08-17'
--where SearchDate >= today() - 7 -- You can chose either one, today() - 7 or write specific dates as above
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

--Remove and IsCheapestGlobal = 1, since that is not a condition in the PowerBI, I find 33M
 
select top 10 SearchDepartureToCountry ToCountry, count(1) num 
from searches.searchlog s 
where SearchDate >= '2021-08-10' and SearchDate <='2021-08-17'
--and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

--The PowerBI shows the searches TODAY. Now I find 221M still larger than the PowerBI > ASK SARA

select top 10 SearchDepartureToCountry ToCountry, count(1) num 
from searches.searchlog s 
where SearchDate = today() 
group by SearchDepartureToCountry 
order by num desc

/* ASK SARA: howdo we get all the columns in one schot without typing each column name? */

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
where TravelOpenness = 'LEVEL_1' or TravelOpenness = 'LEVEL_2'
AND FullyVaccinated = 1
AND Covid19Test = 'NOT_REQUIRED_COVID_19_TEST'


/*Aggregate Sherpa Data*/

select top 100 CountryCode, CountryName, FullyVaccinated, TravelOpenness, EntryRestrictions, Covid19Test, Quarantine,
				Response, UpdatedOn 
from datascience.SherpaData s
WHERE CountryName = 'Aruba' AND FullyVaccinated = 1
--WHERE TravelOpenness = 'LEVEL_1' or TravelOpenness = 'LEVEL_2'
--AND FullyVaccinated = 1
ORDER BY FullyVaccinated desc

/*Homework: run this aggregation on different tables and join tables*/


select top 10 SearchDepartureToCountry, count(1) num, AVG(IsBooked) * 100
from searches.searchlog s 
where SearchDate = today()
--where SearchDate >= '2021-07-30' and SearchDate <= '2021-08-12'
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

/*When I join I get read timeout errors: this is because of the way I aggregated. I need to take a step back and learn 
 * about FRACTALS! The trick is to get the whole aggregation and call it an alias like we did below. Only THEN come back 
 * on top and start selecting from! 
 * One first obstacle is that the SearchDepartureToCountry column in the searchlog table has different codes than the Sherpa
 * table CountryCode column! That is why we need to create a DYI mapping as shown below.
 * Let's build the anatomy of JOIN:
 * after the FROM we have JOIN followed by a table. I'm interested in 2 tables: datascience.SherpaData
  and searches.searchlog. ON is followed by a couple column names separated by an equals sign (ON sherpa.CountryName = 
  cm.DestCountryName) */

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

/* Here below is the reasoning to create the DYI mapping table. Let's focus on Mexico for ex.
 * The query below tells me that Mexico is labeled MEX in the DataScience table: */

--order by num desc  
select top 100 * 
FROM datascience.SherpaData sd 
where CountryCode like 'M%'

/*  The query below tells me that Mexico is labeled MX in the datascience BookingDetails Table: that's why we need mapping
 * table!*/
select distinct DestCountry, DestCountryName
from datascience.BookingDetails -- DIY mapping table
where DestCountryName = 'Mexico'


--write down all of the learnings in comments!!! Very important to understand mapping. Try out left join see what happens.
--Go to mode later to learn different joins




    
-- 1. I get an empty table
select top 100 SearchDepartureToCountry, count(1) num, AVG(IsBooked) * 100
from searches.searchlog sl 
JOIN datascience.SherpaData sherpa 
ON sherpa.CountryName = sl.SearchDepartureToCountry
--where SearchDate >= '2021-07-30' and SearchDate <= '2021-08-12'
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

/*Let's simplify the search to better understand JOIN*/

--select top 10 CountryCode, CountryName, FullyVaccinated, TravelOpenness, EntryRestrictions, Covid19Test, Quarantine,
	--			Response, UpdatedOn 
select top 10 CountryCode, CountryName
from datascience.SherpaData s

select top 10 SearchDepartureToCountry, count(1) num
from searches.searchlog sl 
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

/*SELECT teams.conference AS conference,
       AVG(players.weight) AS average_weight
  FROM benn.college_football_players players
  JOIN benn.college_football_teams teams
    ON teams.school_name = players.school_name
 GROUP BY teams.conference
 ORDER BY AVG(players.weight) DESC*/

select top 100 SearchDepartureToCountry, count(1) num
from searches.searchlog sl 
JOIN datascience.SherpaData s
ON s.CountryCode = sl.SearchDepartureToCountry
where SearchDate = today()
and IsCheapestGlobal = 1 
group by SearchDepartureToCountry 
order by num desc

/* Leave these questions below for another day */
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
show PROCESSLIST

kill query where query_id = '42'
