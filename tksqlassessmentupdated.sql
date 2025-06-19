-- 1)The poetry in this database is the work of children in grades 1 through 5.
-- a. How many poets from each grade are represented in the data?

SELECT  COUNT(DISTINCT name), grade_id
FROM author
GROUP BY grade_id;
-- 623	1
-- 1437	2
-- 2344	3
-- 3288	4
-- 3464	5



-- b. How many of the poets in each grade are Male and how many are Female? Only return the poets identified as Male or Female.

SELECT COUNT(DISTINCT author.name) AS num_of_students, grade_id, gender.name
FROM author
INNER JOIN gender ON author.gender_id = gender.id
WHERE (gender.name = 'Female') OR (gender.name = 'Male')
GROUP BY  gender.name, grade_id;

-- 243	1	"Female"
-- 605	2	"Female"
-- 948	3	"Female"
-- 1241	4	"Female"
-- 1294	5	"Female"
-- 163	1	"Male"
-- 412	2	"Male"
-- 577	3	"Male"
-- 723	4	"Male"
-- 757	5	"Male"

-- c. Briefly describe the trend you see across grade levels.

--More females than Males are interested in poetry generally speaking and that tracks over time. 
--However, this does not account for ambiguity or nulls. 




-- 2)Two foods that are favorites of children are pizza and hamburgers. Which of these things do children write about more often? Which do they have the most to say about when they do?
--total number of poems that mention pizza and total number that mention the word hamburger in the TEXT or TITLE,
--average character count for poems that mention pizza and also for poems that mention the word hamburger in the TEXT or TITLE. 
--Do this in a single query, (i.e. your output should contain all the information).

 

SELECT 
	COUNT(CASE WHEN title ILIKE '%pizza%' THEN 'pizza' END ) AS pizza_in_title,
	COUNT(CASE WHEN text ILIKE '%pizza%' THEN 'pizza' END ) AS pizza_in_text,
	COUNT(CASE WHEN title ILIKE '%hamburger%' THEN 'hamburger' END ) AS hamburger_in_title,
	COUNT(CASE WHEN text ILIKE '%hamburger%' THEN 'hamburger' END ) AS hamburger_in_text,
	ROUND(AVG(char_count) FILTER (WHERE title ILIKE '%pizza%' OR text ILIKE '%pizza%'),2) as avg_char_pizza,
	ROUND(AVG(char_count) FILTER (WHERE title ILIKE '%hamburger%' OR text ILIKE '%hamburger%'),2) as avg_char_hamburger
FROM poem;

-- 106	225	12	28	240.72	245.06


-- 3)Do longer poems have more emotional intensity compared to shorter poems?

-- a. Start by writing a query to return each emotion in the database with its average intensity and average character count.


SELECT *
FROM poem_emotion
INNER JOIN emotion 
ON emotion.id = poem_emotion.emotion_id
INNER JOIN poem 
ON poem_emotion.poem_id = poem.id;

SELECT DISTINCT emotion.name, ROUND(AVG(intensity_percent),2) AS avg_intensity, ROUND(AVG(char_count),2) AS avg_char_count
FROM poem_emotion
INNER JOIN emotion 
ON emotion.id = poem_emotion.emotion_id
INNER JOIN poem 
ON poem_emotion.poem_id = poem.id
GROUP BY emotion.name;

-- "Anger"	43.57	261.16
-- "Fear"	45.47	256.27
-- "Joy"	47.82	220.99
-- "Sadness"	39.26	247.19

-- Which emotion is associated the longest poems on average?

SELECT DISTINCT emotion.name, ROUND(AVG(intensity_percent),2) AS avg_intensity, ROUND(AVG(char_count),2) AS avg_char_count
FROM poem_emotion
INNER JOIN emotion 
ON emotion.id = poem_emotion.emotion_id
INNER JOIN poem 
ON poem_emotion.poem_id = poem.id
GROUP BY emotion.name
ORDER BY avg_char_count DESC
LIMIT 1;

-- "Anger"	43.57	261.16

-- Which emotion has the shortest?

SELECT DISTINCT emotion.name, ROUND(AVG(intensity_percent),2) AS avg_intensity, ROUND(AVG(char_count),2) AS avg_char_count
FROM poem_emotion
INNER JOIN emotion 
ON emotion.id = poem_emotion.emotion_id
INNER JOIN poem 
ON poem_emotion.poem_id = poem.id
GROUP BY emotion.name
ORDER BY avg_char_count  
LIMIT 1;

-- "Joy"	47.82	220.99



-- b. Convert the query you wrote in part a into a CTE. 
--find 5 most intense poems that express anger 
-- longer or shorter than average angry poem?.

WITH emotiontablecte AS 
(
SELECT DISTINCT emotion.name, AVG(intensity_percent) as avg_intensity, AVG(char_count) AS avg_char_count
FROM poem_emotion
INNER JOIN emotion 
ON emotion.id = poem_emotion.emotion_id
INNER JOIN poem 
ON poem_emotion.poem_id = poem.id
GROUP BY emotion.name
ORDER BY avg_char_count  
)
SELECT DISTINCT emotion.name, intensity_percent, poem.title, poem.author_id, poem.char_count,
	   CASE WHEN char_count > emotiontablecte.avg_char_count THEN 'longer' END AS longer_than_avg,
	   CASE WHEN char_count < emotiontablecte.avg_char_count THEN 'shorter' END AS shorter_than_avg, poem.text
FROM poem_emotion
INNER JOIN emotion 
ON emotion.id = poem_emotion.emotion_id
INNER JOIN poem 
ON poem_emotion.poem_id = poem.id
INNER JOIN emotiontablecte ON emotiontablecte.name = emotion.name
WHERE emotiontablecte.name = 'Anger' 
ORDER BY intensity_percent desc
limit 5;

-- "Anger"	96	"Horse"	9738	168		"shorter"
-- "Anger"	96	"Nature&apos;s Ways"	9227	89		"shorter"
-- "Anger"	95	"Think"	8484	134		"shorter"
-- "Anger"	95	"Take Me Away"	8373	204		"shorter"
-- "Anger"	93	"Watching the Bird"	4691	348	"longer"	

-- What is the most angry poem about?

--The most angry according to my data hits more as a joke than an angry emotion.
--Its about a horse who had ants in its pants....poor thing. *makes that God Bless it's heart face*
--It could be beause the student included the word "outraged". 

-- Do you think these are all classified correctly?

--I do not. If the system is meant to simply pick up on key words, then without applying 
--context it will result in an inappropriate  emotional response. 


-- 4)Compare the 5 most joyful poems by 1st graders to the 5 most joyful poems by 5th graders.


(WITH topjoy AS 
(
SELECT poem_emotion.id, poem_emotion.intensity_percent, poem_emotion.poem_id, emotion.name
FROM poem_emotion
INNER JOIN emotion
ON emotion.id = poem_emotion.emotion_id
WHERE emotion.name = 'Joy'
ORDER BY intensity_percent DESC
)
SELECT title, author_id, intensity_percent, grade, gender.name
FROM poem
INNER JOIN author
ON poem.author_id = author.id
INNER JOIN gender
ON author.gender_id = gender.id 
INNER JOIN topjoy 
ON poem.id = topjoy.poem_id
INNER JOIN grade
ON grade.id = author.grade_id
WHERE grade_id = '1'  
LIMIT 5)

UNION
--GOT MY ANSWERS AND THEN UNIONED IT JUST TO SEE WHAT IT LOOKED LIKE ORDER BY INTENSITY . 
(WITH topjoy AS 
(
SELECT poem_emotion.id, poem_emotion.intensity_percent, poem_emotion.poem_id, emotion.name
FROM poem_emotion
INNER JOIN emotion
ON emotion.id = poem_emotion.emotion_id
WHERE emotion.name = 'Joy'
ORDER BY intensity_percent DESC
)
SELECT title, author_id, intensity_percent, grade, gender.name
FROM poem
INNER JOIN author
ON poem.author_id = author.id
INNER JOIN gender
ON author.gender_id = gender.id 
INNER JOIN topjoy 
ON poem.id = topjoy.poem_id
INNER JOIN grade
ON grade.id = author.grade_id
WHERE grade_id = '5'  
LIMIT 5)
ORDER BY intensity_percent desc;

--TOP 5 JOYFUL 5TH GRADERS 
-- "My Dog"	10048	99	"(5,""5th Grade"")"	"Female"
-- "Dark"	10037	98	"(5,""5th Grade"")"	"Male"
-- "Lighning"	10333	98	"(5,""5th Grade"")"	"Male"
-- "The Double Play"	9916	94	"(5,""5th Grade"")"	"Male"
-- "Swimming"	7923	92	"(5,""5th Grade"")"	"Female"

--TOP 5 JOYFUL 1ST GRADERS 
-- "Waterfall"	613	98	"(1,""1st Grade"")"	"Ambiguous"
-- "When it Rains"	598	88	"(1,""1st Grade"")"	"NA"
-- "The book"	293	86	"(1,""1st Grade"")"	"Male"
-- "A kid in a box"	15	86	"(1,""1st Grade"")"	"Male"
-- "Kites"	112	86	"(1,""1st Grade"")"	"Female"


-- a. Which group writes the most joyful poems according to the intensity score?

--5th graders


-- b. How many times do males show up in the top 5 poems for each grade? Females?

-- 2 Males / 1 Female in 1st grade 
-- 3 Males / 2 Females in 5th grade 

-- 5)Robert Frost was a famous American poet. There is 1 poet named robert per grade.

 
SELECT author_id, grade_id, emotion_id
FROM poem
INNER JOIN author
ON poem.author_id = author.id
INNER JOIN poem_emotion
ON poem_emotion.poem_id = poem.id
WHERE author.name LIKE 'robert'  
order by author_id;

 

-- a. Examine the 5 poets in the database with the name robert. Create a report showing the distribution of emotions that characterize their work by grade.
-- b. Export this report to Excel and create an appropriate visualization that shows what you have found.


-- c. Write a short description that summarizes the visualization.

--*SEE PIVOT SHEET* The emotional volatility is mostly seen between first and second grade, whereas emotions stabilize from third to fifth grades. 


