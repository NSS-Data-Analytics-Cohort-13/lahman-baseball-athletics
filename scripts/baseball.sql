
--Question 1: What range of years for baseball games played does the provided database cover?

SELECT 	MIN(yearid)
	, 	MAX(yearid)
FROM teams

--Answer: 145 years.

--Question 2: Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT  p.namefirst
	, 	p.namelast
	, 	MIN(p.height) AS height
	, 	a.G_all AS Total_Games
	, 	t.name
	, 	a.yearid
FROM people AS p
LEFT JOIN appearances AS a
	USING (playerid)
LEFT JOIN teams AS t
	USING (teamid)
WHERE height = (
				 SELECT MIN(height) 
				 FROM people)
GROUP BY  namefirst, namelast, a.G_all, t.name, a.yearid
ORDER BY height



--Answer: Eddie Gaedal was 43 inches tall. He played in 1 game for the Baltimore Orioles in 1951.

--Question 3: Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?



SELECT	CONCAT(pep.namefirst,' ',pep.namelast) AS name
	,	SUM(sal.salary)::INT::MONEY AS salary
FROM people AS pep
INNER JOIN salaries AS sal
	USING(playerid)
INNER JOIN (SELECT distinct(collegeplaying.schoolid)
	,	playerid
			FROM collegeplaying
				INNER JOIN schools
					USING (schoolid)
			) AS school
	USING (playerid)
WHERE school.schoolid = 'vandy'
GROUP BY name
ORDER BY salary DESC

--Answer: David Price earned the most out of all Vanderbilt Alumni.

--Question 4: Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT 
		CASE 	WHEN pos = 'OF' THEN 'Outfield'
				WHEN pos = 'SS' OR
					 pos = '1B' OR
					 pos = '2B' OR
					 pos = '3B' THEN 'Infield'
				WHEN pos = 'P'  OR
					 pos = 'C'  THEN 'Battery'
				ELSE null
				END AS position
		, 	SUM(po) AS putouts 
FROM fielding
WHERE yearid = '2016'
GROUP BY position

--Answer: Battery made 41,424 putouts, Infield made 58,934 putouts, and Outfield made 29,560 putouts.

--Question 5: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?


SELECT 	ROUND((AVG(hr)/AVG(g)), 2) AS hr
	, 	ROUND((AVG(so)/AVG(g)), 2) AS so
	,	ROUND((yearid/10)*10) AS decade
FROM teams
WHERE yearid >1919
GROUP BY decade
ORDER BY decade

SELECT SUM(hr)

--Answer: On average, the HRs and SOs seem to be trending up over time, with strikeouts increasing more consistently.

--Question 6: Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

WITH steals AS(SELECT DISTINCT CONCAT(p.namefirst,' ', p.namelast) AS name
					, ((b.sb+b.cs)+(bp.sb+bp.cs)) AS stolen_base_attempt
					, (b.sb+bp.sb) AS stolen_bases
					, (b.cs+bp.cs) AS caught
		FROM (SELECT *
				FROM batting AS b
			INNER JOIN battingpost AS bp
				USING (playerid))
			INNER JOIN people AS p
				USING (playerid)
		WHERE 	b.yearid = 2016
			AND ((b.sb+b.cs)+(bp.sb+bp.cs)) > 19
		ORDER BY stolen_bases DESC
		)

SELECT 	steals.name
	,	(steals.stolen_bases/steals.stolen_base_attempt)*100 AS success_perc
FROM  steals
ORDER BY success_perc DESC