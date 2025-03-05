DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify_1 (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);





SELECT * FROM public.spotify_1
LIMIT 100
LIMIT 100



SELECT COUNT(*) FROM spotify_1;

SELECT COUNT(DISTINCT artist) FROM spotify_1;

SELECT DISTINCT album_type FROM spotify_1;

SELECT DISTINCT duration_min FROM spotify_1; 

SELECT AVG(duration_min) FROM spotify_1; 

SELECT MAX(duration_min) FROM spotify_1; 

SELECT MIN(duration_min) FROM spotify_1;

SELECT * from spotify_1
WHERE duration_min=0;

DELETE from spotify_1
WHERE duration_min=0;

SELECT COUNT(*) from spotify_1
WHERE duration_min=0;

SELECT DISTINCT channel FROM spotify_1;

SELECT COUNT(DISTINCT channel) FROM spotify_1;

SELECT DISTINCT most_played_on FROM spotify_1;

SELECT COUNT(DISTINCT most_played_on) FROM spotify_1;

--
--
-- DATA ANAYSIS
--
--

-- Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify_1
WHERE stream > 1000000000;

SELECT COUNT(DISTINCT stream) FROM spotify_1
WHERE stream > 1000000000;


--List all albums along with their respective artists.
SELECT album, artist FROM spotify_1;


--Get the total number of comments for tracks where licensed = TRUE.
SELECT * FROM spotify_1;
SELECT COUNT(DISTINCT comments) FROM spotify_1
WHERE licensed = true;

SELECT SUM(comments) as total_comments FROM spotify_1
WHERE licensed = 'true';


--Find all tracks that belong to the album type single
SELECT * FROM spotify_1;

SELECT * from spotify_1
WHERE album_type='single';

SELECT COUNT(DISTINCT track) from spotify_1
WHERE album_type='single';


--Count the total number of tracks by each artist.
SELECT artist, COUNT(*) as total_no_songs FROM spotify_1
GROUP BY artist;



--Calculate the average danceability of tracks in each album.
SELECT * FROM spotify_1;
SELECT album, AVG(danceability) as total_avg_tracks from spotify_1
GROUP BY 1

--Find the top 5 tracks with the highest energy values.
SELECT * from spotify_1;
SELECT track, MAX(energy) from spotify_1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--List all tracks along with their views and likes where official_video = TRUE.
SELECT track, SUM(views) as total_views, SUM(likes) as total_likes 
FROM spotify_1
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC


--For each album, calculate the total views of all associated tracks.
SELECT album, track, SUM(views) FROM spotify_1
GROUP BY 1, 2
ORDER BY 3 DESC


--Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * from spotify_1;
SELECT COUNT(DISTINCT most_played_on) from spotify_1
GROUP BY 2;

SELECT * FROM
(SELECT track,
COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_youtube,
COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_spotify
FROM spotify_1
GROUP BY 1
) as t1
where 
	streamed_spotify > streamed_youtube
	AND
	streamed_youtube <> 0


--Find the top 3 most-viewed tracks for each artist using window functions.
/*-- solution : each artist and total view for each track
--track with highest view for each artist (we need top)
--dense rank
--cte and filder rank <=3
*/

SELECT * FROM spotify_1;

WITH ranking_artist
AS
(SELECT artist, track, SUM(views) as total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC)
	as rank
FROM spotify_1
GROUP BY 1, 2
ORDER BY 1, 3 DESC
) SELECT * from ranking_artist
where rank <= 3



--Write a query to find tracks where the liveness score is above the average.
SELECT * FROM spotify_1;

SELECT * FROM spotify_1
where liveness > (SELECT AVG(liveness) FROM spotify_1);

SELECT track, artist, liveness FROM spotify_1
where liveness > (SELECT AVG(liveness) FROM spotify_1);


--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
SELECT * FROM spotify_1;

WITH cte
AS
(SELECT album, MAX(energy) as highest_energy, 
	MIN(energy) as lowest_energy 
FROM spotify_1
GROUP BY 1
) SELECT album, highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC

 
--Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT * from spotify_1;

SELECT track, energy/liveness as ene_liv from spotify_1
WHERE (energy/liveness) > 1.2
ORDER BY 2 ASC



--Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.


