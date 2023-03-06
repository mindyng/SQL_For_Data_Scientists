A Common Pitfall when Filtering Joined Data

If you are using a LEFT JOIN because you want to return all rows from the “left” table, even those that don't have a match on the “right” side of the join, be sure not to filter on any fields from the “right” table without also allowing NULL results on the right side, or you will filter out results you intended to keep.

A Common Pitfall when Filtering Joined Data
Going back to the LEFT JOIN example between the customer and customer_purchases tables whose output is depicted in Figure 5.12, how do you think the output of the following query will differ from the original LEFT JOIN query without the added WHERE clause?
SELECT * 
FROM customer AS c
LEFT JOIN customer_purchases AS cp
   
 ON c.customer_id = cp.customer_id
WHERE cp.customer_id> 0
All customer_id values are integers above 0, so it might initially appear like the addition of this WHERE clause will make no difference in the output. However, notice that it is filtering on the customer_id on the “right side” table, customer_purchases (note the alias cp in the WHERE clause). That means that the customers without purchases will be filtered out, because they wouldn't have matching records in the customer_purchases table. The addition of this filter makes the query return results like an INNER JOIN instead of a LEFT JOIN, by filtering out records that return NULL values on the “right side” table columns in the output. So, instead of the output shown in Figure 5.12, this query's output would look like the one shown in Figure 5.14.

If you are using a LEFT JOIN because you want to return all rows from the “left” table, even those that don't have a match on the “right” side of the join, be sure not to filter on any fields from the “right” table without also allowing NULL results on the right side, or you will filter out results you intended to keep.
Let's say we want to write a query that returns a list of all customers who did not make a purchase at the March 2, 2019, farmer's market. We will use a LEFT JOIN , since we want to include the customers who have never made a purchase at any farmer's market, so wouldn't have any records in the customer_purchases table:
SELECT c.*, cp.market_date 
FROM customer AS c
LEFT JOIN customer_purchases AS cp
   
 ON c.customer_id = cp.customer_id
WHERE cp.market_date <> '2019-03-02'
Figure 5.15 displays the output we get with this query. There are multiple problems with this output.
A table records customer id, customer first name and last name, and customer zip.
Figure 5.15

The first problem is that we're missing customers who have never made a purchase, like Betty Bullard shown in Figure 5.12, since we filtered to the market_date field in the customer_purchases table, which is on the “right side” of the JOIN, and because (as shown in Chapter 3) SQL doesn't evaluate value comparisons to TRUE when one of the values being compared is NULL. But we need that filter in order to remove customers who made a purchase that day.
One solution that will allow us to filter the results returned using a field in the table on the right side of the join while still returning records that only exist in the left side table is to write the WHERE clause to allow NULL values in the field:
SELECT c.*, cp.market_date 
FROM customer AS c
LEFT JOIN customer_purchases AS cp
   
 ON c.customer_id = cp.customer_id
WHERE (cp.market_date <> '2019-03-02' OR cp.market_date IS NULL)
A table records customer id, customer first name and last name, and customer zip.
Figure 5.16

Now we see customers without purchases in Figure 5.16, like Betty Bullard, in addition to customers who have made purchases on other dates.

The second problem with this output is that it contains one row per customer per item purchased, because the customer_purchases table has a record for each item purchased, when we just wanted a list of customers. We can resolve this problem by removing the market_date field from the customer_purchases “side” of the relationship, so the purchase dates aren't displayed, then using the DISTINCT keyword, which removes duplicate records in the output, only displaying distinct (unique) results. Figure 5.17 shows the output associated with the following query:
SELECT DISTINCT c.* 
FROM customer AS c
LEFT JOIN customer_purchases AS cp
   
 ON c.customer_id = cp.customer_id
WHERE (cp.market_date <> '2019-03-02' OR cp.market_date IS NULL)
A table records customer id, customer first name and last name, and customer zip.
Figure 5.17

With this approach, we were able to filter out records we didn't want, using values on the customer_purchases side of the relationship, without excluding records we did want from the customer side of the relationship. And, we only displayed data from one of the tables, even though we were using fields from both in the query.
