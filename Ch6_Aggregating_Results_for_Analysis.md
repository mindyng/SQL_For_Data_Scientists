However, this approach would result in one row per item each customer purchased, displaying duplicates in the output, because you're querying the customer_purchases table with no grouping specified.
To instead get one row per customer per market date, you can group the results by adding a GROUP BY clause that specifies that you want to summarize the results by the customer_id and market_date fields:
SELECT 
   
 market_date, 
   
 customer_id
FROM farmers_market.customer_purchases
GROUP BY market_date, customer_id
ORDER BY market_date, customer_id
You can also accomplish the same result by using SELECT DISTINCT to remove duplicates, but here we are using GROUP BY with the intention of adding summary columns to the output.

NOTE
Note that this type of modification occurs frequently while designing reports—either by the data analyst or by the requester/customer—so it's important to understand the granularity and structure of the underlying table to ensure that your result means what you think it does. This is why I recommend writing the query without aggregation first to see the values you will be summarizing before grouping the results.

So far, we have been doing all of this aggregation on a single table, but it can be done on joined tables, as well. It's a good idea to join the tables without the aggregate functions first, to make sure the data is at the level of granularity you expect (and not generating duplicates) before adding the GROUP BY .

TIP
If you GROUP BY all of the fields that are supposed to be distinct in your resulting dataset, then add a HAVING clause that filters to aggregated rows with a COUNT(*) > 1 , any results returned indicate that there is more than one row with your “unique” combination of values, highlighting the existence of unwanted duplicates in your database or query results!



