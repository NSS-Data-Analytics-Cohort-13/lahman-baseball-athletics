-- 1. What range of years for baseball games played does the provided database cover?
--A. 1871-2016

--Use subqueries to pull first year and last year with min and max functions
--Not sure how it may be a benefit to use subqueries....
SELECT DISTINCT (SELECT min(yearid) as first_year FROM teams), (SELECT max(yearid) as last_year FROM teams)
FROM teams

----------------------------------------------------------------------------------------------
-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--A: Eddie Gaedal, with height of 43 inches. Eddie played 1 game as part of the St. Louis Browns

--Used playerid to make sure I am not accidentally pulling other players with similar names
SELECT DISTINCT p.playerid, p.namefirst, p.namelast, height, b.g as number_games_played, t.name
FROM people as p
--inner join to pull number of games played
		INNER JOIN batting as b
		ON b.playerid=p.playerid
--inner join to pull name of team
		INNER JOIN teams as t
		ON b.teamID=t.teamID
WHERE height=
--use WHERE subquery to narrow down result by minumum height
	(SELECT MIN(height) FROM people)

-----------------------------------------------------------------------------------------------
-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each playerâ€™s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--Need to eliminate duplicates but not lose the salary assocated with every player ID. Maybe remove first and last name from the inner query and then do a join with another table to bring in the names. 


SELECT sum(n.salary) as total_salary, n.namefirst, n.namelast, n.playerid
FROM
	(
	SELECT DISTINCT p.playerid, p.namefirst, p.namelast, s.schoolname, sa.salary, sa.yearid
	FROM people as p
		INNER JOIN collegeplaying as c
		ON c.playerid=p.playerid
		INNER JOIN schools as s
		ON s.schoolid=c.schoolid
		INNER JOIN salaries as sa
		ON sa.playerID=p.playerID
	WHERE schoolname= 'Vanderbilt University' 
	--WHERE UNIQUE
	GROUP BY p.playerID, p.namefirst, p.namelast, s.schoolname, sa.salary, sa.yearid
	) as n
GROUP BY n.namefirst, n.namelast, n.playerid
ORDER BY total_salary DESC
--) AS g
--Group by g.namefirst, g.namelast, g.playerid
--ORDER by final_total_salary
--GROUP BY total_salary


---------------------------------------------------------------------------------------------
-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--(2)main query that is used to sum po based on position, for the year 2016.
SELECT sum(n.po) as total_putouts, n.position
FROM
--(1)subquery that categorizes pos
		(
		SELECT playerid, po,yearid, 
			CASE WHEN pos='OF' THEN 'Outfield'
			WHEN pos IN('SS','1B','2B','3B') THEN 'Infield'
			WHEN pos IN('P','C') THEN 'Battery'
			ELSE null
			END as position
		FROM fielding
		) as n
WHERE yearid=2016
GROUP BY n.position
ORDER BY total_putouts



----------------------------------------------------------------------------------------------
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends
--1880 and 1890 decades had highest strikeout average per game
--Before 1980 homerun average was zero, accept for 1930s
--Homerun average was .00007-.00009 for 1980s through 2000s
--Homerun average increased to .0001 in 2010

--Query Steps: 
--Year range for batting table is 1871-2016
--1st step-Create subquery with:
--Narrow down batting table to important column
--Remove null rows with null values
--Round years to decades
--Calculate the strikeouts per game
--Group by decade
--2nd step-Create main query with:
--Calculate and round the average strikeouts/number of games
--FROM subquery table
--Group by decade
--Group realization: Need to combine with battingpost to cover postseason games
--Made a subquery using full join to join batting and battingpost, and had to remove decade calculation
--Made main query to convert years to decades
--Query looked messy so I created a CTE
--Then I created a final query to calculate the average (rounded) strikeouts per game for each decade

--STRIKEOUTS


-- WITH totals AS (SELECT (ROUND(years/10,0)*10) as decade, strikeouts,number_of_games, homeruns --ROUND(avg(strikeouts/number_of_games),2) as avgstrikeouts_per_game
-- FROM
-- (SELECT b.yearid as years,b.so as strikeouts, b.g as number_of_games, --(ROUND(yearid/10,0)*10) as decade, 
-- b.hr as homeruns
-- FROM batting AS b
-- FULL JOIN battingpost as ba
-- ON b.playerid=ba.playerid
-- WHERE b.so IS NOT NULL AND ba.so is not null) as totalstable
-- GROUP BY strikeouts, number_of_games, homeruns, years
-- ORDER BY decade)

-- SELECT *
-- FROM(Select decade, ROUND(avg(strikeouts/number_of_games),2) as avg_strikeouts_per_game
-- From Totals
-- GROUP By decade
-- ORDER By avg_strikeouts_per_game) as finaltable
-- ORDER By decade asc


Select f.decade, ROUND(avg(strikeouts/number_of_games),2) as avgstrikeouts_per_game
FROM
	(
	SELECT yearid, ROUND(yearid/10,0)*10 as decade,so as strikeouts, g as number_of_games, hr as homeruns
	From teams
	WHERE yearid>1919
	GROUP By strikeouts, number_of_games, homeruns, yearid
	ORDER BY decade 
	) as f
GROUP BY f.decade
ORDER BY avgstrikeouts_per_game



-- Select (ROUND(yearid/10,0)*10) as decade, yearid
-- FROM batting
-- Group by yearid
-- Order by decade

--HOMERUNS
--Used same CTE, but in the final query, I replaced strikeouts with homeruns

-- WITH totals AS (SELECT (ROUND(years/10,0)*10) as decade, strikeouts,number_of_games, homeruns --ROUND(avg(strikeouts/number_of_games),2) as avgstrikeouts_per_game
-- FROM
-- (SELECT b.yearid as years,b.so as strikeouts, b.g as number_of_games, --(ROUND(yearid/10,0)*10) as decade, 
-- b.hr as homeruns
-- FROM batting AS b
-- FULL JOIN battingpost as ba
-- ON b.playerid=ba.playerid
-- WHERE b.so IS NOT NULL AND ba.so is not null) as totalstable
-- GROUP BY strikeouts, number_of_games, homeruns, years
-- ORDER BY decade)

-- SELECT *
-- FROM(Select decade, ROUND(avg(homeruns/number_of_games),2 as avg_homeruns_per_game
-- From Totals
-- GROUP By decade
-- ORDER By avg_homeruns_per_game) as finaltable
-- ORDER By decade asc

-- Select so, yearid
-- from battingpost

--Using teams table
Select f.decade, ROUND(avg(homeruns/number_of_games),2) as avghomeruns_per_game
FROM
	(
	SELECT yearid, ROUND(yearid/10,0)*10 as decade,so as strikeouts, g as number_of_games, hr as homeruns
	From teams
	WHERE yearid>1920
	GROUP By strikeouts, number_of_games, homeruns, yearid
	ORDER BY decade 
	) as f
GROUP BY f.decade
ORDER BY avghomeruns_per_game

-----------------------------------------------------------------------------------------------
6.-- Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
--Stolen base attempt-caught stealing=stolen bases
--Percent success=stolen bases/(stolen base attempts)

--1st step: 
--Create table with playerid, yearid, sb, cs 
--Add narrowing criteria with WHERE statement
--Add calculation for total successful stolen bases and add descending order
--Result is hamilbi02 with 50 successful stolen bases.
--2nd step: link this table as to a table with the people table INNER JOIN (and add the name columns that are needed from the people table)


SELECT sub.first_name, sub.last_name, sub.successful_stolen_base, sub.stolen_base_attempts, (100*SUM(sub.successful_stolen_base)/SUM(sub.stolen_base_attempts)) AS percentage_success 
FROM
(
SELECT b.playerid, p.namefirst as first_name, p.namelast as last_name, sb as successful_stolen_base, cs as caught_stealing, sb+cs as stolen_base_attempts
FROM batting as b
INNER JOIN people as p
ON p.playerid=b.playerid
WHERE (b.sb+b.cs)>=20 and b.yearid=2016 
GROUP BY b.playerid, first_name,last_name,caught_stealing,successful_stolen_base  
ORDER BY stolen_base_attempts
) AS sub
GROUP BY sub.first_name, sub.last_name, sub.successful_stolen_base, sub.stolen_base_attempts
ORDER BY percentage_success DESC
--A: Chris Owings, with 91% success rate fr stolen base attempts

------------------------------------------------------------------------------------------------
7.-- From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? 

SELECT yearid
, teamid
, name
, w as wins
--, l as losses
, wswin as world_series
FROM teams
WHERE yearid BETWEEN 1970 and 2016 
AND wswin<>'Y'
ORDER BY wins DESC
--A: SEA (Seattle Mariners) with 116 wins in 2001


--What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion â€“ determine why this is the case. 

SELECT yearid
, teamid
, name
, w as wins
--, l as losses
, wswin as world_series
FROM teams
WHERE yearid BETWEEN 1970 and 2016 
AND wswin='Y'
ORDER BY wins ASC
--A: LA Dodgers, 63 wins in 1981 
--Per wikipedia: "Games were suspended for 50 days due to the 1981 Major League Baseball strike, causing a split season." Blue jays did terrible in the first portion of the split season. 


--Then redo your query, excluding the problem year. 

--Addition to WHERE clase to remove yearid 1981
SELECT yearid
, teamid
, name
, w as wins
, l as losses, 
wswin as world_series
FROM teams
WHERE yearid BETWEEN 1970 and 2016 
AND yearid <>1981
AND wswin='Y'
ORDER BY wins ASC
--A. Changes the result to St. Louis Cardinal who won 83 games in 2006

--How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


--Table of WS winners
SELECT yearid
, teamid
, name
, w as wins
, l as losses, 
wswin as world_series
FROM teams
WHERE yearid BETWEEN 1970 and 2016 
AND yearid <>1981
AND wswin='Y'
ORDER BY wins ASC

--(CTE) Table of most wins each year
WITH most_wins AS
(
SELECT DISTINCT yearid
, max(w) as mostwins, count(yearid) as total_years
FROM teams
WHERE yearid BETWEEN 1970 and 2016 
--AND yearid <>1981
GROUP BY yearid
ORDER BY mostwins, total_years
)

--Last step: Combine both tables above to obtain teams with the most wins in the same year that they won the WS. Convert second query into a CTE and join both tables with INNER JOIN

SELECT ROUND((SUM(total)/COUNT(m.total_years))*100,2) AS percent_time
FROM
	(
	SELECT (COUNT(t.yearid)) as total 
	, t.teamid
	, name
	, t.w as wins
	, t.wswin as world_series
	, mostwins
	FROM teams as t
	INNER JOIN most_wins as m 
	USING (yearid)
	WHERE yearid BETWEEN 1970 and 2016 
	AND yearid <>1981
	AND wswin='Y'
	AND t.w=mostwins
	GROUP BY t.teamid
	, name
	, wins
	, world_series
	, mostwins
	ORDER BY total
	) AS subg
--A: 12 years/45 years-->26.7%


-------------------------------------------------------------------------------------------------
--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Select statement for: team ID, team name, park ID, park name, and calculated avg attendance
--team ID and park ID included to reduce duplicates
	SELECT DISTINCT h.team, t.name as team_name, h.park, p.park_name as park_name,(h.attendance/h.games) AS avg_attendance 
--Inner joins between homegames table, teams table, and parks table
--Inner join between homegames and teams with 2 columns, team ID and year-->This helps reduce duplicates that occur with using only either team ID or year
	FROM homegames AS h
	INNER JOIN teams as t
	ON h.year=t.yearid AND h.team = t.teamid
	INNER JOIN parks as p
	ON p.park=h.park
--WHERE criteria to narrow to teams that played at least 10 games in 2016. 
	WHERE games >=10 AND year=2016
	GROUP BY h.park, h.team, h.attendance, h.games, t.name,park_name
--DESC to get top 5 teams/parks with highest avg_attendance
	ORDER BY avg_attendance DESC
	LIMIT 5
--A: Top: Dodger Stadium, Los Angeles Dodgers, average attendance of 45,719. 
	
SELECT DISTINCT h.team, t.name as team_name, h.park, p.park_name as park_name,(h.attendance/h.games) AS avg_attendance 
	FROM homegames AS h
	INNER JOIN teams as t
	ON h.team = t.teamid AND h.year=t.yearid
	INNER JOIN parks as p
	ON p.park=h.park
	WHERE games >=10 AND year=2016
	GROUP BY h.park, h.team, h.attendance, h.games, t.name,park_name
	ORDER BY avg_attendance ASC
	LIMIT 5
 --A: Bottom: Tropicana Field, Tampa Bay Rays, average attendance 15,8

------------------------------------------------------------------------------------------------	
--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.


-- SELECT 
-- playerid
-- , yearid
-- , lgid
-- --, CASE WHEN lgid='AL' THEN 'YES' ELSE 'NO' END AS al
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year'
-- AND lgid<>'ML'
-- AND lgid<>'NL'

-- SELECT 
-- a.playerid
-- --, namefirst
-- --, namelast
-- , a.yearid
-- , a.lgid AS NL
-- --, teamid
-- --, inseason
-- FROM awardsmanagers as a
-- --INNER JOIN managershalf as h
-- --ON h.playerid=a.playerid 
-- --INNER JOIN people as p
-- --ON h.playerid=p.playerid
-- WHERE awardid = 'TSN Manager of the Year'
-- AND a.lgid<>'ML'
-- --AND h.inseason=1
-- AND a.lgid<>'AL'

-- SELECT *
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year'
-- AND lgid<>'ML'
-- AND playerid='leylaji99'
-- SELECT *
-- FROM managershalf
-- WHERE playerid='leylaji99'

-- SELECT 
-- a.playerid
-- , a.yearid
-- , a.lgid AS AL
-- , teamid
-- , inseason
-- FROM awardsmanagers as a
-- --INNER JOIN managershalf as h
-- ON h.playerid=a.playerid 
-- WHERE awardid = 'TSN Manager of the Year'
-- AND a.lgid<>'ML'
-- AND h.inseason=1
-- AND a.lgid<>'NL'




--Need to do another subquery for each CTE to remove the opposite award
--(AL award winners with awardid= 'TSN Manager of the Year' AND lgid<>'ML'
WITH AL_table AS
(
SELECT sub1.playerid,namefirst, namelast, yearid AS alyear, CASE WHEN al='AL' THEN 'Yes' ELSE 'No' END AS AL
FROM
		(
		SELECT  playerID, awardID, yearid, lgid as AL, lgid as NL
		FROM awardsmanagers
		WHERE awardid= 'TSN Manager of the Year' AND lgid<>'ML'
		) as sub1
INNER JOIN people as p
ON p.playerid=sub1.playerid
),

NL_table AS
(
SELECT sub2.playerid
, namefirst,namelast
, yearid as nlyear
, CASE WHEN al='NL' THEN 'Yes' ELSE 'No' END AS NL
FROM
		(
		SELECT  playerID, awardID, yearid, lgid as AL, lgid as NL
		FROM awardsmanagers
		WHERE awardid= 'TSN Manager of the Year' AND lgid<>'ML'
		) as sub2
INNER JOIN people as p
ON p.playerid=sub2.playerid
)

SELECT sub3.namefirst, sub3.namelast, sub3.alyear, sub3.nlyear, sub3.both_awards-- sub3.name,
--, CASE WHEN AL='Yes' AND NL='Yes' THEN 'Yes' ELSE 'No' END AS both_awards
FROM
		(
		Select a.playerID
		, a.namefirst
		, a.namelast
		, alyear
		, nlyear
		, CASE WHEN AL='Yes' AND NL='Yes' THEN 'Yes' ELSE 'No' END AS both_awards
		FROM AL_table as a
		INNER JOIN NL_table as n
		ON a.playerid=n.playerid
		--INNER JOIN teams as t
		--ON t.yearid=n.yearid 
		--INNER JOIN people as p
		--ON p.playerid=a.playerid
		) as sub3
--INNER JOIN managershalf as h
--ON h.playerid=sub3.playerid
WHERE both_awards='Yes' 
--AND INSEASON=1



-- SELECT *
-- FROM player


-- SELECT playerID,sum(al_award+nl_award) AS both_awards
-- --, sum(al_award) as AL
-- --, sum (nl_award) as NL
-- ,yearid
-- FROM
-- (
-- SELECT playerid
-- , yearid
-- , (CASE WHEN lgid= 'AL' THEN 1 ELSE 0 END) AS al_award
-- , (CASE WHEN lgid= 'NL' THEN 1 ELSE 0 END) AS nl_award
-- FROM awardsmanagers
-- WHERE awardid= 'TSN Manager of the Year'
-- ) as sub 
-- WHERE al_award <> 0 AND nl_award<>0
-- GROUP By
-- playerID 
-- , al_award
-- , nl_award
-- ,yearid
-- Order BY al_award, nl_award

-- --both_awards

-- --WHERE playerid = 'leylaji99'


-- WHERE al_award=1 OR nl_award =1

-- SELECT *
-- FROM awardsmanagers
-- WHERE awardid= 'TSN Manager of the Year'
-- AND (lgid='NL' OR lgid='AL')


-- SELECT DISTINCT sub.playerid, firstname, lastname, AL_win_year, NL_win_year, sub.name
-- FROM
-- 		--(1)Self join awardsmanagers table 
-- 		(SELECT DISTINCT p.namefirst as firstname, p.namelast as lastname, t.lgid, g.lgid, t.yearid AS AL_win_year, g.yearid AS NL_win_year, e.name as name--,t.awardid, t.playerid AS playerid, 
-- 		FROM awardsmanagers as t
-- 		INNER JOIN awardsmanagers as g
-- 		using (playerid)
-- 		INNER JOIN people as p
-- 		USING (playerid)
-- 		INNER JOIN TEAMS as e
-- 		ON e.lgid=t.lgid
-- 		--(2)Criteria to seach for managers have won the TSN Manager of the Year award in both NL and AL
-- 		WHERE t.lgid='AL' 
-- 		AND g.lgid='NL' 
-- 		AND t.awardid= 'TSN Manager of the Year' 
-- 		AND g.awardid='TSN Manager of the Year') as sub

-- --conversion of inner joins to unions to try to eliminate duplicates
-- SELECT sub.playerid, firstname, lastname, AL_win_year, NL_win_year, sub.name
-- FROM
-- 		--(1)Self union awardsmanagers table 
-- 		(SELECT DISTINCT t.playerid, p.namefirst, p.namelast, t.lgid, t.yearid AS AL_win_year, e.teamid  --p.namefirst as firstname, p.namelast as lastname, t.lgid, g.lgid, t.yearid AS AL_win_year, g.yearid AS NL_win_year, e.name as name--,t.awardid, 
-- 		FROM awardsmanagers as t
-- 		INNER JOIN people as p
-- 		USING (playerid)
-- 		INNER JOIN TEAMS as e
-- 		ON e.lgid=t.lgid
-- 		WHERE t.lgid='AL' 
-- 		AND t.awardid= 'TSN Manager of the Year' 
-- --WHERE clause subquery to look for AL and TSN Manager of the Year
-- 		UNION
-- 		SELECT g.playerid, p.namefirst, p.namelast, g.lgid, g.yearid AS NL_win_year, e.teamid
-- 		--,CASE WHEN g.lgid='NL' THEN 'Y'
-- 		--ELSE ''
-- 		--END AS NL_award
-- 		FROM awardsmanagers as g
-- 		INNER JOIN people as p
-- 		USING (playerid)
-- 		INNER JOIN TEAMS as e
-- 		ON e.lgid=g.lgid
-- 		WHERE g.lgid='NL' 
-- 		AND g.awardid='TSN Manager of the Year') as sub
-- WHERE lgid= 'NL'

-- SELECT DISTINCT 
-- sub.playerid
-- --, sub.namefirst
-- --, sub.namelast
-- , sub.yearid
-- , sub.al_award
-- , sub.nl_award
-- , sub.teamid
-- FROM
-- --subquery
-- (
-- SELECT DISTINCT t.playerid, p.namefirst, p.namelast, t.yearid,(CASE WHEN t.lgid= 'AL' THEN 'Y'
-- ELSE '' END) AS al_award, (CASE when t.lgid='NL' THEN 'Y' ELSE '' END) AS nl_award, e.teamid  --p.namefirst as firstname, p.namelast as lastname, t.lgid, g.lgid, t.yearid AS AL_win_year, g.yearid AS NL_win_year, e.name as name--,t.awardid, 
-- 		FROM awardsmanagers as t
-- 		INNER JOIN people as p
-- 		USING (playerid)
-- 		INNER JOIN TEAMS as e
-- 		ON e.lgid=t.lgid
-- 		--WHERE t.lgid='AL' 
-- 		WHERE t.awardid= 'TSN Manager of the Year') AS sub
-- --WHERE al_award= 'Y' AND nl_award ='Y'




-- 		Select *
-- 		FROM teams
	
	
-- 		--(2)Criteria to seach for managers have won the TSN Manager of the Year award in both NL and AL
-- 		WHERE t.lgid='AL' 
-- 		AND g.lgid='NL' 
-- 		AND t.awardid= 'TSN Manager of the Year' 
-- 		AND g.awardid='TSN Manager of the Year') as sub



------------------------------------------------------------------------------------------------
--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
--Need to do COUNT(DISTINT

-- select *
-- from people
-- select *
-- from batting

--(4) Convert to a CTE
WITH tableforten AS
--(2)Main query to narrow down results to players who played >10 years-->70 results

(SELECT DISTINCT playerid,namefirst, namelast, homeruns--, yearid
FROM
			(
			--(1)Query to filter for playerid's (using batting table inner joined with people table), where player hit at least one home run in 2016
			--(2)Converted debut and final game to year that is an integer
			--(3)sum the total of homeruns (which eliminates repeating player names)-->515 results
			SELECT DISTINCT playerid, namefirst, namelast, sum(hr) as homeruns,  CAST((left(p.finalgame,4)) AS INT) AS finalgame, CAST((left(p.debut,4)) AS INT) AS debut--, batting.yearid
			FROM batting
			INNER JOIN people AS p
			USING (playerid)
			WHERE yearid=2016 AND hr>=1
			GROUP BY playerid, namefirst, namelast, finalgame, debut--, batting.yearid
			ORDER BY homeruns
			) as sub
WHERE finalgame - debut > 10
GROUP BY homeruns, playerid, namefirst, namelast--, yearid
ORDER BY homeruns DESC),

maxhr AS
(
SELECT playerid
, Max(hr) as maxhomeruns
, yearid 
FROM batting
WHERE hr<>0 
AND yearid=2016
GROUP By playerid, yearid
ORDER BY maxhomeruns desc
)


SELECT DISTINCT 
--m.playerid, 
maxhomeruns
, m.yearid
, t.homeruns
, t.namefirst
, t.namelast
FROM maxhr as m
INNER JOIN tableforten as t
ON t.playerid=m.playerid --and t.yearid=m.yearid
WHERE t.homeruns=maxhomeruns
--AND m.yearid='2016'


--Last step: How do I narrow the results to players who had their max # of homeruns in 2016?
-- SELECT playerid, homeruns, 
-- FROM tableforten
-- INNER JOIN batting
-- ON b.hr=tableforten.homeruns
-- WHERE yearid=2016 AND hr>=1 AND max(hr) = homeruns
-- GROUP By playerid, homeruns

-- SELECT playerid, homeruns, yearid
-- FROM tableforten as t
-- UNION



SELECT playerid, maxhomeruns, b.yearid 
FROM maxhomeruns
INNER JOIN tableforten
USING (playerid)
WHERE homeruns=maxhomeruns

-- SELECT (Select playerid, Max(hr) as maxhr FROM batting WHERE yearid=2016 GROUP By playerid), namefirst, namelast, homeruns
-- FROM tableforten
-- WHERE maxhr


--Note that there are repeating names of players in 2016. Example is arciaos01. Each row of data show difference in teamid and number of hr, therefore it is presumed these rows are not duplicates. 
SELECT *
FROM batting
WHERE playerid='arciaos01'
--CAST (p.finalgame AS DATE) AS finalgame

------------------------------------------------------------------------------------------------
--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

--12. In this question, you will explore the connection between number of wins and attendance.

	--Does there appear to be any correlation between attendance at home games and number of wins?
	--Do teams that win the world series see a boost in attendance the following year? 
	--What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
	--It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. 
	--First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 	--Are left-handed pitchers more likely to win the Cy Young Award? 
	--Are they more likely to make it into the hall of fame?

