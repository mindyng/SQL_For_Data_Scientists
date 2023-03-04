CASE
   
 WHEN [first conditional statement] 
     
 THEN [value or calculation]
   
 WHEN [second conditional statement] 
     
 THEN [value or calculation]
   
 ELSE [value or calculation]
END

The ELSE part of the statement is optional, and that value or calculation result is returned if none of the conditional statements above it evaluate to TRUE. If the ELSE is not included and none of the WHEN conditionals evaluate to TRUE, the resulting value will be NULL.

If we only wanted existing vendor types to be labeled using this logic, we could instead use the IN keyword and explicitly list the existing vendor types we want to label with the “Fresh Produce” category. As a data analyst or data scientist building a dataset that may be refreshed as new data is added to the database, you should always consider what might happen to your transformed columns if the underlying data changes.

You may have noticed that I included “Sunday” in the OR statement, even though we said earlier that our farmer's markets currently occur on Wednesday evenings and Saturday mornings. I had decided to call the field “ weekend_flag ” instead of “saturday_flag” because when creating this example, I imagined an analytical question that could be asked: “Do farmers sell more produce at our weekend market or at our weekday market?” If the farmer's market ever changes or expands its schedule to hold a market on a Sunday, this CASE statement will still correctly flag it as a weekend market for the analysis. There is not much downside to making the field aliased “ weekend_flag ” actually mean what it's called (except for the tiny additional computation done to check the second OR condition when necessary, which is unlikely to make any noticeable difference for data on the scale most farmer's markets could collect) and planning for the future possibility of other market days when designing a dataset to answer this question.

Or, if the result needs to be numeric, a different approach is to output the bottom end of the numeric range, as shown in Figure 4.7:

SELECT 
   
 market_date, 
   
 customer_id, 
   
 vendor_id, 
   
 ROUND(quantity * cost_to_customer_per_qty, 2) AS price,
   
 CASE 
      
 WHEN quantity * cost_to_customer_per_qty < 5.00
          
 THEN 0
      
 WHEN quantity * cost_to_customer_per_qty < 10.00
          
 THEN 5
      
 WHEN quantity * cost_to_customer_per_qty < 20.00 
          
 THEN 10
      
 WHEN quantity * cost_to_customer_per_qty>= 20.00 
          
 THEN 20
  
 END AS price:bin_lower_end
FROM farmers_market.customer_purchases
LIMIT 10

One of these queries generates a new column of strings, and one generates a new column of numbers. You might actually want to include both columns in your query if you were building it to be used in a report, because the price:bin column is a more explanatory label for the bin, but will sort alphabetically instead of in bin value order. With both available to use in your report, you could use the numeric version of the column to sort the bins correctly, and the string version to label the bins.

If there is a mis-entered price, or perhaps a record of a refund, and the value in the price column turns out to be negative in one row, what do you think will happen? In the preceding queries, the first condition is “less than 5,” so negative values will end up in the “Under $5,” or 0, bin. Therefore, the name price:bin_lower_end is a misnomer, since 0 might not actually represent the lowest value possible in the first bin. It's important when writing CASE statements for analytical purposes to determine what the result will be if there end up being unexpected values in any of the referenced database fields.

If the categories represent something that can be sorted in a rank order, it might make sense to convert the string variables into numeric values that represent that rank order. For example, the vendor booths at the farmer's market are rented out at different costs, depending on their size and proximity to the entrance. These booth price levels are labeled with the letters “A,” “B,” and “C,” in order by increasing price, which could be converted into either numeric values 1, 2, 3 or the actual booth prices. The following CASE statement converts the booth price levels into numeric values, and the results are shown in Figure 4.8:

If the categories aren't necessarily in any kind of rank order, like our vendor type categories, we might use a method called “one-hot encoding.” This helps us avoid inadvertently indicating a sort order when none exists. One-hot encoding means that we create a new column representing each category, assigning it a binary value of 1 if a row falls into that category, and a 0 otherwise. These columns are sometimes called “dummy variables.” The following CASE statement one-hot encodes our vendor type categories, and the results are demonstrated in Figure 4.9:

A situation to be aware of when manually encoding one-hot categorical variables this way is that if a new category is added (a new type of vendor in this case), there will be no column in your dataset for the new vendor type until you add another CASE statement.

