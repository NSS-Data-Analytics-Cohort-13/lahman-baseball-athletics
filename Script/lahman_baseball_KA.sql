-- 1. What range of years for baseball games played does the provided database cover?
--A. 1817-2016

--Use subqueries to pull first year and last year with min and max functions
--Not sure how it may be a benefit to use subqueries....
SELECT DISTINCT (SELECT min(yearid) as first_year FROM teams), (SELECT max(yearid) as last_year FROM teams)
FROM teams


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


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--Need to eliminate duplicates but not lose the salary assocated with every player ID. Maybe remove first and last name from the inner query and then do a join with another table to bring in the names. 

--SELECT SUM(total_salary) as final_total_salary, g.namefirst, g.namelast, g.playerid
--FROM
--(
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


--(SELECT p.playerID FROM people WHERE p.playerid=sa.playerid)
-- select*
-- FROM fieldingpost

-- select *
-- FROM appearances 

-- Select *
-- FROM salaries

-- SELECT *
-- FROM teamsfranchises

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--(2)main query that is used to sum po based on position, for the year 2016.
SELECT sum(n.po) as total_putouts, n.position
FROM
--(1)subquery that categorizes pos
		(SELECT playerid, po,yearid, 
			CASE WHEN pos='OF' THEN 'Outfield'
			WHEN pos IN('SS','1B','2B','3B') THEN 'Infield'
			WHEN pos IN('P','C') THEN 'Battery'
			ELSE null
			END as position
		FROM fielding) as n
WHERE yearid=2016
GROUP BY n.position
ORDER BY total_putouts



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


6.-- Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

--1st step: 
--Create table with playerid, yearid, sb, cs 
--Add narrowing criteria with WHERE statement
--Add calculation for total successful stolen bases and add descending order
--Result is hamilbi02 with 50 successful stolen bases.
--2nd step: link this table as to a table with the people table INNER JOIN (and add the name columns that are needed from the people table)

SELECT b.yearid,b.playerid, p.namefirst as first_name, p.namelast as last_name, sb as stolen_base_attempt, cs as caught_stealing, (sb-cs) as sucessful_stolen_base
FROM batting as b
INNER JOIN people as p
on p.playerid=b.playerid
WHERE b.sb>20 and b.yearid=2016 
GROUP BY b.yearid,b.playerid, first_name,last_name, stolen_base_attempt, caught_stealing 
ORDER BY sucessful_stolen_base DESC



7.-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 

--Seriespost table contains playoff level or Teams table-Teams table contains the team name, so will use Teams table
--Other relevant columns: yearid, teamid
select yearid, teamid, w as wins, l as losses, wswin as world_series
from teams
WHERE yearid BETWEEN '1970' and '2016' 
AND wswin='N' or wswin IS NOT NULL 
WHERE 

	--Other relevant columns: yearid, TeamIDwinner, TeamIDloser, wins, losses
--I'm going to guess that WS means world series

--Step 1: Query from series post table with relevant columns, with narrowing criteria (years, exclusion of WS) via WHERE function 
--Step 2: 
--SELECT  yearid, TeamIDwinner, TeamIDloser, wins, losses
--FROM seriespost
--WHERE round NOT like 'WS' and yearID >=1970 and yearid<=2016



--What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 

--Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?



--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

--12. In this question, you will explore the connection between number of wins and attendance.

	--Does there appear to be any correlation between attendance at home games and number of wins?
	--Do teams that win the world series see a boost in attendance the following year? 
	--What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
	--It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. 
	--First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 	--Are left-handed pitchers more likely to win the Cy Young Award? 
	--Are they more likely to make it into the hall of fame?