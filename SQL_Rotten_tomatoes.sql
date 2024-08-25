USE rt
# Viewing the Dataset
ALTER TABLE movies
CHANGE COLUMN ï»¿movie_title movie_title TEXT;

SELECT * FROM movies;

SELECT COUNT(*) FROM movies;

# 1. Find all the movies with highest tomatometer_rating.
SELECT movie_title, tomatometer_rating FROM movies 
WHERE tomatometer_rating = 100;

WITH CTE AS(SELECT movie_title, tomatometer_rating FROM movies 
WHERE tomatometer_rating = 100) SELECT COUNT(*) AS highest_ratings_movies_count FROM CTE;

# 2. Find top 10 movies which have highest both tomatometer_rating and audience_rating.
SELECT movie_title, tomatometer_rating, audience_rating , 
ROUND((tomatometer_rating+audience_rating)/2,1) AS average_rating
FROM movies 
ORDER BY average_rating DESC LIMIT 10;

# 3. How many movies out of total have tomatometer_rating more than the average_tomatometer_ratings.
with cte as(
SELECT COUNT(*) AS total_movies, ROUND(AVG(tomatometer_rating),2) AS average_ratings,
SUM(CASE 
	WHEN tomatometer_rating > (SELECT AVG(tomatometer_rating) FROM movies) THEN 1 
	ELSE 0 
    END) AS more_than_avg
FROM movies) 
SELECT total_movies, average_ratings,  more_than_avg, 
ROUND((more_than_avg/total_movies)*100,2) AS movies_percentage_more_than_avg 
FROM cte;

# 4. Find the top 10 longest movie  and top 10 shortest movie and compare their 
# tomatometer_ratings as well as audience_rating.
(SELECT movie_title, runtime, tomatometer_rating, audience_rating 
    FROM movies ORDER BY runtime DESC LIMIT 10)
UNION ALL
(SELECT movie_title, runtime, tomatometer_rating, audience_rating 
	FROM movies ORDER BY runtime ASC LIMIT 10);

# 5. Find movies which have highest tomatometer_ratings and where tomatometer_top_critic 
# counts is more than 65.
SELECT movie_title, runtime, tomatometer_rating, audience_rating, tomatometer_top_critics_count
	FROM movies WHERE tomatometer_top_critics_count >65
    ORDER BY tomatometer_rating DESC;
    

# 6. Find the movie for which the difference between original_release_date and streaming_release_date is maximum.
SELECT movie_title, runtime, tomatometer_rating, original_release_date, streaming_release_date,
ABS(timestampdiff(YEAR, streaming_release_date, original_release_date)) AS time_diff 
	FROM movies 
    ORDER BY time_diff  DESC;
    
# 7. Find all the movies made by top three director who have made atleast 10 movies
#  in terms of tomatometer_ratings.
WITH CTE AS(
SELECT lead_director, COUNT(*) as movie_count, ROUND(AVG(tomatometer_rating),2) as avg_rating FROM movies 
GROUP BY lead_director 
HAVING movie_count > 10 ORDER BY AVG(tomatometer_rating) DESC LIMIT 3)
SELECT movie_title, runtime, tomatometer_rating, audience_rating, lead_director
FROM movies WHERE lead_director IN (SELECT lead_director FROM CTE);

# Adding a new colmn
ALTER TABLE movies ADD COLUMN average_rating FLOAT;
UPDATE movies SET average_rating = (tomatometer_rating + audience_rating) / 2;

# 8. Find the best movie of each year in terms of ratings.
WITH ranked_movies AS (
    SELECT movie_title, original_release_date, average_rating, genres,
        YEAR(original_release_date) AS release_year,
        ROW_NUMBER() OVER (PARTITION BY YEAR(original_release_date) ORDER BY average_rating DESC) AS ranking
    FROM movies)
SELECT movie_title,  original_release_date, average_rating , genres
FROM ranked_movies WHERE ranking = 1;

# 9. What are the top 5 actors in terms of audience ratings with at least 10 movies.
SELECT lead_actor, ROUND(AVG(audience_rating),2) AS avg_rating, COUNT(*) AS movie_count
    FROM movies
    GROUP BY lead_actor
    HAVING movie_count >= 10 ORDER BY avg_rating DESC LIMIT 5;

# 10. Find number of movies done by each actor and thier average audience rating.
SELECT lead_actor, COUNT(*) AS movie_count, ROUND(AVG(audience_rating),2) AS avg_rating
FROM movies GROUP BY lead_actor ORDER BY movie_count DESC;

# 11. Find number of movies directed by each director and thier average rating.
SELECT lead_director, COUNT(*) AS movie_count, ROUND(AVG(average_rating),2) AS avg_rating
FROM movies GROUP BY lead_director ORDER BY movie_count DESC;

# 12. Find the month each year with most number of movies.
WITH monthly_movie_counts AS (
    SELECT YEAR(original_release_date) AS release_year, MONTHNAME(original_release_date) AS release_month,
        COUNT(*) AS movie_count
    FROM movies GROUP BY release_year, release_month
), 
ranked_months AS ( SELECT release_year, release_month, movie_count,
        ROW_NUMBER() OVER (PARTITION BY release_year ORDER BY movie_count DESC) AS ranking
    FROM monthly_movie_counts )
SELECT 
    release_year, release_month, movie_count FROM ranked_months WHERE ranking = 1
ORDER BY release_year DESC;

# 13.Find the report chard of top 10 actors by audience count. 
 SELECT lead_actor, ROUND(AVG(tomatometer_rating)) AS avg_tomatometer_rating,
	ROUND(AVG(tomatometer_count)) AS avg_tomatometer_count,
    ROUND(AVG(audience_rating)) AS avg_audience_rating,
    ROUND(AVG(audience_count)) AS avg_audience_count,
	COUNT(*) AS movie_count
    FROM movies
    GROUP BY lead_actor ORDER BY avg_audience_count DESC LIMIT 10;
    
# 14. Is there a relationship between genres and average audience_ratings.
SELECT genres, ROUND(AVG(audience_rating)) as avg_ratings FROM movies
GROUP BY genres ORDER BY avg_ratings DESC;

# 15. How many movies released on each day of the week.
with cte as(
SELECT DAYOFWEEK(original_release_date) as day_of_week, COUNT(*) AS movie_counts FROM movies 
GROUP BY DAYOFWEEK(original_release_date))
SELECT CASE  WHEN day_of_week = 1 THEN 'Sunday' 
            WHEN day_of_week =2 THEN 'Monday'
            WHEN day_of_week =3 THEN 'Tuesday'
            WHEN day_of_week =4 THEN 'Wednesday'
            WHEN day_of_week =5 THEN 'Thursday'
            WHEN day_of_week =6 THEN 'Friday'
            WHEN day_of_week =7 THEN 'Saturday'
        END AS day_name, movie_counts FROM cte ORDER BY movie_counts DESC;
        
# 16. Find the number of movies in each genre,  the average duration of each genre of movies, movie_counts
#  their average tomatometer_ratigns and audience_ratings.
SELECT genres AS genre, COUNT(*) AS movie_count,
    ROUND(AVG(runtime)) AS avg_duration, ROUND(AVG(tomatometer_rating)) AS avg_tomatometer_rating,
    ROUND(AVG(audience_rating)) AS avg_audience_rating
FROM movies GROUP BY genres
ORDER BY movie_count DESC;

# 17. Compare TOP 10 production companies in terms of number of movies and ratings.
SELECT 
    production_company, COUNT(*) AS movie_count,
    ROUND(AVG(tomatometer_rating)) AS avg_tomatometer_rating,
    ROUND(AVG(audience_rating)) AS avg_audience_rating
FROM movies GROUP BY production_company 
ORDER BY movie_count DESC, avg_tomatometer_rating DESC, avg_audience_rating DESC LIMIT 10;

# 18. Find movies which have largest difference in the scores between tomatometer ratings and audience ratings.
SELECT movie_title, tomatometer_rating, tomatometer_count, audience_rating, audience_count,
    ABS(tomatometer_rating - audience_rating) AS rating_difference
FROM  movies WHERE tomatometer_rating > 0 AND audience_count> 1000
ORDER BY rating_difference DESC LIMIT 10;

# 19. Find the combination of director, actor and author which will produce a hit movies.
SELECT 
    lead_director, lead_actor, lead_author, COUNT(*) AS movie_count,
    AVG(tomatometer_rating) AS avg_tomatometer_rating,
    AVG(audience_rating) AS avg_audience_rating,
    ROUND(AVG(average_rating))  AS avg_combined_rating
FROM movies GROUP BY lead_director, lead_actor, lead_author
HAVING  movie_count > 1 ORDER BY avg_combined_rating DESC, movie_count DESC
LIMIT 10;

# 20. Is there a relation between content_rating and audience ratings.
SELECT content_rating, ROUND(AVG(audience_rating)) AS avg_audience_rating,
    COUNT(*) AS movie_count
FROM movies GROUP BY content_rating
ORDER BY avg_audience_rating DESC;


select * from movies;







