USE publications;

/*
Challenge 1 - Most Profiting Authors
*/

SELECT * FROM sales; -- title_id, qty
SELECT * FROM titles; -- title_id, royalty, price, advance
SELECT * FROM titleauthor; -- au_id, title_id, royaltyper

-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
SELECT titleauthor.au_id, titleauthor.title_id, titles.advance * titleauthor.royaltyper / 100 as advance
FROM titleauthor
JOIN titles
ON titleauthor.title_id = titles.title_id;

SELECT titleauthor.au_id, titleauthor.title_id, 
	SUM(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as sales_royalty
FROM titleauthor
JOIN sales
ON titleauthor.title_id = sales.title_id
JOIN titles
ON titleauthor.title_id = titles.title_id
GROUP BY titleauthor.au_id, titleauthor.title_id;

-- Step 2: Aggregate the total royalties for each title and author
SELECT titleauthor.au_id, titleauthor.title_id, 
	titles.advance * titleauthor.royaltyper / 100 as advance,
    royalties.sales_royalty
FROM titleauthor
JOIN titles
ON titleauthor.title_id = titles.title_id
JOIN
	(SELECT titleauthor.au_id, titleauthor.title_id, 
		SUM(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as sales_royalty
	FROM titleauthor
	JOIN sales
	ON titleauthor.title_id = sales.title_id
	JOIN titles
	ON titleauthor.title_id = titles.title_id
	GROUP BY titleauthor.au_id, titleauthor.title_id) royalties
ON titleauthor.au_id = royalties.au_id and titleauthor.title_id = royalties.title_id
GROUP BY titleauthor.au_id, titleauthor.title_id;

-- Step 3: Calculate the total profits of each author
SELECT titleauthor.au_id, titleauthor.title_id, 
	SUM(titles.advance * titleauthor.royaltyper / 100 +
    royalties.sales_royalty) as total
FROM titleauthor
JOIN titles
ON titleauthor.title_id = titles.title_id
JOIN
	(SELECT titleauthor.au_id, titleauthor.title_id, 
		SUM(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as sales_royalty
	FROM titleauthor
	JOIN sales
	ON titleauthor.title_id = sales.title_id
	JOIN titles
	ON titleauthor.title_id = titles.title_id
	GROUP BY titleauthor.au_id, titleauthor.title_id) royalties
ON titleauthor.au_id = royalties.au_id and titleauthor.title_id = royalties.title_id
GROUP BY titleauthor.au_id
ORDER BY total DESC
LIMIT 3;

/*
Challenge 2 - Alternative Solution
*/
-- Create the first temporary table
SELECT titleauthor.au_id, titleauthor.title_id, titles.advance * titleauthor.royaltyper / 100 as advance
FROM titleauthor
JOIN titles
ON titleauthor.title_id = titles.title_id;

DROP TABLE royalties;
CREATE TEMPORARY TABLE royalties
SELECT titleauthor.au_id, titleauthor.title_id, 
	SUM(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as sales_royalty
FROM titleauthor
JOIN sales
ON titleauthor.title_id = sales.title_id
JOIN titles
ON titleauthor.title_id = titles.title_id
GROUP BY titleauthor.au_id, titleauthor.title_id;

-- Create the second temporary table
DROP TABLE royalty_plus_advance;
CREATE TEMPORARY TABLE royalty_plus_advance
SELECT titleauthor.au_id, titleauthor.title_id, 
	titles.advance * titleauthor.royaltyper / 100 as advance,
    royalties.sales_royalty
FROM titleauthor
JOIN titles
ON titleauthor.title_id = titles.title_id
JOIN royalties
ON titleauthor.au_id = royalties.au_id and titleauthor.title_id = royalties.title_id
GROUP BY titleauthor.au_id, titleauthor.title_id;

-- Getting the final result
SELECT au_id, 
	SUM(advance + sales_royalty) as total
FROM royalty_plus_advance
GROUP BY au_id
ORDER BY total DESC
LIMIT 3;

/*
Challenge 3
*/
-- First create a temporary table from the table below, and then create a table from it.
DROP TABLE total;
CREATE TEMPORARY TABLE total
SELECT au_id, 
	SUM(advance + sales_royalty) as total
FROM royalty_plus_advance
GROUP BY au_id
ORDER BY total DESC
LIMIT 3;

-- Table creation
CREATE TABLE most_profiting_authors
SELECT * FROM total;