USE ibm_hr;

SELECT *
FROM ibm_hr;


-- Total Number Of Employees and break down attrition numbers

SELECT 
	COUNT(EmployeeNumber) AS 'Total Employees',
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS 'Attrition Numbers',
    SUM(CASE WHEN Attrition = 'Yes' AND Gender = 'Male' THEN 1 ELSE 0 END) AS 'Male Attrition Employees',
    SUM(CASE WHEN Attrition = 'Yes' AND Gender = 'Female' THEN 1 ELSE 0 END) AS 'Male Attrition Employees'
FROM ibm_hr;

-- --------------------------------------------------------

-- Add a categorical income column to show attrition by income

ALTER TABLE ibm_hr
ADD cat_income VARCHAR(100);

UPDATE ibm_hr 
SET cat_income =(
SELECT
		(CASE
			WHEN MonthlyIncome BETWEEN 1000 AND 3000 THEN '1-3k'
			WHEN MonthlyIncome BETWEEN 3000 AND 6000 THEN '3-6k'
			WHEN MonthlyIncome BETWEEN 6000 AND 10000 THEN '6-10k'
			WHEN MonthlyIncome BETWEEN 10000 AND 15000 THEN '10-15k'
			ELSE '15-20k'
		END)
);

-- Impact of Monthly Income on Attrition

SELECT 
	cat_income AS 'Income',
	COUNT(cat_income) AS 'Attrition Number',
    COUNT(cat_income)/(SELECT COUNT(cat_income) FROM ibm_hr)*100 AS 'Percent of Total Employees'
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY cat_income
ORDER BY 2 DESC;


-- Impact of Salary Hike on Attrition

SELECT 
	Attrition,
    AVG(PercentSalaryHike)
FROM ibm_hr
GROUP BY Attrition;

-- --------------------------------------------------------

-- Create a categorical age column to show attrition by age range

ALTER TABLE ibm_hr
ADD cat_age VARCHAR(100);

UPDATE ibm_hr 
SET cat_age = (
SELECT
		(CASE
			WHEN Age BETWEEN 18 AND 25 THEN '18-25'
			WHEN Age BETWEEN 26 AND 35 THEN '26-35'
			WHEN Age BETWEEN 36 AND 45 THEN '36-45'
			WHEN Age BETWEEN 46 AND 55 THEN '46-55'
			ELSE '56-60'
		END)
);

-- Impact of Age on Attrition

SELECT 
	cat_age AS 'Age Range',
    COUNT(cat_age)/(SELECT COUNT(EmployeeNumber) FROM ibm_hr WHERE Attrition = 'Yes')*100 AS 'Percent of Attrition'
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY cat_age
ORDER BY 2 DESC;

-- --------------------------------------------------------

-- Add column to better represent values in WorkLifeBlance column 

ALTER TABLE ibm_hr
ADD wl_bal VARCHAR(10);
 
UPDATE ibm_hr
SET wl_bal = (	CASE
					WHEN WorkLifeBalance = 1 THEN 'Bad'
                    WHEN WorkLifeBalance = 2 THEN 'Okay'
                    WHEN WorkLifeBalance = 3 THEN 'Good'
                    ELSE 'Best'
				END);

-- Impact of Work-Life balance on Attrition

SELECT 
	wl_bal AS 'Work Life Balance',
    COUNT(wl_bal)/(SELECT COUNT(EmployeeNumber) FROM ibm_hr WHERE Attrition = 'Yes')*100 AS 'Percent of Attrition Values'
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY wl_bal
ORDER BY 2 DESC;

-- --------------------------------------------------------

-- Create a categorical commute distance column to show attrition by travel

ALTER TABLE ibm_hr
ADD cat_comm VARCHAR(100);

UPDATE ibm_hr 
SET cat_comm = (
SELECT
		(CASE
			WHEN DistanceFromHome BETWEEN 1 AND 7 THEN '1-7 miles'
			WHEN DistanceFromHome BETWEEN 8 AND 15 THEN '8-15 miles'
			WHEN DistanceFromHome BETWEEN 16 AND 20 THEN '16-20 miles'
			WHEN DistanceFromHome BETWEEN 21 AND 25 THEN '21-25 miles'
			ELSE '26-30 miles'
		END)
	);

-- Impact of daily commute on Attrition 

SELECT 
	cat_comm AS 'Commute Distance',
    COUNT(cat_comm)/(SELECT COUNT(EmployeeNumber) FROM ibm_hr WHERE Attrition = 'Yes')*100 AS 'Percent of Attrition Values'
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY cat_comm
ORDER BY 2 DESC;

-- Impact of work-related travel on Attrition 

SELECT 
	BusinessTravel,
    COUNT(BusinessTravel)
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY BusinessTravel
ORDER BY 2 DESC;

-- --------------------------------------------------------

-- Impact of working overtime on Attrition

SELECT 
	OverTime,
    COUNT(OverTime) AS 'Employees'
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY OverTime;
    
-- --------------------------------------------------------

-- Create a categorical years in current role column

ALTER TABLE ibm_hr
ADD cat_yrs_in_pos VARCHAR(100);

UPDATE ibm_hr 
SET cat_yrs_in_pos = (
SELECT
		(CASE
			WHEN YearsInCurrentRole BETWEEN 0 AND 2 THEN '0-2 Years'
			WHEN YearsInCurrentRole BETWEEN 2 AND 4 THEN '2-4 Years'
			WHEN YearsInCurrentRole BETWEEN 4 AND 7 THEN '4-7 Years'
			WHEN YearsInCurrentRole BETWEEN 7 AND 10 THEN '7-10 Years'
            WHEN YearsInCurrentRole BETWEEN 10 AND 15 THEN '10-15 Years'
			ELSE '15-20 Years'
		END)
	);

-- display number of employees in each department, role, 
-- and how long they've been in the same position
 
SELECT 
	Department, 
    JobRole,
    cat_yrs_in_pos AS 'Years in Current Position',
    COUNT(*) AS 'Employees'
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY Department, JobRole, cat_yrs_in_pos;

-- --------------------------------------------------------

-- Impact of Current Manager on Attrition

SELECT YearsWithCurrManager, 
	COUNT(YearsWithCurrManager)/(SELECT COUNT(EmployeeNumber) FROM ibm_hr WHERE Attrition = 'Yes')*100 
FROM ibm_hr
WHERE Attrition = 'Yes'
GROUP BY YearsWithCurrManager
ORDER BY 2 DESC;
