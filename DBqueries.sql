-- **************************************************************************************
-- Database Queries Script
-- **************************************************************************************


USE theatre;

GO


-- **************************************************************************************
-- Query 1: Child friendly movies

SELECT movieName, durationMinutes, classification 
FROM movie
WHERE durationMinutes < 100 AND classification = 'G' OR classification = 'PG'
ORDER BY durationMinutes ASC


-- **************************************************************************************
-- Query 2: Movie Search

SELECT movieName, dateAndTime, cost, cinemaTypeName
FROM sessionView 
WHERE movieName LIKE '%star wars%' AND dateAndTime > getdate()
ORDER BY dateAndTime


-- **************************************************************************************
-- Query 3: Review Details

SELECT text, dateAndTime, rating, firstName, YEAR(GETDATE())-YEAR(DOB) AS 'age'
FROM review AS r INNER JOIN customer AS c
ON r.customerEmail = c.customerEmail
WHERE movieID = 5
ORDER BY dateAndTime DESC


-- **************************************************************************************
--Query 4: Genre Count

SELECT genreName, COUNT(movieName) AS numMovies
FROM genre AS g LEFT OUTER JOIN movieGenre AS mg
ON g.genreID = mg.genreID
LEFT OUTER JOIN movie AS m
ON mg.movieID = m.movieID
GROUP BY g.genreID, genreName


-- **************************************************************************************
-- Query 5: Movie Review Stats


-- The rating is first cast as a float and then an average is taken. Then the average is rounded to 1 decimal place.  

SELECT movieName, COUNT(rating) AS numReviews, ROUND(AVG(CAST(rating AS FLOAT)),1) AS avgRating
FROM movie AS m LEFT OUTER JOIN review AS r
ON m.movieID = r.movieID
GROUP BY m.movieID, movieName
ORDER BY avgRating DESC


-- This alternative query does the same as above but then casts the result as a decimal to ensure all results have one decimal place.

SELECT movieName, COUNT(rating) AS numReviews, CAST(ROUND(AVG(CAST(rating AS FLOAT)),1) AS DECIMAL(2,1)) AS avgRating
FROM movie AS m LEFT OUTER JOIN review AS r
ON m.movieID = r.movieID
GROUP BY m.movieID, movieName
ORDER BY avgRating DESC


-- **************************************************************************************
-- Query 6: Top Selling Movies 

SELECT TOP(3) movieName, COUNT(ticketID) AS ticketsSold
FROM sessionView AS sv INNER JOIN tickets AS t
ON sv.sessionID = t.sessionID 
GROUP BY sv.movieID, sv.movieName
ORDER BY ticketsSold DESC;


-- **************************************************************************************
-- Query 7: Customer Ticket Sales

SELECT CONCAT(firstName,' ', lastName) AS fullName, COUNT(ticketID) AS numTickets, SUM(cost) AS totalSpent
FROM customer AS c LEFT OUTER JOIN tickets AS t
ON c.customerEmail = t.customerEmail
LEFT OUTER JOIN session AS s
ON s.sessionID = t.sessionID
GROUP BY c.customerEmail, firstName, lastName
ORDER BY totalSpent DESC


-- **************************************************************************************
-- Query 8: Age Appropriate Movies


-- Two versions of this query have been included here. One using a subquery and one that uses a variable. 

-- Using subquery:

SELECT movieName, durationMinutes, description
FROM movie AS m INNER JOIN classification AS c
ON m.classification = c.classificationID
WHERE c.MinimumAge <= (SELECT YEAR(GETDATE())-YEAR(DOB)
	FROM customer 
	WHERE customer.customerEmail = 'Ludmila.Limonov@mail.com')


-- Using variable:

DECLARE @age INT
SET @age = (SELECT YEAR(GETDATE())-YEAR(DOB)
	FROM customer 
	WHERE customer.customerEmail = 'Ludmila.Limonov@mail.com')

SELECT movieName, durationMinutes, description
	FROM movie AS m INNER JOIN classification AS c
	ON m.classification = c.classificationID
	WHERE c.MinimumAge <= @age


-- **************************************************************************************
-- Query 9: Session Revenue

SELECT sv.sessionID, dateAndTime, movieName, cinemaName, COUNT(ticketID) AS ticketsSold, cost*COUNT(ticketID) AS totalRevenue
FROM sessionView AS sv LEFT OUTER JOIN tickets AS t
ON sv.sessionID = t.sessionID
WHERE dateAndTime < GETDATE() -- Retrieves details on
GROUP BY sv.sessionID, dateAndTime, movieName, cinemaName, cost
ORDER BY totalRevenue DESC