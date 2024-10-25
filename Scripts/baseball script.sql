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
SELECT p.namefirst, p.namelast, p.namegiven, player.pct_successful_steals
FROM ((SELECT playerid, sb, cs, sb * 100 / (sb + cs) AS pct_successful_steals
FROM batting
WHERE (sb + cs) >= 20 AND yearid = 2016)

UNION ALL

(SELECT playerid, sb, cs, sb * 100 / (sb + cs) AS pct_successful_steals
FROM fielding
WHERE (sb + cs) >= 20 AND yearid = 2016)
ORDER BY pct_successful_steals DESC
LIMIT 1) AS player
INNER JOIN people AS p
USING (playerid)

--q7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT *
FROM teams
WHERE wswin = 'N'
	AND yearid BETWEEN 1970 AND 2016 


SELECT *
FROM fieldingpost