# SQL-Data-Cleaning

Layoff Data Cleaning Project using SQL

Project Overview:

This project focuses on cleaning and preparing layoff data for further analysis using SQL. Data cleaning is a critical step in data preprocessing to ensure accuracy, consistency, and reliability of the data. The dataset used contains information about layoffs, including company names, locations, industries, number of layoffs, and other related details.

In this project, I applied various SQL techniques to clean and standardize the dataset, making it ready for exploratory data analysis (EDA) and reporting.

Dataset

The dataset contains the following columns:

 `company`: Name of the company where layoffs occurred.
 `location`: The company's location.
`industry`: The industry in which the company operates.
`total_laid_off`: The total number of employees laid off.
`percentage_laid_off`: The percentage of the workforce laid off.
`date`: The date the layoffs occurred.
`stage`: The stage of the company (e.g., Seed, Series A, etc.).
`country`: The country where the layoffs occurred.
`funds_raised_millions`: The amount of funds raised by the company in millions.

Steps in Data Cleaning:

1. Creating a Staging Database:
I first created a staging table to hold a copy of the original data for cleaning.

```sql
CREATE TABLE layoff_stage LIKE layoffs;
INSERT INTO layoff_stage SELECT * FROM layoffs;
SELECT * FROM layoff_stage;
```

2. Removing Duplicates:
To ensure that the data is unique and free from redundant records, I removed duplicate rows based on the key columns.

```sql
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_value 
FROM layoff_stage;
```

I identified and deleted duplicate rows by using a `ROW_NUMBER()` function in a Common Table Expression (CTE) and then inserted the cleaned data into a new table.

```sql
WITH duplicate_cte AS (
    SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_value
    FROM layoff_stage
)
DELETE FROM layoff_stage_dup WHERE row_value > 1;
```

3.Standardizing the Data:

I standardized key columns to ensure data consistency.

Company Column:

- Removed unnecessary spaces from company names.
```sql
UPDATE layoff_stage_dup SET company = TRIM(company);
```

Industry Column:

- Standardized variations in industry names, e.g., ensuring consistent representation of "crypto".
```sql
UPDATE layoff_stage_dup SET industry = 'crypto' WHERE industry LIKE 'crypto%';
```

Country Column:

- Standardized country names by removing extra trailing characters.
```sql
UPDATE layoff_stage_dup SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'united states%';
```

Location Column:

- Removed unnecessary characters from location names.
```sql
UPDATE layoff_stage_dup SET location = TRIM(TRAILING '.' FROM location) WHERE location LIKE 'washington%';
UPDATE layoff_stage_dup SET location = REGEXP_REPLACE(location, '[^a-zA-Z. ]', '');
UPDATE layoff_stage_dup SET location = 'Non U.S' WHERE location LIKE 'NonU.S.%';
```

4. Handling Dates :
The `date` column was in text format, so I converted it to the proper SQL `DATE` format.

```sql
UPDATE layoff_stage_dup SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoff_stage_dup MODIFY `date` DATE;
```

5. Handling Null and Blank Values :
I handled missing and blank values in the dataset:

- Updated blank entries in the `industry` column to `NULL`.
```sql
UPDATE layoff_stage_dup SET industry = NULL WHERE industry = '';
```

- Filled in missing industry values by matching companies with the same name but valid industry values.
```sql
UPDATE layoff_stage_dup t1 
JOIN layoff_stage_dup t2 ON t1.company = t2.company 
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
```

 6. Removing Unwanted Rows and Columns:
I removed rows where both `total_laid_off` and `percentage_laid_off` were `NULL`, as these records were considered irrelevant for the analysis.

```sql
DELETE FROM layoff_stage_dup WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```

After cleaning, I removed the helper column `row_value` used for de-duplication.

```sql
ALTER TABLE layoff_stage_dup DROP COLUMN row_value;
```

7. Final Cleaned Dataset:
The final dataset, `layoff_stage_dup`, is free from duplicates, standardized, and properly formatted. You can view the cleaned dataset with the following query:

```sql
SELECT * FROM layoff_stage_dup;
```

Conclusion:

This project provided hands-on experience with various data cleaning techniques in SQL. By removing duplicates, standardizing data, handling null values, and cleaning up columns, the dataset is now ready for deeper analysis and exploration.

Technologies Used:
SQL (Database : MySQL)

How to Use This Project:
1. Clone the repository to your local machine.
2. Import the dataset and run the SQL queries provided in the `layoff_stage.sql` file to replicate the cleaning process.
3. Explore the cleaned dataset for further analysis.

Contact:
If you have any questions or feedback, feel free to reach out to me via 
[Email id](sanjaykumar2372003@gmail.com)
[LinkedIn](https://www.linkedin.com/in/sanjayk58979a251/) or 
check out more of my projects on [GitHub](https://github.com/Sanjaykumar20cs084).



