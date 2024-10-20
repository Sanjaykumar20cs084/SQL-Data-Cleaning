-- Data cleaning in SQL 
 
 -- Creating staging database:
select * from layoffs;

create table layoff_stage
like layoffs;

insert layoff_stage select * from layoffs;

select * from layoff_stage;

-- step 1: removing duplicates :
select * , 
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_value from layoff_stage; 

with duplicate_cte as 
( 
select * , 
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_value from layoff_stage
) select * from duplicate_cte where row_value > 1 ;


CREATE TABLE `layoff_stage_dup` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
   `row_value` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoff_stage_dup
select * , 
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_value from layoff_stage ;

delete from layoff_stage_dup where row_value>1;

select * from layoff_stage_dup ;

-- step 2: standardizing the data :

select * from layoff_stage_dup ;

-- standardizing company column data :

select distinct company from layoff_stage_dup;

update layoff_stage_dup set company= trim(company) ;

-- standardizing industry column data :

select distinct industry from layoff_stage_dup;

update  layoff_stage_dup set industry = 'crypto' where industry like 'crypto%'; 

-- standardizing country column data :

select distinct country from layoff_stage_dup;

update layoff_stage_dup set country = trim(trailing '.' from country) where country like 'united states%';

-- standardizing location column data :

select distinct location from layoff_stage_dup;

update layoff_stage_dup set location = trim(trailing '.' from location) where location like 'washington%';

UPDATE layoff_stage_dup
SET location = REGEXP_REPLACE(location, '[^a-zA-Z. ]', '');

update layoff_stage_dup set location = 'Non U.S' where location like 'NonU.S.%';
-- changing date column to date format :

update layoff_stage_dup set `date`= str_to_date(`date`,'%m/%d/%Y');

-- changing data type of date column :
alter table layoff_stage_dup modify `date` DATE;



-- Step 3: working with null and blank values :

select * from layoff_stage_dup;
select * from layoff_stage_dup where industry is null or industry ='';

update layoff_stage_dup set industry=null where industry='';

select t1.company, t1.industry,t2.industry from layoff_stage_dup t1 join layoff_stage_dup t2 
on t1.company = t2.company where (t1.industry is null ) and t2.industry is not null; 

update layoff_stage_dup t1 join layoff_stage_dup t2 on t1.company = t2.company set t1.industry=t2.industry where t1.industry is null and t2.industry is not null;



-- step 4: removing unwanted rows and columns :

select * from layoff_stage_dup where total_laid_off is null and percentage_laid_off is null ;

delete from layoff_stage_dup where total_laid_off is null and percentage_laid_off is null;

select * from layoff_stage_dup;

alter table layoff_stage_dup
drop column row_value ;


select * from layoff_stage_dup; -- final result after all data cleaning process completed
select count(*) from layoff_stage_dup; 