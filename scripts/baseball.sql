
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

--SELECT SUM(hr)

--Answer: On average, the HRs and SOs seem to be trending up over time, with strikeouts increasing more consistently.

--Question 6: Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

WITH steals AS(SELECT (CONCAT(p.namefirst,' ', p.namelast)) AS name
					, (full_batting.sb+full_batting.cs) AS stolen_base_attempt
					, (full_batting.sb) AS stolen_bases
					, (full_batting.cs) AS caught
					, (full_batting.playerid) AS playerid
		FROM people AS p
			INNER JOIN (SELECT   		SUM (b1.sb) AS sb
								, 		SUM (b1.cs) AS cs
								,		b1.yearid AS yearid
								,		b1.playerid AS playerid
						FROM  battingpost AS b1
						WHERE b1.yearid = 2016
						GROUP BY b1.playerid, b1.yearid
					UNION
						SELECT 	 		SUM (b2.sb) AS sb
								, 		SUM (b2.cs) AS cs
								,		b2.yearid AS yearid
								,		b2.playerid AS playerid
						FROM batting AS b2
						WHERE b2.yearid = 2016
						GROUP BY b2.playerid, b2.yearid) AS full_batting
				USING (playerid)
		WHERE 	full_batting.yearid = 2016
			AND (full_batting.sb+full_batting.cs) > 19
		ORDER BY stolen_bases DESC
		)

/*SELECT sb,cs
FROM batting
WHERE 	playerid ='villajo01'
		AND yearid = 2016

SELECT sb, cs
FROM battingpost
WHERE 	playerid ='villajo01'
		AND yearid = 2016*/

SELECT 	DISTINCT steals.name
	,	steals.stolen_bases
	,	steals.stolen_base_attempt
	,	ROUND((CAST(steals.stolen_bases AS numeric))/(CAST(steals.stolen_base_attempt AS numeric))*100, 2) AS success_rate
FROM  steals
ORDER BY success_rate desc


--Answer : Chris Owings had the most success stealing bases with a success rate of 91.3%.


--Question 7: From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT 	MAX(w) AS wins
	, 	yearid
	, 	wswin
FROM teams
WHERE wswin = 'N'
	AND	yearid > 1969
	AND yearid < 2017
	AND yearid <>1981
GROUP BY yearid, wswin
ORDER BY wins DESC

SELECT	 MIN(w) AS wins
	,	 yearid
FROM teams
WHERE 	wswin = 'Y'
	AND	yearid > 1969
	AND yearid < 2017
	AND yearid <> 1981 --This year was an anomaly due to the MLB Strike.
GROUP BY yearid
ORDER BY wins
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Solving for percentage of time teams had most wins and WS win begins here


WITH wswins AS (SELECT 	MAX(w) AS wins
					, 	yearid
					, 	wswin
					FROM teams
					WHERE wswin = 'Y'
						AND	yearid > 1969
						AND yearid < 2017
						AND yearid <>1981
					GROUP BY yearid, wswin
					ORDER BY yearid DESC),

wslosses AS (SELECT MAX(w) AS wins
					, 	yearid
					, 	wswin
					FROM teams
					WHERE wswin = 'N'
						AND	yearid > 1969
						AND yearid < 2017
						AND yearid <>1981
					GROUP BY yearid, wswin
					ORDER BY yearid DESC),


agg_ws AS (SELECT 	wswins.wins AS wswins
				, 	wslosses.wins AS wslosses
				, 	yearid
				FROM wswins
				INNER JOIN wslosses
					USING (yearid)
					ORDER BY yearid),

wins_with_max AS 
				(SELECT 	SUM(CASE 
					WHEN agg_ws.wswins >= agg_ws.wslosses 
					THEN 1 ELSE 0
					END) AS wins
					,	COUNT(yearid) AS year_count
FROM agg_ws)

SELECT ROUND((wins::numeric/year_count::numeric), 2)*100 AS percent_of_time
FROM wins_with_max


--Answer: From 1970-2016, the largest number of wins for a team that did not win the WS was 116, and the lowest number of wins for a team that did win the WS was 63 wins in 1981. The low number of games played was due to the 1981 MLB Strike. From 1970-2016, the team with the most wins also won the world series ~27% of the time.


--Question 8: Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

WITH TOP_5 AS (SELECT t.park AS Park, t.name AS Team, ROUND(AVG(t.attendance/t.ghome), 2) AS avg_att
FROM teams AS t
WHERE 	yearid = 2016
	AND t.ghome > 9
GROUP BY t.park, t.name
ORDER BY avg_att DESC
LIMIT 5),

BOTTOM_5 AS (SELECT t.park AS Park, t.name AS Team, ROUND(AVG(t.attendance/t.ghome), 2) AS avg_att
FROM teams AS t
WHERE 	yearid = 2016
	AND t.ghome > 9
GROUP BY t.park, t.name
ORDER BY avg_att
LIMIT 5)

SELECT *
FROM TOP_5
UNION ALL
SELECT *
FROM BOTTOM_5



--Answer:
   PARK					TEAM					AVG_ATT
"Dodger Stadium"		"Los Angeles Dodgers"	45719.00
"Busch Stadium III"		"St. Louis Cardinals"	42524.00
"Rogers Centre"			"Toronto Blue Jays"		41877.00
"AT&T Park"				"San Francisco Giants"	41546.00
"Wrigley Field"			"Chicago Cubs"			39906.00
"Tropicana Field"		"Tampa Bay Rays"		15878.00
"O.co Coliseum"			"Oakland Athletics"		18784.00
"Progressive Field"		"Cleveland Indians"		19895.00
"Marlins Park"			"Miami Marlins"			21405.00
"U.S. Cellular Field"	"Chicago White Sox"		21559.00


--Question 9: Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH NL AS (SELECT playerid, awardid, lgid, yearid
FROM awardsmanagers
WHERE awardid iLIKE 'TSN%'
	AND lgid NOT iLIKE 'ML'
	AND lgid iLIKE 'NL'),

AL AS (SELECT playerid, awardid, lgid, yearid
FROM awardsmanagers
WHERE awardid iLIKE 'TSN%'
	AND lgid NOT iLIKE 'ML'
	AND lgid iLIKE 'AL')

SELECT nl.playerid, CONCAT(p.namefirst,' ',p.namelast) AS name, nl.lgid, nl.yearid AS NL_Year, al.playerid, al.lgid, al.yearid AS AL_Year
FROM NL
INNER JOIN AL
	USING (playerid)
INNER JOIN people AS p
	USING (playerid)


--Answer: Jim Leyland won the TSN for each league, winning the NL in '88,'90, and '92 and then the AL in '06. Davey Johnson also won the award in each league, with the AL coming in '97 and the NL coming in '12.


--Question 10: Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


--This code gives the playerids for all players who have played at least 10 years in the league.
WITH ten_yrs AS (SELECT playerid
FROM batting
GROUP BY playerid
HAVING COUNT(DISTINCT yearid) >9),

--This code gives the career high of homeruns per each playerid from ten_yrs table.
HR_High AS (SELECT MAX(hr) AS hrs, ten_yrs.playerid
FROM ten_yrs
INNER JOIN batting
	USING (playerid)
GROUP BY playerid
ORDER BY MAX(hr) desc)


--This code then uses the playerids from the list above to achieve the rest of the question, using the people table to give the full names and HR_high table to pull the homerun numbers.
SELECT h.playerid AS playerid, CONCAT(p.namefirst,' ',p.namelast) AS name, MAX(h.hrs) AS hrs
FROM batting AS b
INNER JOIN people AS p
	USING (playerid)
INNER JOIN hr_high AS h
	ON h.playerid=b.playerid AND h.hrs = b.hr
WHERE b.yearid = 2016
	AND hrs > 0
GROUP BY h.playerid, name
ORDER BY hrs desc


--This code was to show that the CTE was necessary
/*SELECT playerid, CONCAT(p.namefirst,' ',p.namelast) AS name, SUM(b.hr) AS hrs
FROM batting AS b
INNER JOIN people AS p
	USING (playerid)
WHERE b.yearid = 2016
GROUP BY playerid, name
HAVING COUNT(yearid) >9
ORDER BY hrs desc*/


--Answer:
"playerid"			"name"				"hrs"
"encared01"		"Edwin Encarnacion"		42
"canoro01"		"Robinson Cano"			39
"napolmi01"		"Mike Napoli"			34
"uptonju01"		"Justin Upton"			31
"paganan01"		"Angel Pagan"			12
"davisra01"		"Rajai Davis"			12
"wainwad01"		"Adam Wainwright"		2
"liriafr01"		"Francisco Liriano"		1
"colonba01"		"Bartolo Colon"			1

--Question 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

WITH yearly_team_sal AS (SELECT 	SUM(salary) AS team_salary
		,	s.teamid AS teamid
		, 	s.yearid AS yearid
		FROM salaries AS s
		WHERE s.yearid > 1999
		GROUP BY 	s.teamid
				, 	s.yearid
		ORDER BY s.yearid DESC)

SELECT 	CAST(yearly_team_sal.team_salary AS numeric)::MONEY
	, 	t.w
	, 	yearly_team_sal.teamid
	, 	yearly_team_sal.yearid
	FROM teams AS t
		INNER JOIN yearly_team_sal
			ON yearly_team_sal.yearid = t.yearid
				AND yearly_team_sal.teamid = t.teamid
	ORDER BY yearly_team_sal.team_salary

--Answer: It does appear that there is some correlation between salaries and wins, but nothing that is cosistent enough to draw a direct connection between the two data points.

--Question 12: In this question, you will explore the connection between number of wins and attendance.
  -- *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
  -- *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

SELECT attendance, w, yearid
FROM teams
WHERE attendance IS NOT NULL
	AND yearid > 2000
ORDER BY w DESC
