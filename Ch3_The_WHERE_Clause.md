Filtering on Multiple Conditions
You can combine multiple conditions with boolean operators, such as “ AND ,” “ OR ,” or “ AND NOT ” between them in order to filter using multiple criteria in the WHERE clause.
Clauses with OR between them will jointly evaluate to TRUE, meaning the row will be returned, if any of the clauses are TRUE. Clauses with AND between them will only evaluate to TRUE in combination if all of the clauses evaluate to TRUE. Otherwise, the row will not be returned. Remember that NOT flips the following boolean value to its opposite (TRUE becomes FALSE, and vice versa). See Table 3.2.

Table 3.2

CONDITION 1 EVALUATES TO	BOOLEAN OPERATOR	CONDITION 2 EVALUATES TO	ROW RETURNED?
TRUE	OR	FALSE	TRUE
TRUE	OR	TRUE	TRUE
FALSE	OR	FALSE	FALSE
TRUE	AND	FALSE	FALSE
TRUE	AND	TRUE	TRUE
TRUE	AND NOT	FALSE	TRUE
FALSE	AND NOT	TRUE	FALSE
FALSE	AND NOT	FALSE	FALSE
FALSE	OR NOT	FALSE	TRUE

Since the OR statement evaluates to TRUE if any of the conditions are TRUE, but the AND statement only evaluates to TRUE if all of the conditions are true, the row with a product_id value of 10 is only returned by the first query.

A Warning About Null Comparisons
You might wonder why the comparison operator IS NULL is used instead of equals NULL in the previous section. NULL is not actually a value, it's the absence of a value, so it can't be compared to any existing value. If your query were filtered to WHERE product_size = NULL , no rows would be returned, even though there is a record with a NULL product_size, because nothing “equals” NULL, even NULL.
This is important for other types of comparisons as well. Look at the following two queries and their output in Figures 3.15 and 3.16:

SELECT 
   
 market_date,
   
 transaction_time,
   
 customer_id, 
   
 vendor_id, 
   
 quantity
FROM farmers_market.customer_purchases
WHERE 
   
 customer_id = 1
   
 AND vendor_id = 7
   
 AND quantity> 1

Figure 3.15

SELECT 
   
 market_date,
   
 transaction_time,
   
 customer_id, 
   
 vendor_id, 
   
 quantity
FROM farmers_market.customer_purchases
WHERE 
   
 customer_id = 1
   
 AND vendor_id = 7
   
 AND quantity <= 1

Figure 3.16

You might think that if you ran both of the queries, you would get all records in the database, since in one case you're looking for quantities over 1, and in the other you're looking for quantities less than or equal to 1, the combination of which appears to contain all possible values. But since NULL values aren't comparable to numbers in that way, there is a record that is never returned when there's a numeric comparison used, because it has a NULL value in the quantity field. You can see that if you run this query, which results in Figure 3.17:


SELECT 
   
 market_date,
   
 transaction_time,
   
 customer_id, 
   
 vendor_id, 
   
 quantity
FROM farmers_market.customer_purchases
WHERE 
   
 customer_id = 1
   
 AND vendor_id = 7

Figure 3.17

Ideally, the database should be designed so that the quantity value for a purchase record isn't allowed to be NULL because you can't buy a NULL number of items, but since NULL values weren't prevented, one was entered.

If you wanted to return all records that don't have NULL values in a field, you could use the condition “[field name] IS NOT NULL ” in the WHERE clause.
