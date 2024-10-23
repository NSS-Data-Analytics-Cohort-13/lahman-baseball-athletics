--1.What range of years for baseball games played does the provided database cover?
SELECT min(yearid),max(yearid)
FROM teams
--Answer: 1871-2016

--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT p.playerid
, p.namegiven
, p.namefirst, p.namelast
, min(p.height) as height
, a.g_all
, a.teamid
,t_f.franchname
,a.yearid
, p.debut
,p.finalgame
FROM people as p
INNER JOIN appearances as a
	USING (playerid)
INNER JOIN teams
	USING(teamid)
FULL JOIN teamsfranchises as t_f
	USING (franchid)
WHERE namegiven LIKE 'Edward Carl'
GROUP BY p.playerid, p.namegiven, p.namefirst, p.namelast, a.G_all, a.teamid,t_f.franchname,a.yearid
ORDER BY height 

SELECT p.namefirst
, p.namelast
, p.namegiven
, p.height
, a.g_all
, t.name
FROM people as p
INNER JOIN appearances as a
	USING(playerid)
INNER JOIN teams as t
	USING (teamid)
WHERE height=(SELECT MIN(height) FROM people)
LIMIT 1

--ANSWER: Eddie Gaedel who played just one game with the St. Louis Browns who became later into the Orioles Boltimore.

--3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT p.namefirst,p.namelast, CAST(SUM(s.salary)AS numeric)::MONEY as salary
FROM people as p
INNER JOIN collegeplaying
	USING (playerid)
INNER JOIN schools as sch
	USING (schoolid)
INNER JOIN salaries as s
	USING (playerid)
WHERE schoolname LIKE 'Vanderbilt University'
GROUP BY p.namefirst,p.namelast
ORDER BY SUM(s.salary) DESC
--ANSWER: David Price

--4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?