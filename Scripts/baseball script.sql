--q1 What range of years for baseball games played does the provided database cover?
SELECT MIN (yearid), MAX (yearid)
FROM teams
--answer: 1871-2016

--q2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT DISTINCT p.namefirst, p.namelast, p.namegiven, p.height, a.g_all, t.name
FROM people AS p
INNER JOIN appearances AS a
USING (playerid)
INNER JOIN teams AS t
USING (teamid)
WHERE height = (SELECT MIN (height) FROM people)

--q3 Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT vandy.namefirst, vandy.namelast, vandy.namegiven, SUM (vandy.salary) AS total_salary
FROM (
	SELECT DISTINCT p.namefirst, p.namelast, p.namegiven, sal.teamid, sal.yearid, sal.salary
	FROM collegeplaying AS c
	INNER JOIN schools AS sch
	USING (schoolid)
	INNER JOIN people AS p
	USING (playerid)
	INNER JOIN salaries AS sal
	USING (playerid)
	WHERE schoolname ILIKE 'Vanderbilt University'
	) AS vandy
GROUP BY vandy.namefirst, vandy.namelast, vandy.namegiven
ORDER BY total_salary DESC

-- SELECT DISTINCT p.namefirst, p.namelast, p.namegiven, SUM (sal.salary) AS total_salary
-- FROM collegeplaying AS c
-- INNER JOIN schools AS sch
-- USING (schoolid)
-- INNER JOIN people AS p
-- USING (playerid)
-- INNER JOIN salaries AS sal
-- USING (playerid)
-- WHERE schoolname ILIKE 'Vanderbilt University'
-- GROUP BY p.namefirst, p.namelast, p.namegiven
-- ORDER BY total_salary DESC

--q4 Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT position, SUM (po) AS sum_putouts
FROM (SELECT playerid, po, yearid,
		CASE WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			WHEN pos IN ('P', 'C') THEN 'Battery'
			END AS position
FROM fielding) AS players
WHERE yearid = 2016
GROUP BY position

--q5 Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT FLOOR (yearid/10 *10) AS decade, ROUND(AVG(so/g), 2) AS strikeouts, ROUND(AVG(hr/g), 2) AS homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade

-- SELECT dec.decade, SUM(dec.homeruns) AS avg_homerums, SUM (dec.strikeouts) AS avg_strikeouts
-- FROM (SELECT FLOOR (yearid/10 *10) AS decade, ROUND(AVG(hr/g), 2) AS homeruns, ROUND(AVG(so/g), 2) AS strikeouts
-- FROM batting
-- WHERE yearid >= 1920
-- GROUP BY decade

-- UNION

-- SELECT FLOOR (yearid/10 *10) AS decade, ROUND(AVG(hr/g), 2) AS homeruns, ROUND(AVG(so/g), 2) AS strikeouts
-- FROM pitching
-- WHERE yearid >= 1920
-- GROUP BY decade

-- UNION 

-- SELECT FLOOR (yearid/10 *10) AS decade, ROUND(AVG(hr/g), 2) AS homeruns, ROUND(AVG(so/g), 2) AS strikeouts
-- FROM battingpost
-- WHERE yearid >= 1920
-- GROUP BY decade

-- UNION

-- SELECT FLOOR (yearid/10 *10) AS decade, ROUND(AVG(hr/g), 2) AS homeruns, ROUND(AVG(so/g), 2) AS strikeouts
-- FROM pitchingpost
-- WHERE yearid >= 1920
-- GROUP BY decade) AS dec
-- GROUP BY dec.decade

--q6 Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
SELECT p.namefirst, p.namelast, p.namegiven, sb, cs, sb * 100 / (sb + cs) AS pct_successful_steals
FROM batting
INNER JOIN people AS p
USING (playerid)
WHERE (sb + cs) >= 20 AND yearid = 2016
ORDER BY pct_successful_steals DESC

--q7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT teamid, yearid, g, MAX (w) AS largest_wins
FROM teams
WHERE wswin = 'N'
	AND yearid BETWEEN 1970 AND 2016
GROUP BY teamid, yearid, g
ORDER BY largest_wins DESC

SELECT teamid, yearid, g, MIN (w) AS smallest_wins
FROM teams
WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
GROUP BY teamid, yearid, g
ORDER BY smallest_wins DESC

--The 1981 strike resulted in regular season games being cancelled. 

SELECT teamid, yearid, g, MIN (w) AS smallest_wins
FROM teams
WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
GROUP BY teamid, yearid, g
ORDER BY smallest_wins DESC

WITH winners AS (SELECT yearid, wswin, MAX (w) AS largest_wins 
					FROM teams 
					WHERE wswin = 'Y' 
					AND yearid BETWEEN 1970 AND 2016
					AND yearid <> 1981
					GROUP BY yearid, wswin)
,
losers AS (SELECT yearid, MAX (w) AS largest_wins 
					FROM teams 
					WHERE wswin = 'N'
					AND yearid BETWEEN 1970 AND 2016
					AND yearid <> 1981
					GROUP BY yearid
					ORDER BY yearid)
,
allw AS (SELECT w.largest_wins AS winlarge, l.largest_wins AS loselarge, yearid
		FROM winners AS w
		INNER JOIN losers AS l
		USING (yearid))
, 
pct AS (SELECT SUM (CASE WHEN allw.winlarge >= allw.loselarge THEN 1 
					ELSE 0
					END) AS total_wins,
				COUNT (yearid) AS cnt_year
		FROM allw)

SELECT ROUND((total_wins::numeric/cnt_year::numeric), 2) * 100 AS pct_time
FROM pct
		
--q8 Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT name, park, attendance/ghome AS avg_attendance
FROM teams AS t
WHERE yearid = '2016'
AND ghome >= 10
ORDER BY avg_attendance DESC
LIMIT 5

SELECT name, park, attendance/ghome AS avg_attendance
FROM teams AS t
WHERE yearid = '2016'
AND ghome >= 10
ORDER BY avg_attendance
LIMIT 5

--q9 Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT playerid, tsnwinners.lgid, tsnwinners.yearid, m.teamid, t.name, p.namefirst, p.namelast
FROM 			(SELECT playerid, lgid, yearid
				FROM awardsmanagers
				WHERE awardid = 'TSN Manager of the Year'
				AND playerid IN (SELECT playerid
								FROM awardsmanagers
								WHERE awardid = 'TSN Manager of the Year'
								AND lgid = 'NL'
		
						INTERSECT
			
						SELECT playerid
						FROM awardsmanagers
						WHERE awardid = 'TSN Manager of the Year'
						AND lgid = 'AL')) AS tsnwinners
INNER JOIN managers AS m  --to get team id
USING (playerid)
INNER JOIN teams AS t --to get team name
USING (teamid)
INNER JOIN people AS p --to get full name
USING (playerid)
WHERE m.yearid = tsnwinners.yearid
	AND m.yearid = t.yearid
ORDER BY playerid

--q10 Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
SELECT DISTINCT p.namefirst, p.namelast, players.max_hr
FROM (WITH ten_years AS (SELECT playerid
						FROM batting
						GROUP BY playerid
						HAVING COUNT (DISTINCT yearid) >= 10)
	,
	highest_hr AS (SELECT DISTINCT playerid, MAX (hr) AS max_hr
			FROM batting
			GROUP BY playerid
			ORDER BY playerid)
	
	SELECT playerid, max_hr
	FROM ten_years
	INNER JOIN highest_hr
	USING (playerid)) AS players

INNER JOIN batting AS b
ON players.playerid=b.playerid AND players.max_hr=b.hr
INNER JOIN people AS p
ON b.playerid=p.playerid
WHERE yearid = 2016
	AND max_hr > 0
ORDER BY max_hr DESC


SELECT playerid, yearid, hr
FROM batting
WHERE playerid = 