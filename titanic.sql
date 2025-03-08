CREATE TABLE titanic_survival_rate(
PassengerId	int,Survived smallint,Pclass smallint,Name varchar(40),Sex varchar(10),Age int,	SibSp smallint,Parch	smallint,Ticket varchar(40),	Fare numeric(10,2),	Cabin varchar(40),Embarked char(2)
)
SELECT * FROM titanic_survival_rate

ALTER TABLE titanic_survival_rate
RENAME TO titanic;

COPY titanic from 'C:\Users\polla\Downloads\archive (1)\tested.csv' csv header
SELECT * FROM titanic

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'titanic'

SELECT 
SUM(CASE WHEN passengerid ISNULL THEN 1 ELSE 0 END)AS passengerid_nulls,
SUM(CASE WHEN survived ISNULL THEN 1 ELSE 0 END)AS survived,
SUM(CASE WHEN pclass ISNULL THEN 1 ELSE 0 END) AS p_class,
SUM(CASE WHEN name ISNULL THEN 1 ELSE 0 END) AS name,
SUM(CASE WHEN sex  ISNULL THEN 1 ELSE 0 END) AS sex,
SUM(CASE WHEN age ISNULL THEN 1 ELSE 0 END) AS age,
SUM(CASE WHEN sibsp ISNULL THEN 1 ELSE 0 END) AS sibsp,
SUM(CASE WHEN parch ISNULL THEN 1 ELSE 0 END) AS parch,
SUM(CASE WHEN ticket ISNULL THEN 1 ELSE 0 END) AS ticket,
SUM(CASE WHEN fare ISNULL THEN 1 ELSE 0 END) AS fare,
SUM(CASE WHEN cabin ISNULL THEN 1 ELSE 0 END) AS cabin,
SUM(CASE WHEN embarked ISNULL THEN 1 ELSE 0 END) AS embarked
FROM titanic

UPDATE titanic 
SET 
	age = COALESCE(age,45),
	cabin =  COALESCE(cabin,'ignored'),
	fare = COALESCE(fare,0)
WHERE 
age ISNULL OR cabin ISNULL OR fare  ISNULL 

SELECT * FROM titanic

--BASIC EXPLORATION
--1. What is the overall survival rate?
SELECT 
SUM(CASE WHEN survived = 1 THEN 1 ELSE 0 END)*100/ COUNT(*) AS survival_rate_IN_PERCENTAGE,
COUNT(*) as total_passengers,
SUM(CASE WHEN survived = 1 THEN 1 ELSE 0 END)AS SURVIVED 
FROM titanic



--2.How many passengers were in each passenger class (Pclass)?
SELECT COUNT(*) as total_passengers,pclass FROM titanic
GROUP BY pclass 
ORDER BY 1 DESC

--3.What was the distribution of male and female passengers?
SELECT COUNT(*),sex FROM titanic
GROUP BY sex
ORDER BY 1 DESC

--4.What is the range of ages in the dataset?
SELECT 
MAX(age), MIN (age)
FROM titanic

--5.Where did most passengers embark from (Embarked)
SELECT
CASE 
	WHEN embarked = 'S' THEN 'Southampton'
	WHEN embarked = 'C' THEN 'Cherbourg'
	ELSE 'Queenstown'
END AS embarked_ports,
COUNT(*) as total_passengers, 
COUNT(*)* 100/(SELECT COUNT(*) FROM titanic WHERE embarked IS NOT NULL) AS percentage
FROM titanic
GROUP BY embarked
ORDER BY 1 DESC

UPDATE titanic 
SET embarked =CASE
	WHEN embarked = 'ignored' THEN 's'
	ELSE embarked 
END

--Relationship Analysis:
--1.How did survival rates vary by passenger class?
SELECT
CASE 
	WHEN pclass = 1 THEN 'FIRST CLASS'
	WHEN pclass = 2 THEN 'SECOND CLASS'
	ELSE 'THIRD CLASS'
END AS classes,
COUNT (*) as passenger_lists,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END)AS SURVIVED,
SUM(CASE WHEN survived =0 THEN 1 ELSE 0 END)AS DIED,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END) *100 /COUNT (*) AS survival_rate
FROM titanic
WHERE pclass IS NOT NULL 
GROUP BY pclass 
ORDER BY 1 DESC 

--2.Did women have a higher survival rate than men?
SELECT
sex,
COUNT(*) as TOTAL_passengers, SUM (CASE WHEN survived = 1 THEN 1 ELSE 0 END) AS survived_people,
SUM (CASE WHEN survived = 1 THEN 1 ELSE 0 END)*100/COUNT(*) AS survival_rate_in_percent
FROM titanic
WHERE sex IS NOT NULL
GROUP BY sex 
ORDER BY 4 DESC


--3.How did age affect survival rates?
SELECT 
CASE 
 WHEN age < 18 THEN 'children'
 WHEN age >18 AND age<60 THEN 'adults'
 else 'seniors'
END AS Age_group,
SUM(CASE WHEN survived = 1 Then 1 else 0 END) AS SURVIVORS,
COUNT(*) AS TOTAL_PASSENGERS,
SUM(CASE WHEN survived = 1 Then 1 else 0 END) *100 /COUNT(*)  AS survival_rate_IN_percent
FROM titanic
WHERE age IS NOT NULL
GROUP BY Age_group
ORDER BY survival_rate_IN_percent DESC


--4.Did passengers with more siblings/spouses (SibSp) have a higher chance of survival?

SELECT
    CASE
        WHEN sibsp = 0 THEN 'No Siblings/Spouses'
        WHEN sibsp BETWEEN 1 AND 2 THEN '1-2 Siblings/Spouses'
        ELSE '3+ Siblings/Spouses'
    END AS sibsp_category,
    COUNT(*) AS total_passengers,
    SUM(CASE WHEN survived = 1 THEN 1 ELSE 0 END) AS survived_passengers,
    (SUM(CASE WHEN survived = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*)) AS survival_rate
FROM titanic
GROUP BY sibsp_category
ORDER BY survival_rate DESC;

--5.Did passengers with more parents/children (Parch) have a higher chance of survival?
SELECT 
CASE 
	WHEN sibsp = 0 THEN 'No parents/childrens'
    WHEN sibsp BETWEEN 1 AND 2 THEN '1-2 parents/childrens'
    ELSE '3+ parents/childrens'
    END AS parch_category,
COUNT(*) AS Total_passengers,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END) AS survived_passengers,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END)*100/COUNT(*) AS survival_rate
FROM titanic
GROUP BY parch_category
ORDER BY survival_rate DESC;

SELECT * FROM titanic
--6.How did fare correlate with survival?
SELECT 
CASE 
	WHEN fare < 20 THEN 'low_fare'
	WHEN fare >= 20 AND fare <= 80 THEN 'medium_fare'
	ELSE 'premium'
END AS fare_categories,
COUNT(*) AS Total_passengers,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END) AS survived,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END)*100/COUNT(*) AS survival_rate
FROM titanic
GROUP BY fare_categories
ORDER BY survival_rate DESC

--7.How did the port of embarkation effect survival rates?
SELECT
CASE 
	WHEN embarked = 'S' THEN 'Southampton'
	WHEN embarked = 'C' THEN 'Cherbourg'
	WHEN embarked = 'Q' THEN 'Queenstown'
END AS embarked_ports,pclass,
COUNT(*) as total_passengers,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END) AS survived,
SUM(CASE WHEN survived =1 THEN 1 ELSE 0 END)*100.0/COUNT(*) AS percentage_survivalrate
FROM titanic
GROUP BY embarked_ports,pclass 
ORDER BY  embarked_ports DESC

--8.Create a new feature "FamilySize" by combining "SibSp" and "Parch."
SELECT sibsp,parch, family_size FROM titanic
--9.Create a new feature "IsAlone" to indicate whether a passenger was traveling alone
SELECT 
CASE WHEN 
