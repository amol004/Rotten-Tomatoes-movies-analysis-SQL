# Rotten-Tomatoes-movies-analysis-SQL


## About Dataset



Movies' data is stored on several popular websites, but when it comes to critic reviews there is no better place than Rotten Tomatoes. This website allows to compare the ratings given by regular users (audience score) and the ratings given/reviews provided by critics (tomatometer) who are certified members of various writing guilds or film critic-associations.

# Content
In the movies dataset each record represents a movie available on Rotten Tomatoes, with the URL used for the scraping, movie tile, description, genres, duration, director, actors, users' ratings, and critics' ratings.
In the critics dataset each record represents a critic review published on Rotten Tomatoes, with the URL used for the scraping, critic name, review publication, date, score, and content.
 
 # Columns 

rotten_tomatoes_link: URL to the Rotten Tomatoes page for the movie

movie_title: Title of the movie

movie_info: Additional information about the movie

critics_consensus: Consensus summary from critics

content_rating: Content rating of the movie

genres: Genres of the movie

directors: Directors of the movie

authors: Authors of the movie (e.g., screenplay writers)

actors: Actors in the movie

original_release_date: Original release date of the movie

streaming_release_date: Date when the movie was made available for streaming

runtime: Duration of the movie in minutes

production_company: Production company that produced the movie

tomatometer_status: Status of the Tomatometer (e.g., Fresh, Rotten)

tomatometer_rating: Rating given by critics (Tomatometer score)

tomatometer_count: Total number of critic reviews

audience_status: Status of the audience rating

audience_rating: Rating given by the audience

audience_count: Number of audience reviews

tomatometer_top_critics_count: Number of reviews from top critics

tomatometer_fresh_critics_count: Number of fresh critic reviews

tomatometer_rotten_critics_count: Number of rotten critic reviews


# Objectives

The SQL case study aims to:

Analyze the distribution of movie ratings across different genres.

Compare critic ratings with audience ratings.

Identify trends in movie ratings over time.

Explore the relationship between critic reviews and the tomatometer rating.

# Approach

Data Cleaning: Handle missing values and inconsistencies in the dataset.

Data Analysis: Write SQL queries to extract insights from the dataset.\

Visualization: Generate reports and visualizations based on the SQL query results (if applicable).

# SQL Queries and Findings
1. Movies with the Highest Tomatometer Rating

       SELECT movie_title, tomatometer_rating 
       FROM movies 
       WHERE tomatometer_rating = 100;
![1](https://github.com/user-attachments/assets/3257506b-4333-44d6-8c5a-a56dade3ff8e)

Out of 14446 movies only 542 movies have 100% ratings that is only 4% of all the movies released.

2. Find top 10 movies which have highest both tomatometer_rating and audience_rating.

          SELECT movie_title, tomatometer_rating, audience_rating , 
          ROUND((tomatometer_rating+audience_rating)/2,1) AS average_rating
          FROM movies 
          ORDER BY average_rating DESC LIMIT 10;
   ![2](https://github.com/user-attachments/assets/51f15392-7856-4cc4-abc3-607061ecc0b4)

3. How many movies out of total have tomatometer_rating more than the average_tomatometer_ratings.

       with cte as(
       SELECT COUNT(*) AS total_movies, ROUND(AVG(tomatometer_rating),2) AS average_ratings,
       SUM(CASE 
	     WHEN tomatometer_rating > (SELECT AVG(tomatometer_rating) FROM movies) THEN 1 
      	ELSE 0 END) AS more_than_avg FROM movies) 
       SELECT total_movies, average_ratings,  more_than_avg, 
       ROUND((more_than_avg/total_movies)*100,2) AS movies_percentage_more_than_avg 
       FROM cte;

4. Find the top 10 longest movie and top 10 shortest movie and compare their tomatometer_ratings as well as audience_rating.

       (SELECT movie_title, runtime, tomatometer_rating, audience_rating FROM movies
       ORDER BY runtime DESC LIMIT 10)
       UNION ALL
       (SELECT movie_title, runtime, tomatometer_rating, audience_rating FROM movies
       ORDER BY runtime ASC LIMIT 10);
![e4](https://github.com/user-attachments/assets/b3b4b95d-6476-44a5-975a-705c2c06fbc9)

5. Find movies which have highest tomatometer_ratings and where tomatometer_top_critic counts is more than 65.

       SELECT movie_title, runtime, tomatometer_rating, audience_rating, tomatometer_top_critics_count FROM movies
       WHERE tomatometer_top_critics_count >65
       ORDER BY tomatometer_rating DESC;
![e5](https://github.com/user-attachments/assets/87f77d38-5d31-4697-8c30-5510484ca2c0)

6. Find the TOP 20 movie for which the difference between original_release_date and streaming_release_date is maximum in months.

       SELECT movie_title, runtime, tomatometer_rating, original_release_date, streaming_release_date,
       ABS(timestampdiff(YEAR, streaming_release_date, original_release_date)) AS time_diff FROM movies 
       ORDER BY time_diff  DESC LIMIT 20;


![6](https://github.com/user-attachments/assets/eac56dcd-86da-42a6-b52f-61bd76cdd422)

7. Find all the movies made by top three director who have made atleast 10 movies in terms of tomatometer_ratings.

        WITH CTE AS(
        SELECT lead_director, COUNT(*) as movie_count, ROUND(AVG(tomatometer_rating),2) as avg_rating FROM movies 
        GROUP BY lead_director 
        HAVING movie_count > 10 ORDER BY AVG(tomatometer_rating) DESC LIMIT 3)
        SELECT movie_title, runtime, tomatometer_rating, audience_rating, lead_director
        FROM movies WHERE lead_director IN (SELECT lead_director FROM CTE);

![7](https://github.com/user-attachments/assets/d736c15b-954d-494c-b117-5cd0d8969f0c)

Director Akira Kurosawa has the highest ratings whereas William Wyler has made most number of movies with good ratings.

8. Find the best movie of each year in terms of ratings.


		WITH ranked_movies AS (
		    SELECT movie_title, original_release_date, average_rating, genres,
		        YEAR(original_release_date) AS release_year,
		        ROW_NUMBER() OVER (PARTITION BY YEAR(original_release_date) ORDER BY average_rating DESC) AS ranking
		    FROM movies)
		SELECT movie_title,  original_release_date, average_rating , genres
		FROM ranked_movies WHERE ranking = 1;

![8](https://github.com/user-attachments/assets/0c4404dd-4f91-4dff-b730-ad6e5f07e9d6)

Out of 105 years of movie data, for about 35 years, the genre 'Art House & International' has produced the best movies.
The genres 'Western' and 'Musical & Performing Arts' each have the best movie for only one year.

9. What are the top 5 actors in terms of audience ratings with at least 10 movies.


		SELECT lead_actor, ROUND(AVG(audience_rating),2) AS avg_rating, COUNT(*) AS movie_count
		    FROM movies
		    GROUP BY lead_actor
		    HAVING movie_count >= 10 ORDER BY avg_rating DESC LIMIT 5;
![9](https://github.com/user-attachments/assets/ac86526f-e386-4801-8ea9-39053fe714fb)

10. Find number of movies done by each actor and their average audience rating.


		SELECT lead_actor, COUNT(*) AS movie_count, ROUND(AVG(audience_rating),2) AS avg_rating
		FROM movies GROUP BY lead_actor ORDER BY movie_count DESC;

![10](https://github.com/user-attachments/assets/b18ae084-6ad5-4536-96e7-fa4864349563)

   

   

