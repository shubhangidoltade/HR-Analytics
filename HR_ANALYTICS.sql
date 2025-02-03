CREATE DATABASE HR_Attrition_DA;

USE HR_Attrition_DA;
select * from HR_Analytics_DA;

CREATE TABLE HR_Analytics_DA (
    EmpID INT,
    Age INT,
    Attrition VARCHAR(50),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement	INT,
    JobLevel INT,	
    JobRole	VARCHAR(50),
    JobSatisfaction	INT,
    MaritalStatus VARCHAR(10),	
    MonthlyIncome	INT,
    MonthlyRate	INT,
    NumCompaniesWorked	INT,
    Over18	VARCHAR(5),
    OverTime	VARCHAR(5),
    PercentSalaryHike	INT,
    PerformanceRating	INT,
    RelationshipSatisfaction INT,	
    StandardHours	INT,
    StockOptionLevel	INT,
    TotalWorkingYears INT,	
    TrainingTimesLastYear	INT,
    WorkLifeBalance	INT,
    YearsAtCompany	INT,
    YearsInCurrentRole	INT,
    YearsSinceLastPromotion	INT,
    YearsWithCurrManager INT

   
);

desc HR_Analytics_DA;






LOAD DATA INFILE "C:/DA/DA PROJECTS/HR Analytics/HR_Analytics_DA.csv"
INTO TABLE HR_Analytics 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';



SELECT * FROM HR_Analytics_DA ;

#Below Lines will be deleted in final sql file                                                                            
#To Add New Column for Attrition_COUNT                                                                                                                                                    
                                                                             
ALTER TABLE  HR_Analytics_DA
ADD Attrition_COUNT INT;

UPDATE  HR_Analytics_DA
SET Attrition_COUNT = CASE
    WHEN Attrition = 'Yes' THEN 1
    WHEN Attrition = 'No' THEN 0
    ELSE NULL
    END;       
    
    
ALTER TABLE HR_Analytics_DA
ADD attrition_rate DECIMAL(5, 2);

-- Step 2: Update the column with calculated attrition rate
UPDATE HR_ANALYTICS_DA
SET attrition_rate = (Attrition_COUNT * 100.0) / EmployeeCount;

Select attrition_rate from HR_Analytics_DA;

/*KPI1:
Average Attrition rate for all Departments.*/

CREATE VIEW AttritionRate_by_Department AS
	SELECT 
			Department,
			ROUND((AVG((Attrition_Count)/(EmployeeCount))*100),2) as Avg_Attrition_Rate
	FROM 
			 HR_Analytics_DA
	GROUP BY 
			Department
	ORDER BY 
			Avg_Attrition_Rate DESC;
            
	 
	#USING VIEWS FOR KPI 1
     SELECT * FROM AttritionRate_by_Department;
     
     
     
      /*KPI2:
     Attrition rate by years at company.*/
     
    
CREATE VIEW attrition_rate_by_years AS
SELECT 
    yearsatcompany,
    AVG(attrition_rate) AS avg_attrition_rate
FROM HR_Analytics_DA

GROUP BY yearsatcompany;
   
	#USING VIEWS FOR KPI 2
	SELECT * FROM attrition_rate_by_years;
    
    

    /*KPI3:
     Attrition count by Job Role.*/
     
CREATE VIEW attrition_count_by_jobrole AS
SELECT 
    jobrole,
    SUM(Attrition_Count) AS total_attrition_count
FROM HR_Analytics_DA
GROUP BY jobrole;

#USING VIEWS FOR KPI 3
select * from  attrition_count_by_jobrole;


/*KPI4:
     Attrition count by Job Satisfaction.*/

Drop view attrition_count_by_job_satisfaction;
CREATE VIEW attrition_count_by_job_satisfaction AS
SELECT 
    jobrole,
    SUM(CASE WHEN HR_Analytics_DA.JobSatisfaction = 1 THEN attrition_count ELSE 0 END) AS "1",
    SUM(CASE WHEN HR_Analytics_DA.JobSatisfaction = 2 THEN attrition_count ELSE 0 END) AS "2",
    SUM(CASE WHEN HR_Analytics_DA.JobSatisfaction = 3 THEN attrition_count ELSE 0 END) AS "3",
    SUM(CASE WHEN HR_Analytics_DA.JobSatisfaction = 4 THEN attrition_count ELSE 0 END) AS "4",
    SUM(attrition_count) AS total_attrition_count
FROM HR_Analytics_DA
GROUP BY jobrole
ORDER BY "1" DESC; -- Sort by attrition count where JobSatisfaction = 1

#USING VIEWS FOR KPI 4
select * from attrition_count_by_job_satisfaction;



/*KPI5:
     Attrition rate by years since last promotion.*/


CREATE VIEW attrition_rate_by_years_since_last_promotion AS
SELECT 
    yearssincelastpromotion,
    sum(attrition_count) as total_attrition_count,
     (SUM(attrition_count) * 100.0) / NULLIF(SUM(employeecount), 0) AS attrition_rate
FROM HR_Analytics_DA
GROUP BY yearssincelastpromotion;

#USING VIEWS FOR KPI 5
select * from attrition_rate_by_years_since_last_promotion;


/*KPI6:
     Attrition count by age group.*/

CREATE VIEW attrition_count_by_age_group AS
SELECT
    CASE
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        WHEN age >= 55 THEN '55+'
        ELSE 'Below 26' -- If you want to include employees below 26 years old
    END AS age_group,
    
    -- Total employees in each age group
    COUNT(*) AS total_employees,
    
    -- Attrition count (number of employees who have left the company)
    SUM(attrition_count) AS total_attrition_count
FROM
    HR_Analytics_DA
GROUP BY
    age_group;
    
    #USING VIEWS FOR KPI 6
    select * from attrition_count_by_age_group;




     /*KPI7:
     Attrition rate Vs Monthly income .*/
     
     drop view attrition_by_monthly_income;
     CREATE VIEW attrition_by_monthly_income AS
SELECT 
    -- Grouping based on adjusted monthly income ranges
    CASE
        WHEN HR_Analytics_DA.MonthlyIncome BETWEEN 1000 AND 5000 THEN '1000-5000'
        WHEN HR_Analytics_DA.MonthlyIncome BETWEEN 5001 AND 10000 THEN '5001-10000'
        WHEN HR_Analytics_DA.MonthlyIncome BETWEEN 10001 AND 15000 THEN '10001-15000'
        WHEN HR_Analytics_DA.MonthlyIncome BETWEEN 15001 AND 19999 THEN '15001-19999'
        ELSE 'Unknown'
    END AS income_group,
    
  
    -- Average attrition rate (assuming this column exists in your data)
    AVG(HR_Analytics_DA.attrition_rate) AS avg_attrition_rate
FROM 
    HR_Analytics_DA
GROUP BY 
    income_group;

	
	;

     #USING VIEWS For KPI 7
     SELECT * FROM attrition_by_monthly_income;
     
     
     /*KPI8:
     Attrition count by salary slab*/
     
     CREATE VIEW attrition_count_by_salary_slab AS
SELECT 
    -- Grouping employees based on MonthlyIncome into the defined salary slabs
    CASE
        WHEN HR_Analytics_DA.MonthlyIncome <= 5000 THEN 'Up to 5K'
        WHEN HR_Analytics_DA.MonthlyIncome BETWEEN 5001 AND 10000 THEN '5K - 10K'
        WHEN HR_Analytics_DA.MonthlyIncome BETWEEN 10001 AND 15000 THEN '10K - 15K'
        WHEN HR_Analytics_DA.MonthlyIncome > 15000 THEN '15K+'
        ELSE 'Unknown'
    END AS salary_slab,
    
    -- Sum of attrition count for each salary slab
    SUM(HR_Analytics_DA.attrition_count) AS total_attrition_count,
    
    -- Total employees in each salary slab
    COUNT(*) AS total_employees
FROM 
    HR_Analytics_DA
GROUP BY 
    salary_slab;
    
 #USING VIEWS For KPI 8
     select * from attrition_count_by_salary_slab;
     
     
     /*KPI9:
     Attrition count by education field. */
     
     CREATE VIEW attrition_count_by_education_field AS
SELECT 
    HR_Analytics_DA.EducationField,  -- Grouping by EducationField
    -- Sum of attrition count for each education field
    SUM(HR_Analytics_DA.attrition_count) AS total_attrition_count
    
FROM 
    HR_Analytics_DA
GROUP BY 
    HR_Analytics_DA.EducationField;
    
    #USING VIEWS For KPI 9
    select * from attrition_count_by_education_field;
    
    
    
    /*KPI10:
     Attrition rate by OverTime. */
     
     
    CREATE VIEW attrition_rate_by_overtime AS
SELECT 
    -- Group employees by whether they worked overtime (Yes/No)
    HR_Analytics_DA.overtime AS overtime_status,
    
    -- Calculate the average attrition rate for employees who worked overtime vs. those who did not
    AVG(HR_Analytics_DA.attrition_rate) AS avg_attrition_rate
    
FROM 
    HR_Analytics_DA
GROUP BY 
    HR_Analytics_DA.overtime;


#USING VIEWS For KPI 10
select * from attrition_rate_by_overtime;


/*KPI11:
     Attrition rate by Marital Status. */

CREATE VIEW attrition_rate_by_marital_status AS
SELECT 
    HR_Analytics_DA.MaritalStatus,  -- Grouping by marital status
    -- Calculate the average attrition rate for each marital status group
    AVG(HR_Analytics_DA.attrition_rate) AS avg_attrition_rate
FROM 
    HR_Analytics_DA
GROUP BY 
    HR_Analytics_DA.MaritalStatus;


#USING VIEWS For KPI 11
select * from attrition_rate_by_marital_status;




 /*KPI12:
     Attrition rate by Distance from home. */
     
CREATE VIEW attrition_rate_by_distance_from_home AS
SELECT 
    -- Grouping employees by distance from home ranges
    CASE
        WHEN HR_Analytics_DA.DistanceFromHome BETWEEN 1 AND 10 THEN '1-10'
        WHEN HR_Analytics_DA.DistanceFromHome BETWEEN 11 AND 20 THEN '11-20'
        WHEN HR_Analytics_DA.DistanceFromHome BETWEEN 21 AND 30 THEN '21-30'
        ELSE 'Other' -- For employees outside of these ranges
    END AS distance_group,
    
    -- Calculate the average attrition rate for each distance range
    AVG(HR_Analytics_DA.attrition_rate) AS avg_attrition_rate
FROM 
    HR_Analytics_DA
GROUP BY 
    distance_group;

#USING VIEWS For KPI 12
select * from attrition_rate_by_distance_from_home;



/*KPI13:
     Attrition count by number of companies worked. */
     
CREATE VIEW attrition_count_by_num_companies_worked AS
SELECT 
    -- Group employees by the number of companies worked
    CASE
        WHEN HR_Analytics_DA.NumCompaniesWorked BETWEEN 0 AND 2 THEN '0-2'
        WHEN HR_Analytics_DA.NumCompaniesWorked BETWEEN 3 AND 5 THEN '3-5'
        WHEN HR_Analytics_DA.NumCompaniesWorked BETWEEN 6 AND 9 THEN '6-9'
        ELSE '10+'  -- Any employee who has worked 10 or more companies
    END AS companies_worked_group,
    
    -- Calculate the total attrition count for each group
    SUM(HR_Analytics_DA.attrition_count) AS total_attrition_count
FROM 
    HR_Analytics_DA
GROUP BY 
    companies_worked_group;
    
    
    #USING VIEWS For KPI 13
    select * from attrition_count_by_num_companies_worked;

     /*KPI14:
     Average working years for each Department.*/
     
     
     CREATE VIEW Total_Working_Years_by_Department AS
     SELECT
			HR_Analytics_DA.Department,
			ROUND(AVG(HR_Analytics_DA.TotalWorkingYears),2) AS Avg_Working_Years
	 FROM
			HR_Analytics_DA
	
	 GROUP BY
			Department
	 ORDER BY 
			Department;
     
     
     #USING VIEWS FOR KPI 14
     SELECT * FROM Total_Working_Years_by_Department;

     
     
     
     /*KPI15:
     Job Role Vs Work life balance.*/
     
     drop view Work_Life_Balance_by_Job_Role;
    CREATE VIEW Work_Life_Balance_by_Job_Role AS
	SELECT
			HR_Analytics_DA.JobRole,
			SUM(CASE WHEN HR_Analytics_DA.WorkLifeBalance = 4 THEN 1 ELSE 0 END) AS Excellent,
			SUM(CASE WHEN HR_Analytics_DA.WorkLifeBalance = 3 THEN 1 ELSE 0 END) AS Good,
			SUM(CASE WHEN HR_Analytics_DA.WorkLifeBalance = 2 THEN 1 ELSE 0 END) AS Average,
			SUM(CASE WHEN HR_Analytics_DA.WorkLifeBalance = 1 THEN 1 ELSE 0 END) AS Poor
           
	FROM
			HR_Analytics_DA

	GROUP BY
			JobRole
	ORDER BY
			JobRole;

    #USING VIEWS FOR KPI 15
    SELECT * FROM Work_Life_Balance_by_Job_Role ;
    
    
  
   /*KPI16:
     attrition rate Vs Work life balance.*/
     
	CREATE VIEW attrition_rate_by_Work_Life_Balance AS
	SELECT
			HR_Analytics_DA.WorkLifeBalance,
			avg(Attrition_rate) as Attrition_rate
           
	FROM
			HR_Analytics_DA 
            
            group by worklifebalance
            
            order by worklifebalance;
            
	#USING VIEWS FOR KPI 16
	 select * from attrition_rate_by_Work_Life_Balance;
			
  
    
      
      
     

     
     #---------------------------------------------------------------------------Thank You------------------------------------------------------------------------------------------------    
																	    
