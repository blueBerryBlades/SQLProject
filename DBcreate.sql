
--  **************************************************************************************
--	Database Creation & Population Script 
--  **************************************************************************************

/* To ensure this creation script can be run multiple times without errors this first step was adapted from the company example in Module 5. 

Adapted from Module 5:
We first check if the database exists, and drop it if it does.
Setting the active database to the built in 'master' database ensures that we are not trying to drop the currently active database.
Setting the database to 'single user' mode ensures that any other scripts currently using the database will be disconnectetd.
This allows the database to be deleted, instead of giving a 'database in use' error when trying to delete it.
*/


IF DB_ID('theatre') IS NOT NULL             
	BEGIN
		PRINT 'Database exists - dropping.';
		USE master;		
		ALTER DATABASE theatre SET SINGLE_USER WITH ROLLBACK IMMEDIATE;		
		DROP DATABASE theatre;
	END
GO

--  Now that we are sure the database does not exist, we create it.

PRINT 'Creating database.';
CREATE DATABASE theatre;
GO

--  Now that an empty database has been created, we will make it the active one.
--  The table creation statements that follow will therefore be executed on the newly created database.

USE theatre;
GO

-- End of script adapted from Module 5. 

-- **************************************************************************************
--  We now create the tables in the database.
-- **************************************************************************************


-- **************************************************************************************
-- Create classification table to hold details of different classifications. 
-- Movie table has a foreign key referencing this table.


PRINT 'Creating classification table…';

CREATE TABLE classification (
	classificationID CHAR(2) NOT NULL,
	classificationName VARCHAR(25) NOT NULL,
	MinimumAge TINYINT NOT NULL DEFAULT 0,
	CONSTRAINT classPK PRIMARY KEY (classificationID)
);


-- **************************************************************************************
-- Create genre table to hold information about different genres. 
-- MovieGenre table has a foreign key referencing this table.

PRINT 'Creating genre table…';

CREATE TABLE genre (
	genreID TINYINT NOT NULL IDENTITY,
	genreName VARCHAR(25) NOT NULL,
	CONSTRAINT genrePK PRIMARY KEY (genreID)
);


-- **************************************************************************************
-- Create movie table to hold the details of each movie. 
-- MovieGenre table has a foreign key referencing this table.

PRINT 'Creating movie table…;'
CREATE TABLE movie (
	movieID SMALLINT NOT NULL IDENTITY,
	classification CHAR(2) NOT NULL,
	movieName VARCHAR(75) NOT NULL,
	durationMinutes TINYINT NOT NULL,
	description VARCHAR(2000) NOT NULL,
	CONSTRAINT moviePK PRIMARY KEY (movieID),
	CONSTRAINT classificationFK FOREIGN KEY (classification) REFERENCES classification(classificationID)
);


-- **************************************************************************************
-- Create movieGenre table. 
-- This table resolves a M:M relationship between the movie and genre tables. 

PRINT 'Creating movieGenre table…;'

CREATE TABLE movieGenre (
	movieGenreID INT NOT NULL IDENTITY,
	movieID SMALLINT NOT NULL,
	genreID TINYINT NOT NULL,
	CONSTRAINT movieGenrePK PRIMARY KEY (movieGenreID),
	CONSTRAINT movieIDFK FOREIGN KEY (movieID) REFERENCES movie(movieID),
	CONSTRAINT genreIDFK FOREIGN KEY (genreID) REFERENCES genre(genreID),
);

ALTER TABLE movieGenre 
	ADD CONSTRAINT combUnique UNIQUE (
	 movieID,
	 genreID
);


-- **************************************************************************************
-- Create cinemaType table to hold the details of different types of cinemas in the theatre. 
-- Cinema table has a foreign key referencing this table.

PRINT 'Creating cinemaType table…;'

CREATE TABLE cinemaType (
	cinemaTypeID TINYINT NOT NULL IDENTITY,
	cinemaTypeName VARCHAR(25) NOT NULL,
	CONSTRAINT cinemaTypePK PRIMARY KEY (cinemaTypeID)
);


-- **************************************************************************************
-- Create cinema table. This table holds the details of each individual cinema.

PRINT 'Creating cinema table…;'

CREATE TABLE cinema (
	cinemaID TINYINT NOT NULL IDENTITY,
	cinemaTypeID TINYINT NOT NULL,
	cinemaName VARCHAR(25) NOT NULL,
	capacity TINYINT NOT NULL,
	CONSTRAINT cinemaPK PRIMARY KEY (cinemaID),
	CONSTRAINT cinemaTypeIDFK FOREIGN KEY (cinemaTypeID) REFERENCES cinemaType(cinemaTypeID)
);


-- **************************************************************************************
-- Create customer table to store the details of each customer. 
-- Tickets and review tables have foreign keys that referene this table. 

PRINT 'Creating customer table…;'

CREATE TABLE customer (
	customerEmail VARCHAR(320) NOT NULL,
	password VARCHAR(25) NOT NULL,
	firstName VARCHAR(25) NOT NULL,
	lastName VARCHAR(25) NOT NULL,
	DOB DATE NOT NULL,
	CONSTRAINT customerPK PRIMARY KEY (customerEmail)
);


-- **************************************************************************************
-- Create session table to hold the details of each session. 
-- Tickets table has a foreign key referencing this table.

PRINT 'Creating session table…;'

CREATE TABLE session (
	sessionID INT NOT NULL IDENTITY,
	cinemaID TINYINT NOT NULL,
	movieID SMALLINT NOT NULL,
	dateAndTime SMALLDATETIME NOT NULL,
	cost SMALLMONEY NOT NULL,
	CONSTRAINT sessionPK PRIMARY KEY (sessionID),
	CONSTRAINT cinemaIDFK FOREIGN KEY (cinemaID) REFERENCES cinema(cinemaID),
	CONSTRAINT sessionMovieIDFK FOREIGN KEY (movieID) REFERENCES movie(movieID)
);


-- **************************************************************************************
-- Create tickets table. This table holds details of tickets that customers have purchased.  

PRINT 'Creating tickets table…;'

CREATE TABLE tickets (
	ticketID INT NOT NULL IDENTITY,
	customerEmail VARCHAR(320) NOT NULL,
	sessionID INT NOT NULL,
	CONSTRAINT ticketsPK PRIMARY KEY (ticketID),
	CONSTRAINT customerEmailFK FOREIGN KEY (customerEmail)REFERENCES customer(customerEmail),
	CONSTRAINT sessionIDFK FOREIGN KEY (sessionID) REFERENCES session(sessionID)
);


-- **************************************************************************************
-- Create review table. This table holds the details of reviews that customers have left for particular movies. 

PRINT 'Creating review table…;'

CREATE TABLE review (
	reviewID SMALLINT NOT NULL IDENTITY,
	customerEmail VARCHAR(320) NOT NULL,
	movieID SMALLINT NOT NULL,
	dateAndTime SMALLDATETIME NOT NULL DEFAULT GETDATE(),
	text VARCHAR(2000) NOT NULL,
	rating TINYINT NOT NULL,
	CONSTRAINT reviewPK PRIMARY KEY (reviewID),
	CONSTRAINT reviewCustomerEmailFK FOREIGN KEY (customerEmail) REFERENCES customer(customerEmail),
	CONSTRAINT reviewMovieIDFK FOREIGN KEY (movieID) REFERENCES movie(movieID),
	CONSTRAINT ratingCheck CHECK (rating >= 0 AND rating <= 5)
);

ALTER TABLE review
	ADD CONSTRAINT reviewCombUnique 
		UNIQUE (
		customerEmail, 
		movieID
		);


-- **************************************************************************************
--	Database Population Statements
-- **************************************************************************************


-- **************************************************************************************	
/*	The following statement inserts the details of 5 classifications into a table named "classification".
    It specifies values for 3 columns - the classification's abbreviation, name and minimum age restriction (where appropriate).	
*/

PRINT 'Populating classification table...;'

INSERT INTO classification
VALUES ('G',  'General', 0),
       ('PG', 'Parental Guidance', 0),
       ('M',  'Mature', 0),
       ('MA', 'Mature Audiences', 15),
       ('R',  'Restricted', 18);


-- **************************************************************************************
/*	The following statement inserts the details of 10 genres into a table named "genre". 
    It specifies values for 1 column:  The genre name.
	Genre ID numbers are not specified since an auto-incrementing integer is being used as the primary key for this table.	
*/
PRINT 'Populating genre table...;'

INSERT INTO genre
VALUES ('Action'),     -- Genre 1
       ('Adventure'),  -- Genre 2
       ('Animation'),  -- Genre 3
       ('Comedy'),     -- Genre 4
       ('Crime'),      -- Genre 5
       ('Drama'),      -- Genre 6
       ('Fantasy'),    -- Genre 7
       ('Horror'),     -- Genre 8
       ('Romance'),    -- Genre 9
       ('Sci-Fi');     -- Genre 10


-- **************************************************************************************
/*	The following statement inserts the details of 10 movies into a table named "movie". 
    It specifies values for 4 columns:  The movie name, its duration in minutes, a description of the movie, and its classification.
	Movie ID numbers are not specified an auto-incrementing integer is being used as the primary key for this table.
	The data in this table was retrieved from IMDB (http://www.imdb.com/).
*/

PRINT 'Populating movie table...;'

INSERT INTO movie

VALUES ('MA', 'The Shawshank Redemption', 142, 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.'),
       ('R', 'Pulp Fiction', 154, 'The lives of two mob hit men, a boxer, a gangster''s wife, and a pair of diner bandits intertwine in four tales of violence and redemption.'),
       ('M', 'Forrest Gump', 142, 'Forrest Gump, while not intelligent, has accidentally been present at many historic moments, but his true love, Jenny Curran, eludes him.'),
       ('PG', 'Star Wars: Episode IV - A New Hope', 121, 'Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a wookiee and two droids to save the universe from the Empire''s world-destroying battle-station.'),
       ('G', 'WALL-E', 98, 'In the distant future, a small waste collecting robot inadvertently embarks on a space journey that will ultimately decide the fate of mankind.'),
       ('M', 'Eternal Sunshine of the Spotless Mind', 108, 'When their relationship turns sour, a couple undergoes a procedure to have each other erased from their memories. But it is only through the process of loss that they discover what they had to begin with.'),
       ('PG', 'Monty Python and the Holy Grail', 91, 'King Arthur and his knights embark on a low-budget search for the Grail, encountering many very silly obstacles.'),
       ('PG', 'Up', 96, 'Seventy-eight year old Carl Fredricksen travels to Paradise Falls in his home equipped with balloons, inadvertently taking a young stowaway.'),
       ('M', 'Gran Torino', 116, 'Disgruntled Korean War veteran Walt Kowalski sets out to reform his neighbor, a Hmong teenager who tried to steal Kowalski''s prized possession: a 1972 Gran Torino.'),
       ('PG', 'Metropolis', 153, 'In a futuristic city sharply divided between the working class and the city planners, the son of the city''s mastermind falls in love with a working class prophet who predicts the coming of a savior to mediate their differences.');


-- **************************************************************************************
/*	The following statement inserts the details of which genres apply to which movies into a table named "movie_genre". 
    It specifies values for 2 columns:  A movie ID number, followed by a genre ID number.
    For clarity and conciseness, the values have been grouped by movie.
	
*/

PRINT 'Populating movieGenre table...;'

INSERT INTO movieGenre
VALUES (1, 5), (1, 6),           -- Shawshank: Crime & Drama
       (2, 5), (2, 6),           -- Pulp Fiction: Crime & Drama
       (3, 6), (3, 9),           -- Forrest Gump: Drama & Romance
       (4, 1), (4, 2), (4, 7),   -- Star Wars: Action & Adventure & Fantasy
       (5, 2), (5, 3),           -- Wall-E: Adventure & Animation
       (6, 6), (6, 9), (6, 10),  -- Eternal Sunshine: Drama & Romance & Sci-Fi
       (7, 2), (7, 4), (7, 7),   -- Holy Grail: Adventure & Comedy & Fantasy
       (8, 2), (8, 3),           -- Up: Adventure & Animation
       (9, 6),                   -- Gran Torino: Drama
       (10, 6), (10, 10);        -- Metropolis: Drama & Sci-Fi


-- **************************************************************************************
/* The following statement inserts details of the types of cinemas the theatre has into the 'cinemaType' table. 
It specifies one value, for 'cinemaTypeName'.
Cinema Type ID numbers are not specified as an auto-incrementing integer is being used as the primary key for this table.
*/

PRINT 'Populating cinemaType table...;'

INSERT INTO cinemaType
VALUES	('Standard'),
		('Gold Class'),
		('MegaDeluxe'),
		('Imax');


-- **************************************************************************************
/* The following statement inserts details of the types of the different cinemas in the theatre into the 'cinema' table. 
It specifies values for 3 columns: cinemaType, cinemaName and capacity. 
Cinema ID numbers are not specified as an auto-incrementing integer is being used as the primary key for this table.
*/

PRINT 'Populating cinema table...;'

INSERT INTO cinema
VALUES	(1, 'Cinema One', 240),
		(1, 'Cinema Two', 240),
		(2, 'Cinema Three', 180),
		(2, 'Cinema Four', 160),
		(3, 'Cinema Five', 120),
		(4, 'Imax', 220);


-- **************************************************************************************
/* The following statement inserts the details of registered customers into the 'customer' table. 
It specifies values for 5 columns: customerEmail, password, firstName, lastName and DOB.
The customer's email address is the primary key for this table. 
*/

PRINT 'Populating customer table...;'

INSERT INTO customer
VALUES	('andrea.apples@gmail.com', 'aaaAAA', 'Andrea', 'Apples', '1986-01-01'),
		('bryan.bananas@hotmail.com', 'bbbBBB', 'Bryan', 'Bananas','1987-02-02'),
		('catherine.coconut@outlook.com', 'cccCCC', 'Catherine', 'Coconut', '1989-03-03'),
		('david.dewberry@live.com', 'dddDDD', 'David', 'Dewberry', '1991-04-04'),
		('erica.elderberry@yahoo.com', 'eeeEEE', 'Erica', 'Elderberry', '1995-05-05'),
		('frank.fig@mail.ru', 'fffFFF', 'Frank', 'Fig', '1976-06-06'),
		('grace.grape@protonomail.com', 'gggGGG', 'Grace', 'Grape', '1954-08-08'),
		('herman.heiss@yandex.ru', 'hhhHHH', 'Herman', 'Heiss', '1969-09-09'),
		('Ignacio.Inez@googlemail.com', 'iiiIII', 'Ignacio', 'Inez', '1993-10-10'),
		('Juanita.Jiminez@aol.com', 'jjjJJJ', 'Juanita', 'Jiminez', '2000-11-11'),
		('Kalkin.Kaur@icloud.com', 'kalKAU', 'Kalkin', 'Kaur', '2004-07-07'),
		('Ludmila.Limonov@mail.com', 'lllLLL', 'Ludmila', 'Limonov', '2003-12-12');


-- **************************************************************************************
/* The following statement inserts details of sessions into the 'sessions' tble. 
It specifies values for 4 columns: cinemaID, movieID, dateAndTime and cost. 
Session ID numbers are not specified as an auto-incrementing integer is being used as the primary key for this table.
*/

PRINT 'Populating session table...;'

INSERT INTO session
VALUES	(1, 1, '2018-01-31 12:00:00', 20.00),
		(1, 2, '2018-02-11 19:00:00', 20.00),
		(2, 3, '2018-08-29 21:00:00', 20.00),
		(2, 4, '2018-07-31 18:00:00', 20.00),
		(3, 5, '2018-04-10 17:00:00', 30.00),
		(3, 6, '2018-01-12 11:30:00', 30.00),
		(4, 7, '2018-02-13 18:25:00', 30.00),
		(4, 8, '2018-03-28 20:45:00', 30.00),
		(5, 9, '2018-05-04 18:25:00', 35.00),
		(5, 10, '2018-06-01 19:15:00', 35.00),
		(6, 1, '2018-07-22 11:35:00', 40.00),
		(6, 2, '2018-09-03 21:00:00', 40.00),
		(2, 4, '2018-12-31 18:00:00', 20.00);


-- **************************************************************************************
/* The following statement inserts details of customer purchases into the 'tickets' table. 
It specifies values for 2 columns: customerEmail and sessionID. 
Ticket ID numbers are not specified as an auto-incrementing integer is being used as the primary key for this table.
*/

PRINT 'Populating tickets table...;'

INSERT INTO tickets
VALUES	('andrea.apples@gmail.com', 1),
		('andrea.apples@gmail.com', 1),
		('david.dewberry@live.com', 1),
		('erica.elderberry@yahoo.com', 2),
		('erica.elderberry@yahoo.com', 2),
		('erica.elderberry@yahoo.com', 2),
		('david.dewberry@live.com', 3),
		('andrea.apples@gmail.com', 4),
		('andrea.apples@gmail.com', 4),
		('frank.fig@mail.ru', 5),
		('grace.grape@protonomail.com', 6),
		('grace.grape@protonomail.com', 6),
		('herman.heiss@yandex.ru', 6),
		('herman.heiss@yandex.ru', 6),
		('Juanita.Jiminez@aol.com', 7),
		('andrea.apples@gmail.com', 7),
		('Kalkin.Kaur@icloud.com', 8),
		('Kalkin.Kaur@icloud.com', 8),
		('Ludmila.Limonov@mail.com', 9),
		('Ludmila.Limonov@mail.com', 9),
		('Ludmila.Limonov@mail.com', 9),
		('Ignacio.Inez@googlemail.com', 10),
		('Ignacio.Inez@googlemail.com', 10),
		('catherine.coconut@outlook.com', 11),
		('bryan.bananas@hotmail.com', 12),
		('bryan.bananas@hotmail.com', 12),
		('bryan.bananas@hotmail.com', 12);


-- **************************************************************************************
/* The following statement inserts details of customer's reviews of movies into the 'reviews' table. 
It specifies values for 5 columns: customerEmail, movieID, text and rating. 
Review ID numbers are not specified as an auto-incrementing integer is being used as the primary key for this table.
DateAndTime is not specified as the default GETDATE() value is used. 
*/

PRINT 'Populating review table...;'

INSERT INTO review
VALUES	('andrea.apples@gmail.com', 4, '2018-08-01 00:00:00', 'Ugh! So boring! Do not get the appeal.', 0),
		('bryan.bananas@hotmail.com', 2, '2018-09-04 21:00:00', 'Great movie. In general I think Tarantino is overrated but this movie is cool.', 4),
		('catherine.coconut@outlook.com', 1, '2018-07-26 11:35:00', 'Nice film. Quite corny at times but I can see why it is a classic. Morgan Freeman is always amazing.', 3),
		('david.dewberry@live.com', 3, '2018-08-30 21:00:00', 'Entertaining and all – but what’s the point???', 3),
		('erica.elderberry@yahoo.com', 2, '2018-02-12 19:00:00', 'OMG I like HEART everything Tarantino does coz I’m like really cool like that :P', 5),
		('frank.fig@mail.ru', 5, '2018-04-10 23:00:00',  'The kids loved it!', 4),
		('grace.grape@protonomail.com', 6, '2018-01-12 17:30:00', 'Such an incredible film. Kate Winslet and Jim Carrey are talented performers and the story artfully explores interesting concepts.', 5),
		('herman.heiss@yandex.ru', 6, '2018-01-12 16:30:00', 'What even was that? 1 star because Kate Winslet, but otherwise 0.', 1),
		('Ignacio.Inez@googlemail.com', 10, '2018-06-02 11:15:00',  'My favourite movie of all time. A classic. Everyone should watch it.', 5),
		('Juanita.Jiminez@aol.com', 7, '2018-02-13 23:55:00', 'My friends made me see it. 90 minutes of my life I’ll never get back.', 0),
		('Kalkin.Kaur@icloud.com', 8, '2018-03-29 20:45:00', 'Meh.', 2),
		('Ludmila.Limonov@mail.com', 9, '2018-05-05 18:25:00', 'About what you would expect. I’m not a huge Clint Eastwood fan.', 3);