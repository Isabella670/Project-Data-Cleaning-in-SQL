# SQL Project - Data Cleaning

## Introduction
Data cleaning is a crucial step in the data analysis process. It involves identifying and correcting errors and inconsistencies in data to improve its quality. In this project, I developed a protocol for cleaning databases, which is essential before performing any exploratory data analysis. This protocol was applied to a dataset of layoffs from 2022, sourced from [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022) and with [Alex Freberg's](https://www.youtube.com/watch?v=4UltKCnnnTA&list=PLUaB-1hjhk8FE_XZ87vPPSfHqb6OcM0cF&index=19) best practices guide.

## Background
The dataset used in this project contains information about layoffs from various companies around the world. Like many real-world datasets, it was not in a perfect state and required significant cleaning to ensure accurate and reliable analysis. The goal of this project was to demonstrate the process of data cleaning and to establish a reusable protocol for future projects.

## Tools I used
- **SQL:** Allowing me to query the database.

- **MySQL:** Used for executing the SQL queries and managing the database.

- **Kaggle:** Source of the dataset.

## The Analysis
In this project, we followed a structured approach to clean the data, ensuring its accuracy and reliability for subsequent analysis. The steps included:

### Check for Duplicates and Remove Any:

We identified duplicate records in the dataset and removed them to ensure that each record was unique and accurate.

### Standardize Data and Fix Errors:

We standardized the data by trimming whitespace, unifying naming conventions, and converting date fields to a standard format. This included correcting variations in company names, industry classifications, and country names.

### Look at Null Values:

We examined null values in critical columns and addressed them appropriately. Where possible, we imputed missing values based on related data. For instance, empty industry fields were filled based on the company's existing records.

### Remove Unnecessary Columns and Rows:

We removed rows and columns that were not necessary for analysis. This included deleting rows with null values in key columns such as total laid off and percentage laid off, and dropping temporary columns used during the cleaning process.

```sql
-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT * 
FROM world_layoffs.layoffs;

-- Create a staging table for data cleaning
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- Step 1: Remove Duplicates
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE;

-- Step 2: Standardize Data
-- Trim whitespace
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry names
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Step 3: Convert date column to DATE type
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 4: Handle Nulls and Blank Fields
-- Update empty industry fields based on company
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Remove rows with null values in key columns
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove temporary columns
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

## What I Learned
Through this project, I learned the importance of having a systematic approach to data cleaning. Key lessons include:

Always keep a raw copy of the original data.
Thoroughly check for and handle duplicates.
Standardize data formats to ensure consistency.
Carefully manage null values to maintain data integrity.
Document each step for reproducibility and transparency.

## Conclusions
Data cleaning is an iterative and detailed process that significantly improves the quality of the data. By establishing a protocol, we can streamline this process and ensure that our datasets are ready for meaningful analysis. This project serves as a foundation for future data cleaning tasks and highlights the importance of meticulous data preparation in any data analysis workflow.
