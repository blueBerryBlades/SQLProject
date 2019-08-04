-- **************************************************************************************
-- Database Views Creation Script
-- **************************************************************************************


USE theatre;

GO

-- **************************************************************************************
-- This view selects the cinema ID number, cinema name, seating capacity and the name of the cinema type for all cinemas.

CREATE VIEW cinemaView
	AS SELECT cinemaID, cinemaName, capacity, cinemaTypeName
	FROM cinema INNER JOIN cinemaType
	ON cinema.cinemaTypeID = cinemaType.cinemaTypeID

GO

SELECT * FROM cinemaView


-- **************************************************************************************
/*  This view selects the following details of all rows in the session table:
	The session ID number, session date/time and cost of the session.
	The movie ID number, movie name and classification of the movie (e.g. 'PG') being shown.
    The cinema ID number, cinema name, seating capacity and cinema type name of the cinema that the session is in.
*/

GO

CREATE VIEW sessionView
	AS SELECT sessionID, dateAndTime, cost, movie.movieID, movieName, classification, session.cinemaID, cinemaName, capacity, cinemaTypeName
	FROM session INNER JOIN movie 
	ON session.movieID = movie.movieID
	INNER JOIN cinema 
	ON session.cinemaID = cinema.cinemaID
	INNER JOIN cinemaType
	ON cinema.cinemaTypeID = cinemaType.cinemaTypeID
	
GO

SELECT * FROM sessionView