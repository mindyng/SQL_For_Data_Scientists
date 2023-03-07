Some sensible questions to ask via query are:

How large are the tables, and how far back in time does the data go?
What kind of information is available about each product and each purchase?
What is the granularity of each of these tables; what makes a row unique?
Since we'll be looking at trends over time, what kind of date and time dimensions are available, and how do the different values look when summarized over time?
How is the data in each table related to the other tables? How might we join them together to summarize the details for reporting?

Let's start with the product table first. We'll select everything in the table, to see what kind of data is in each column, but limit it to 10 rows in case it is a large table:

it appears that most of the fields are populated (there aren't a lot of NULL values). 

The product_id appears to be the primary key. What if we didn't know whether it was a unique identifier? To check to see if any two rows have the same product_id , we can write a query that groups by the product_id and returns any groups with more than one record. This isn't a guarantee that it is the primary key, but can tell you whether, at least currently, the product_id is unique per record:

SELECT product_id, count(*)
FROM farmers_market.product
GROUP BY product_id
HAVING count(*)> 1

here are no results returned, so no product_id groups have more than one row, meaning each product_id is unique, and we can say that this table has a granularity of one row per product

How many different categories are there, and what do those look like? (Group By)

How many different products are there in the catalog-like product metadata table? (Python value_counts())

Exploring Possible Column Values

And how many different quantity types are there?” which could be answered with this query using the DISTINCT keyword:

SELECT DISTINCT product_qty_type
FROM farmers_market.product

 some products have a NULL product_qty_type , so we'll have to remember that when doing any sort of filtering or calculation based on this column.
 
 We might need to ask the Director what the “original price” of an item is, but with that name, we might guess that it is the item price before any sales or special deals. And it is tracked per market date, so changes over time would be recorded.
 
  Otherwise, we can group by the fields we expect are unique and use HAVING to check whether there is more than one record with each combination, like we did previously with the product_id in the product table:

SELECT market_date, vendor_id, product_id, count(*)
FROM farmers_market.vendor_inventory
GROUP BY market_date, vendor_id, product_id
HAVING count(*)> 1
There are no combinations of these three values that occur on more than one row, so at least with the currently entered data, this combination of fields is indeed unique, and the vendor_inventory table has a granularity of one record per market date, vendor, and product. It is not visible in the version of the E-R diagram displayed in Chapter 1, but it's possible to highlight the primary key of a table in MySQL Workbench, as shown in Figure 9.7. Here, we confirm that it is a composite primary key, made up of the three fields we guessed.

Exploring Changes Over Time

SELECT min(market_date), max(market_date)
FROM farmers_market.vendor_inventory
As you can see in Figure 9.8, it looks like we have about one and a half years’ worth of records. So, if we're asked to build any kind of forecast involving an annual seasonality, we will have to explain that we have limited training data for that, since we don't have multiple complete years of seasonal trends yet. It would be good to check to see if purchases were tracked during that entire period, as well.

SELECT
EXTRACT(YEAR FROM market_date) AS market_year,
EXTRACT(MONTH FROM market_date) AS market_month,
COUNT(DISTINCT vendor_id) AS vendors_with_inventory
FROM farmers_market5.vendor_inventory
GROUP BY EXTRACT(YEAR FROM market_date), EXTRACT(MONTH FROM market_date)
ORDER BY EXTRACT(YEAR FROM market_date), EXTRACT(MONTH FROM market_date)
Since only three vendors have inventory entered into this example database, there isn't much variation seen in this output, but you can see in Figure 9.10 that there are three vendors in June through September, and two vendors per month the rest of the year. So one of the vendors (likely vendor 4, from the date ranges we saw in Figure 9.9) may be a seasonal vendor.

(We'll have to remember to check with the Director to see whether that is true, because if not, there might be an issue with the data.) These are the aspects of the data that we want to discover during EDA instead of later when we're doing analysis, so we know what to expect in the report output.

 Sorting and filtering the data different ways—by market date and time, by vendor_id , by customer_id —you can get a sense of the processes that the data represents and see if anything stands out that might be worth following up on with the subject matter experts.
 
 We can also join in additional “lookup” tables to convert the various IDs to human-readable values, pulling in the vendor name and product names.
 
 
