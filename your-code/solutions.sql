USE publications;

/*
Challenge 1 - Most Profiting Authors
*/

SELECT * FROM sales; -- title_id, qty
SELECT * FROM authors; -- au_id
SELECT * FROM titles; -- title_id, royalty, price, advance
SELECT * FROM titleauthor; -- au_id, title_id, royaltyper


-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
SELECT 
    t.title_id,
    ta.au_id,
    (t.advance * ta.royaltyper / 100) AS advance,
    (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
FROM
    titles t
        INNER JOIN
    titleauthor ta ON t.title_id = ta.title_id
        INNER JOIN
    sales s ON t.title_id = s.title_id;

-- Step 2: Aggregate the total royalties for each title and author
SELECT 
    agg_royalty.title_id,
    agg_royalty.au_id,
    SUM(advance) AS total_advance,
    SUM(sales_royalty) AS total_sales_royalty
FROM
    (SELECT 
        t.title_id,
            ta.au_id,
            (t.advance * ta.royaltyper / 100) AS advance,
            (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
    FROM
        titles t
    INNER JOIN titleauthor ta ON t.title_id = ta.title_id
    INNER JOIN sales s ON t.title_id = s.title_id) agg_royalty
GROUP BY agg_royalty.title_id , agg_royalty.au_id;

-- Step 3: Calculate the total profits of each author
SELECT 
    total_profits.au_id,
    ROUND(SUM(total_profits.total_advance + total_profits.total_sales_royalty),
            2) AS profit_per_author
FROM
    (SELECT 
        agg_royalty.title_id,
            agg_royalty.au_id,
            SUM(agg_royalty.advance) AS total_advance,
            SUM(agg_royalty.sales_royalty) AS total_sales_royalty
    FROM
        (SELECT 
        t.title_id,
            ta.au_id,
            (t.advance * ta.royaltyper / 100) AS advance,
            (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
    FROM
        titles t
    INNER JOIN titleauthor ta ON t.title_id = ta.title_id
    INNER JOIN sales s ON t.title_id = s.title_id) agg_royalty
    GROUP BY agg_royalty.title_id , agg_royalty.au_id) total_profits
GROUP BY total_profits.au_id
ORDER BY profit_per_author DESC
LIMIT 3;

/*
Challenge 2 - Alternative Solution
*/
DROP TABLE royal_agg;
CREATE TEMPORARY TABLE royal_agg
SELECT 
    t.title_id,
    ta.au_id,
    (t.advance * ta.royaltyper / 100) AS advance,
    (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
FROM
    titles t
        INNER JOIN
    titleauthor ta ON t.title_id = ta.title_id
        INNER JOIN
    sales s ON t.title_id = s.title_id;
   
-- Check the first table
SELECT * FROM royal_agg;

DROP TABLE total_profits;
CREATE TEMPORARY TABLE total_profits
SELECT ra.title_id, ra.au_id, SUM(ra.advance) AS total_advance, SUM(ra.sales_royalty) AS sales_royalty 
FROM royal_agg ra
GROUP BY ra.title_id, ra.au_id;

-- Check the second table
SELECT * FROM total_profits;

-- Create the final table
SELECT 
    tp.au_id,
    ROUND(SUM(tp.total_advance + tp.sales_royalty),
            2) AS total_revenue
FROM
    total_profits tp
GROUP BY tp.au_id
ORDER BY total_revenue DESC
LIMIT 3;

/*
Challenge 3
*/
-- Creating the temporary table that will turn into a permanent table
DROP TABLE profitable_authors;
CREATE TEMPORARY TABLE profitable_authors
SELECT 
    tp.au_id,
    ROUND(SUM(tp.total_advance + tp.sales_royalty),
            2) AS total_revenue
FROM
    total_profits tp
GROUP BY tp.au_id
ORDER BY total_revenue DESC
LIMIT 3;


DROP TABLE most_profiting_authors;
CREATE TABLE most_profiting_authors
SELECT * FROM profitable_authors;

SELECT * FROM most_profiting_authors;

