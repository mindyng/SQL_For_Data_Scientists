To get back to simpler aggregate functions that use dates, we will again return to customer 1's purchase history (originally shown in Figure 8.9). Let's say that today's date is March 31, 2019, and the marketing director of the farmer's market wants to give infrequent customers an incentive to return to the market in April. The director asks you for a list of everyone who only made a purchase at one market event during the previous month, because they want to send an email to all of those customers with a coupon to receive a discount on a purchase made in April. How would you pull up that list?

Well, first we have to find everyone who made a purchase in the 31 days prior to March 31, 2019. Then, we need to filter that list to those who only made a purchase on a single market date during that time.

This query would retrieve a list of one row per market date per customer within that date range:

SELECT DISTINCT customer_id, market_date 
FROM farmers_market.customer_purchases
WHERE DATEDIFF('2019-03-31', market_date) <= 31
Then, we could query the results of that query, count the distinct market_date values per customer during that time, and filter to those with exactly one market date, using the HAVING clause (which remember is like the WHERE clause, but calculated after the GROUP BY aggregation):

SELECT x.customer_id, 
   
 COUNT(DISTINCT x.market_date) AS market_count
FROM
(
   
 SELECT DISTINCT customer_id, market_date 
   
 FROM farmers_market.customer_purchases
   
 WHERE DATEDIFF('2019-03-31', market_date) <= 31
) x
GROUP BY x.customer_id
HAVING COUNT(DISTINCT market_date) = 1
The results of this query are shown in Figure 8.15

A table records customer id and market count.
Figure 8.15

If we were actually fulfilling a report request, we would want to next join these results to the customer table to get the customer name and contact information, but here we have shown how to use date calculations to filter a list of customers by the actions they took.

