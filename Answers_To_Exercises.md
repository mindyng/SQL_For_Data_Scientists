APPENDIX
Answers to Exercises
Chapter 1: Data Sources
Answers
If the “Author Full Name” field is updated (overwritten) in the existing Authors table record for the author, then when a query is run to retrieve a list of authors and their books, all past books associated with the author will now be associated with the author's new name in the database, even if that wasn't the name printed on the cover of the book.
If instead a new row is added to the Authors table to record the new name (leaving the existing books associated with the prior name), then there might be no way to know that the two authors, who now have different Author IDs, are actually the same person.

There are solutions to this problem that include designing the database tables and relationships to allow multiple names per Author ID, with start and stop dates, or adding a field to the Authors table such as “prior Author ID” that associates an Authors table record with another record in the same table, if one exists.

Understanding these relationships and when and how data is updated in the database you're querying is important for understanding and explaining the results of your queries.

One example might be tracking personal exercise routines. You could have a table of workout sessions and a table of exercises, which would be a many to many relationship: each workout could contain multiple exercises, and each exercise could be part of multiple workouts. If you included a table of workout session locations, that could be designed as a “one to many” relationship with the workout sessions table, assuming each workout could only take place in one location (say, at home or at the gym), but each location could be the site of many workout sessions.
Chapter 2: The SELECT Statement
Answers
This query returns everything in the customer table:
SELECT * FROM farmers_market.customer
This query displays all of the columns and 10 rows from the customer table, sorted by customer_last_name , then customer_first_name :
SELECT *
FROM farmers_market.customer
ORDER BY customer_last_name, customer_first_name
LIMIT 10
This query lists all customer IDs and first names in the customer table, sorted by first_name :
SELECT 
   
 customer_id, 
   
 customer_first_name
FROM farmers_market.customer
ORDER BY customer_first_name
Chapter 3: The WHERE Clause
Answers
There are multiple answers to most SQL questions, but here are some possible solutions for the exercises in Chapter 3:

Remember that even though the English phrasing is “product ids 4 and 9,” using AND between the conditions in the query will not return any results, because there is only one product_id per customer_purchase . Use an OR between the conditions in the WHERE clause to return every row that has a product_id of either 4 or 9:
SELECT *
FROM farmers_market.customer_purchases 
WHERE product_id = 4 
   
 OR product_id = 9
Note that the first query uses >= and <= to establish the inclusive range, while the second query uses BETWEEN to achieve the same result:
SELECT *
FROM farmers_market.customer_purchases 
WHERE vendor_id>= 8 
   
 AND vendor_id <= 10
   
 
SELECT *
FROM farmers_market.customer_purchases 
WHERE vendor_id BETWEEN 8 AND 10
One approach is to filter to market dates that are not in the “rainy dates” list, by using the NOT operator to negate the IN condition. This will return TRUE for the rows in the customer_purchases table with a market_date that is NOT IN the query in the WHERE clause:
SELECT 
   
 market_date, 
   
 customer_id, 
   
 vendor_id, 
   
 quantity * cost_to_customer_per_qty AS price
FROM farmers_market.customer_purchases
WHERE 
   
 market_date NOT IN
   
 (
   
 SELECT market_date
   
 FROM farmers_market.market_date_info
   
 WHERE market_rain_flag = 1
   
 )
Another option is to keep the IN condition but change the query in the WHERE clause to return dates where it was not raining, when market_rain_flag is set to 0:

SELECT 
   
 market_date, 
   
 customer_id, 
   
 vendor_id, 
   
 quantity * cost_to_customer_per_qty AS price
FROM farmers_market.customer_purchases

WHERE 
   
 market_date IN
   
 (
   
 SELECT market_date
   
 FROM farmers_market.market_date_info
   
 WHERE market_rain_flag = 0
   
 )
Chapter 4: CASE Statements
Answers
Look back at Figure 2.1 for sample data and column names for the product table referenced in this exercise. This query outputs the product_id and product_name columns from product , with a column called prod_qty_type_condensed that displays the word “unit” if the product_qty_type is “unit,” and otherwise displays the word “bulk”:
SELECT 
   
 product_id,
   
 product_name,
   
 CASE WHEN product_qty_type = "Unit" 
      
 THEN "unit"
      
 ELSE "bulk"
   
 END AS prod_qty_type_condensed
   
 FROM farmers_market.product
To add a column to the previous query called pepper_flag that outputs a 1 if the product_name contains the word “pepper” (regardless of capitalization), and otherwise outputs 0, do the following:
SELECT 
   
 product_id,
   
 product_name,
   
 CASE WHEN product_qty_type = "Unit" 
      
 THEN "per unit"
      
 ELSE "bulk"
   
 END AS prod_qty_type_condensed,
   
 CASE WHEN LOWER(product_name) LIKE '%pepper%'
      
 THEN 1
      
 ELSE 0
   
 END AS pepper_flag
   
 FROM farmers_market.product
If the product name doesn't include the word “pepper,” spelled exactly that way, it won't be flagged. For example, a product might only be labeled as “Jalapeno” instead of Jalapeno pepper.
Chapter 5: SQL JOINs
Answers
This query INNER JOINs the vendor table to the vendor_booth_assignments table and sorts the result by vendor_name , then market_date :
SELECT *
FROM vendor AS v 
   
 INNER JOIN vendor_booth_assignments AS vba
      
 ON v.vendor_id = vba.vendor_id
ORDER BY v.vendor_name, vba.market_date
The following query uses a LEFT JOIN to produce output identical to the output of this exercise's query:
SELECT c.*, cp.* 
FROM customer_purchases AS cp
   
 LEFT JOIN customer AS c
      
 ON cp.customer_id = c.customer_id
This could have been written with SELECT * and be considered correct. Using the table aliases in this way allows you to control which table's columns are displayed first, so in addition to returning the same data, it's also returned with the same column order as the given query.

One approach is to INNER JOIN the product table and the product_category table, to get the category of every product (a new category with no products in it yet wouldn't need to be included here, and there shouldn't be any products without categories), then LEFT JOIN the vendor_inventory table to the product table. I chose a LEFT JOIN instead of an INNER JOIN because we might want to know if products exist in the database that are never in season because they have never been offered by a vendor at the farmer's market. There are acceptable answers that include all types of JOINs, as long as the reason for each choice is explained.
Because we haven't learned about aggregation (summarization) yet, the dataset you can create using the information included in this chapter will have one row per product per vendor who offered it per market date it was offered, labeled with the product category. Because the vendor_inventory table includes the date the product was offered for sale, you could sort by product_category , product , and market_date , and scroll through the query results to determine when each type of item is in season.

Chapter 6: Aggregating Results for Analysis
Answers
This query determines how many times each vendor has rented a booth at the farmer's market:
SELECT 
   
 vendor_id,
   
 count(*) AS count_of_booth_assignments
FROM farmers_market.vendor_booth_assignments
GROUP BY vendor_id
This query displays the product category name, product name, earliest date available, and latest date available for every product in the “Fresh Fruits & Vegetables” product category:
SELECT 
   
 pc.product_category_name,
   
 p.product_name,
   
 min(market_date) AS first_date_available,
   
 max(market_date) AS last_date_available
FROM farmers_market.vendor_inventory vi
   
 INNER JOIN farmers_market.product p
      
 ON vi.product_id = p.product_id
   
 INNER JOIN farmers_market.product_category pc
      
 ON p.product_category_id = pc.product_category_id
WHERE product_category_name = 'Fresh Fruits & Vegetables'
This query joins two tables, uses an aggregate function, and uses the HAVING keyword to generate a list of customers who have spent more than $50, sorted by last name, then first name:
SELECT 
   
 cp.customer_id,
   
 c.customer_first_name,
   
 c.customer_last_name,
   
 SUM(quantity * cost_to_customer_per_qty) AS total_spent
FROM farmers_market.customer c
   
 LEFT JOIN farmers_market.customer_purchases cp
      
 ON c.customer_id = cp.customer_id
GROUP BY 
   
 cp.customer_id,
   
 c.customer_first_name,
   
 c.customer_last_name
HAVING total_spent> 50
ORDER BY c.customer_last_name, c.customer_first_name
Chapter 7: Window Functions and Subqueries
Answers
Here are the answers to the two parts of this exercise:
These queries use DENSE_RANK() or ROW_NUMBER() to select from the customer_purchases table and numbers each customer's visits to the Farmer's Market using DENSE_RANK() :
select cp.*,
   
 DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY market_date) AS visit_number
FROM farmers_market.customer_purchases AS cp
ORDER BY customer_id, market_date
or
select customer_id, market_date, 
   
 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS visit_number
FROM farmers_market.customer_purchases
GROUP BY customer_id, market_date
ORDER BY customer_id, market_date
This is how to reverse the numbering of the preceding query so each customer's most recent visit is labeled 1, and then use another query to filter the results to only the customer's most recent visit:
SELECT * FROM
(
   
 select customer_id, market_date, 
   
 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date DESC) AS visit_number
   
 FROM farmers_market.customer_purchases
   
 GROUP BY customer_id, market_date
   
 ORDER BY customer_id, market_date
) x
where x.visit_number = 1
Or

SELECT * FROM
(
select cp.*,
   
 DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY market_date DESC) AS visit_number
FROM farmers_market.customer_purchases AS cp
ORDER BY customer_id, market_date
) x
where x.visit_number = 1
Here's how to use a COUNT() window function and include a value along with each row of the customer_purchases table that indicates how many different times that customer has purchased that product_id :
select cp.*,
   
 COUNT(product_id) OVER (PARTITION BY customer_id, product_id) AS product_purchase_count
FROM farmers_market.customer_purchases AS cp
ORDER BY customer_id, product_id, market_date
If you swap out LEAD for LAG , you're looking at the next row instead of the previous, so to get the same output, you just have to sort market_date in descending order, so everything is reversed!
SELECT 
   
 market_date, 
   
 SUM(quantity * cost_to_customer_per_qty) AS market_date_total_sales,
   
 LEAD(SUM(quantity * cost_to_customer_per_qty), 1) OVER (ORDER BY market_date DESC) AS previous_market_date_total_sales
FROM farmers_market.customer_purchases
GROUP BY market_date
ORDER BY market_date
Chapter 8: Date and Time Functions
Answers
Here is how to get the customer_id , month, and year (in separate columns) of every purchase in the farmers_market.customer_purchases table:
 SELECT customer_id,
   
 EXTRACT(MONTH FROM market_date) AS purchase_month,
   
 EXTRACT(YEAR FROM market_date) AS purchase_year
   
 FROM farmers_market.customer_purchases
Here is an example of filtering and summing purchases made in the past two weeks.
Using March 31, 2019 as the reference date:

SELECT MIN(market_date) AS sales_since:date, 
   
 SUM(quantity * cost_to_customer_per_qty) AS total_sales
FROM farmers_market.customer_purchases
WHERE DATEDIFF('2019-03-31', market_date) <= 14
Using CURDATE() , which will result in NULL results on the sample database, since all dates are more than two weeks ago:

SELECT MIN(market_date) AS sales_since:date, 
   
 SUM(quantity * cost_to_customer_per_qty) AS total_sales
FROM farmers_market.customer_purchases
WHERE DATEDIFF(CURDATE(), market_date) <= 14
This is an example of using a quality control query to check manually entered data for correctness:
SELECT 
   
 market_date, 
   
 market_day, 
   
 DAYNAME(market_date) AS calculated_market_day,
   
 CASE WHEN market_day <> DAYNAME(market_date) then "INCORRECT"
      
 ELSE "CORRECT" END AS entered_correctly
FROM farmers_market.market_date_info
Chapter 9: Exploratory Data Analysis with SQL
Answers
The following query gets the earliest and latest dates in the customer_purchases table:
SELECT MIN(market_date), MAX(market_date)
FROM farmers_market.customer_purchases
Here is how to use the DAYNAME() and EXTRACT() functions to select and group by the weekday and hour of the day, and count the distinct number of customers during each hour of the Wednesday and Saturday markets:
SELECT DAYNAME(market_date), 
   
 EXTRACT(HOUR FROM transaction_time), 
   
 COUNT(DISTINCT customer_id)
FROM farmers_market.customer_purchases
GROUP BY DAYNAME(market_date), EXTRACT(HOUR FROM transaction_time)
ORDER BY DAYNAME(market_date), EXTRACT(HOUR FROM transaction_time)
A variety of answers would be acceptable. Two examples are shown here.
How many customers made purchases at each market?

SELECT market_date, COUNT(DISTINCT customer_id)
FROM customer_purchases
GROUP BY market_date
ORDER BY market_date
What is the total value of the inventory each vendor brought to each market?

SELECT market_date, vendor_id,
   
 ROUND(SUM(quantity * original_price),2) AS inventory_value 
FROM vendor_inventory
GROUP BY market_date, vendor_id
ORDER BY market_date, vendor_id
Chapter 10: Building SQL Datasets for Analytical Reporting
Answers
Sales per vendor per market week:
SELECT market_week, vendor_id, vendor_name, 
   
 SUM(sales) AS weekly_sales
FROM farmers_market.vw_sales_by_day_vendor AS s
GROUP BY market_week, vendor_id, vendor_name
ORDER BY market_date
Subquery rewritten using a WITH clause:
WITH x AS
(
SELECT 
   
 market_date, 
   
 vendor_id,
   
 booth_number,
   
 LAG(booth_number,1) OVER (PARTITION BY vendor_id ORDER BY market_date, vendor_id) AS previous_booth_number
FROM farmers_market.vendor_booth_assignments
ORDER BY market_date, vendor_id, booth_number
)
   
 
SELECT * 
FROM x
WHERE 
   
 x.market_date = '2020-03-13' 
   
 AND 
   
 (x.booth_number <> x.previous_booth_number
   
 OR x.previous_booth_number IS NULL)
There is one vendor booth assignment per vendor per market date, so we don't need to change the granularity of our dataset in order to summarize by booth type, but we do need to pull that booth type into the dataset. We can accomplish that by LEFT JOIN ing in the vendor_booth_assignments and booth tables, and including the booth_number and booth_type columns in our SELECT statement:
SELECT 
   
 cp.market_date,
   
 md.market_day,
   
 md.market_week,
   
 md.market_year,
   
 cp.vendor_id, 
   
 v.vendor_name,
   
 v.vendor_type,
   
 vba.booth_number,
   
 b.booth_type,
   
 ROUND(SUM(cp.quantity * cp.cost_to_customer_per_qty),2) AS sales
FROM farmers_market.customer_purchases AS cp
   
 LEFT JOIN farmers_market.market_date_info AS md
      
 ON cp.market_date = md.market_date
   
 LEFT JOIN farmers_market.vendor AS v
      
 ON cp.vendor_id = v.vendor_id
   
 LEFT JOIN farmers_market.vendor_booth_assignments AS vba
      
 ON cp.vendor_id = vba.vendor_id
   
 AND cp.market_date = vba.market_date
   
 LEFT JOIN farmers_market.booth AS b
      
 ON vba.booth_number = b.booth_number
GROUP BY cp.market_date, cp.vendor_id
ORDER BY cp.market_date, cp.vendor_id
Chapter 11: More Advanced Query Structures
Answers
There are multiple possible solutions. Here is one:
WITH 
sales_per_market_date AS
(
   
 SELECT 
   
 market_date, 
   
 ROUND(SUM(quantity * cost_to_customer_per_qty),2) AS sales
   
 FROM farmers_market.customer_purchases
   
 GROUP BY market_date
   
 ORDER BY market_date
),
record_sales_per_market_date AS
(
   
 SELECT 
   
 cm.market_date,
   
 cm.sales,

 MAX(pm.sales) AS previous_max_sales,
   
 CASE WHEN cm.sales> MAX(pm.sales)
      
 THEN "YES"
      
 ELSE "NO"
   
 END sales_record_set
   
 FROM sales_per_market_date AS cm
   
 LEFT JOIN sales_per_market_date AS pm
      
 ON pm.market_date < cm.market_date
   
 GROUP BY cm.market_date, cm.sales
)
   
 
SELECT 
   
 market_date,
   
 sales
FROM record_sales_per_market_date
WHERE sales_record_set = 'YES'
ORDER BY market_date DESC
LIMIT 1
This may be more challenging than you initially anticipated! First, we need to add vendor_id to the output and the partition in the CTE, so we are ranking the first purchase date per customer per vendor. Then, we need to count the distinct customers per market per vendor, so we add the vendor_id to the GROUP BY in the outer query, and also modify the CASE statements to use the field we have re-aliased to first_purchase_from_vendor_date :
WITH
customer_markets_vendors AS
(
   
 SELECT DISTINCT
   
 customer_id,
   
 vendor_id,
   
 market_date,
   
 MIN(market_date) OVER(PARTITION BY cp.customer_id, cp.vendor_id) AS first_purchase_from_vendor_date
   
 FROM farmers_market.customer_purchases cp
)
   
 
SELECT
   
 md.market_year,
   
 md.market_week,
   
 cmv.vendor_id,
   
 COUNT(customer_id) AS customer_visit_count,
   
 COUNT(DISTINCT customer_id) AS distinct_customer_count,
   
 COUNT(DISTINCT 
   
 CASE WHEN cmv.market_date = cmv.first_purchase_from_vendor_date 
      
 THEN customer_id 
      
 ELSE NULL 

 END) AS new_customer_count,
   
 COUNT(DISTINCT 
   
 CASE WHEN cmv.market_date = cmv.first_purchase_from_vendor_date 
      
 THEN customer_id 
      
 ELSE NULL 
   
 END) 
   
 / COUNT(DISTINCT customer_id)
   
 AS new_customer_percent
FROM customer_markets_vendors AS cmv
   
 LEFT JOIN farmers_market.market_date_info AS md
      
 ON cmv.market_date = md.market_date
GROUP BY md.market_year, md.market_week, cmv.vendor_id
ORDER BY md.market_year, md.market_week, cmv.vendor_id
Again, there are many possible solutions, but here is one where the sales per market date are ranked ascending and descending, and then the top results from each of those rankings are selected and unioned together:
WITH
sales_per_market AS
(
   
 SELECT 
   
 market_date, 
   
 ROUND(SUM(quantity * cost_to_customer_per_qty),2) AS sales
   
 FROM farmers_market.customer_purchases
   
 GROUP BY market_date
   
 ),
   
 market_dates_ranked_by_sales AS
   
 (
   
 SELECT 
   
 market_date,
   
 sales,
   
 RANK() OVER (ORDER BY sales) AS sales_rank_asc,
   
 RANK() OVER (ORDER BY sales DESC) AS sales_rank_desc
   
 FROM sales_per_market
   
 )
   
 
SELECT market_date, sales, sales_rank_desc AS sales_rank
FROM market_dates_ranked_by_sales
WHERE sales_rank_asc = 1
   
 
UNION
   
 
SELECT market_date, sales, sales_rank_desc AS sales_rank
FROM market_dates_ranked_by_sales
WHERE sales_rank_desc = 1
Chapter 12: Creating Machine Learning Datasets Using SQL
Answers
This can be accomplished by duplicating the customer_markets_attended_30days_count feature and replacing each “30” with 14:
 (SELECT COUNT(market_date) 
   
 FROM customer_markets_attended cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date < cp.market_date
   
 AND DATEDIFF(cp.market_date, cma.market_date) <= 14) AS customer_markets_attended_14days_count,
The query is already grouped by customer_id and market_date , so we just need to add a column that determines if any underlying row has an item with a price over $10, and if so, return a 1, then use the MAX function to get the highest number per group, which will be a 1 if any row met the criteria:
MAX(CASE WHEN cp.cost_to_customer_per_qty> 10 THEN 1 ELSE 0 END) purchased_item_over_10_dollars,
This is a tricky one. One way to accomplish it is to add the purchase_total per market date to the CTE, then add up all purchase_total values for dates prior to the row's market_date . Both total_spent_to_date and customer_has_spent_over_200 fields have been added to the following query, which also includes the fields from exercises 1 and 2:
WITH
customer_markets_attended AS
(
   
 SELECT 
   
 customer_id,
   
 market_date,
   
 SUM(quantity * cost_to_customer_per_qty) AS purchase_total,
   
 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS market_count
   
 FROM farmers_market.customer_purchases
   
 GROUP BY customer_id, market_date 
   
 ORDER BY customer_id, market_date
)
   
 
SELECT 
   
 cp.customer_id,
   
 cp.market_date,

 EXTRACT(MONTH FROM cp.market_date) AS market_month,
   
 SUM(cp.quantity * cp.cost_to_customer_per_qty) AS purchase_total,
   
 COUNT(DISTINCT cp.vendor_id) AS vendors_patronized,
   
 MAX(CASE WHEN cp.vendor_id = 7 THEN 1 ELSE 0 END) AS purchased_from_vendor_7,
   
 MAX(CASE WHEN cp.vendor_id = 8 THEN 1 ELSE 0 END) AS purchased_from_vendor_8,
   
 COUNT(DISTINCT cp.product_id) AS different_products_purchased,
   
 DATEDIFF(cp.market_date,
   
 (SELECT MAX(cma.market_date) 
   
 FROM customer_markets_attended AS cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date < cp.market_date
   
 GROUP BY cma.customer_id)) days_since:last_customer_market_date,
   
 (SELECT MAX(market_count) 
   
 FROM customer_markets_attended cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date <= cp.market_date) AS customer_markets_attended_count,
   
 (SELECT COUNT(market_date) 
   
 FROM customer_markets_attended cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date < cp.market_date
   
 AND DATEDIFF(cp.market_date, cma.market_date) <= 30) AS customer_markets_attended_30days_count,
   
 (SELECT COUNT(market_date) 
   
 FROM customer_markets_attended cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date < cp.market_date
   
 AND DATEDIFF(cp.market_date, cma.market_date) <= 14) AS customer_markets_attended_14days_count,
   
 MAX(CASE WHEN cp.cost_to_customer_per_qty> 10 THEN 1 ELSE 0 END) AS purchased_item_over_10_dollars,
   
 (SELECT SUM(purchase_total) 
   
 FROM customer_markets_attended cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date <= cp.market_date) AS total_spent_to_date,
   
 CASE WHEN 
   
 (SELECT SUM(purchase_total) 
   
 FROM customer_markets_attended cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date <= cp.market_date)> 200
      
 THEN 1 ELSE 0 END AS customer_has_spent_over_200,
   
 CASE WHEN
   
 DATEDIFF(
   
 (SELECT MIN(cma.market_date) 
   
 FROM customer_markets_attended AS cma
   
 WHERE cma.customer_id = cp.customer_id 
   
 AND cma.market_date> cp.market_date

 GROUP BY cma.customer_id),
   
 cp.market_date) <=30 THEN 1 ELSE 0 END AS purchased_again_within_30_days
FROM farmers_market.customer_purchases AS cp
GROUP BY cp.customer_id, cp.market_date
ORDER BY cp.customer_id, cp.market_date
Chapter 14: Storing and Modifying Data
Answers
The timestamp returned when you query the view will be the current time (on the server), because unlike with a table, the view isn't storing any data and is generating the results of the query when it is run.
There are multiple correct answers, but one approach is to filter to records prior to October 4, 2020 (so if a change was made at any time on October 3, it is retrieved), and include a window function that returns the maximum timestamp per vendor and booth pair, indicating the most recent record of each booth assignment on or before the filtered date range. Then, the results of the query are embedded inside an outer query that filters to rows in the subquery where the snapshot timestamp matches the maximum timestamp calculated in the window function:
SELECT x.* FROM
(
   
 SELECT 
   
 vendor_id, 
   
 booth_number, 
   
 market_date,
   
 snapshot_timestamp,
   
 MAX(snapshot_timestamp) OVER (PARTITION BY vendor_id, booth_number) AS max_timestamp_in_filter
   
 FROM farmers_market.vendor_booth_log
   
 WHERE DATE(snapshot_timestamp) <= '2020-10-04'
) AS x
WHERE x.snapshot_timestamp = x.max_timestamp_in_filter
