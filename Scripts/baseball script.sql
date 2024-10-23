--q1 What range of years for baseball games played does the provided database cover?
SELECT MIN (yearid), MAX (yearid)
FROM teams
--answer: 1871-2016

--q2 Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT p.namefirst, p.namelast, p.namegiven, p.height, a.g_all, t.name
FROM people AS p
INNER JOIN appearances AS a
USING (playerid)
INNER JOIN teams AS t
USING (teamid)
WHERE height = (SELECT MIN (height) FROM people)
LIMIT 1

--q3 Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT DISTINCT p.namefirst, p.namelast, p.namegiven, SUM (sal.salary) AS total_salary
FROM collegeplaying AS c
INNER JOIN schools AS sch
USING (schoolid)
INNER JOIN people AS p
USING (playerid)
INNER JOIN salaries AS sal
USING (playerid)
WHERE schoolname ILIKE 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast, p.namegiven
ORDER BY total_salary DESC

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

--q4 Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT CASE WHEN (SELECT pos FROM fielding) IN ('OF') THEN 'outfield'
			WHEN (SELECT pos FROM fielding) IN ('SS', '1B', '2B', '3B') THEN 'infield'
			WHEN (SELECT pos FROM fielding) IN ('P', 'C') THEN 'battery'
			END
FROM fielding

SELECT *
FROM fielding