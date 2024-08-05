-- SQL Project - Data Cleaning

-- Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- View the original data
SELECT * 
FROM world_layoffs.layoffs;

-- Create a staging table to work on and preserve the raw data
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- Step 1: Remove Duplicates

-- Check for duplicates
SELECT company, industry, total_laid_off, `date`,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, `date`
       ) AS row_num
FROM world_layoffs.layoffs_staging;

-- Identify duplicates
SELECT *
FROM (
    SELECT company, industry, total_laid_off, `date`,
           ROW_NUMBER() OVER (
               PARTITION BY company, industry, total_laid_off, `date`
           ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- Confirm duplicates for specific cases (e.g., 'Oda')
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Oda';

-- Remove duplicates
WITH DELETE_CTE AS (
    SELECT *
    FROM (
        SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
               ROW_NUMBER() OVER (
                   PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
               ) AS row_num
        FROM world_layoffs.layoffs_staging
    ) duplicates
    WHERE row_num > 1
)
DELETE FROM DELETE_CTE;

-- Step 2: Standardize Data

-- Trim whitespace in 'company' column
UPDATE world_layoffs.layoffs_staging
SET company = TRIM(company);

-- Standardize 'industry' column values
UPDATE world_layoffs.layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize 'country' column values
UPDATE world_layoffs.layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert 'date' column to DATE format
UPDATE world_layoffs.layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE world_layoffs.layoffs_staging
MODIFY COLUMN `date` DATE;

-- Step 3: Handle Null Values

-- Update empty 'industry' fields based on company
UPDATE world_layoffs.layoffs_staging t1
JOIN world_layoffs.layoffs_staging t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL OR t1.industry = '';

-- Remove rows with null values in key columns
DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Step 4: Remove Unnecessary Columns and Rows

-- Verify and clean the staging table
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company LIKE 'Belly%';

-- Remove the 'row_num' column if it was added previously
ALTER TABLE world_layoffs.layoffs_staging
DROP COLUMN row_num;
