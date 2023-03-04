Evaluating Query Output

When you are developing a SQL SELECT statement, how do you know if the result will include the rows and columns you expect, in the form you expect?

As previously demonstrated, one method is to run the query with a LIMIT each time you make a modification. This gives a quick preview of the first x number of rows to ensure the changes you expect to see are returned, and you can inspect the column names and format of a few output values to verify that they look the way you intended.

However, you still might want to confirm how many rows would have been returned if you hadn't placed the LIMIT on the results. Similarly, there's the concern that your function might not perform as expected on some values that didn't appear in your limited results preview.

I therefore use the query editor to help me review the results of my query a bit further. This method doesn't provide a full quality control of the output (which should be done before putting any query into production), but it can give me a sanity check that the output looks correct enough for me to continue on with my work. To demonstrate, we'll use the “rounded price” query from the earlier “More Inline Calculation Examples: Rounding” section.

First, I remove the LIMIT . Note that your query editor might have a built-in limit (such as 2000 rows) to prevent you from generating a gigantic dataset by accident, so you might need to go into the settings and turn off any pre-set row limits to actually return the full dataset. Figure 2.15 shows the “Don't Limit” option available in MySQL Workbench, under the Query menu.

Then, I'll run the query to generate the output for inspection:

SELECT 
    
 market_date, 
    
 customer_id, 
    
 vendor_id, 
    
ROUND(quantity * cost_to_customer_per_qty, 2) AS price 
FROM farmers_market.customer_purchases

Figure 2.15

The first thing I'll look at in the output is the total count of rows returned, to see if it matches my expectations. This is often displayed at the bottom of the results window or in the output window. In this prototype version of the Farmer's Market database, there are only 21 rows in the customer_purchases table, which is indicated in the Message column of the Output section of MySQL Workbench, shown in the lower right of Figure 2.16. (Note that there will be more rows when you run this query yourself, after a more realistic volume of data has been added to the database).

Next, I'll look at the resulting dataset that was generated (which is called the “Result Grid” in MySQL Workbench). I check the column headers, to see if I need to change any aliases. Then, I scroll through and spot-check a few of the values in the output, looking for anything that stands out as incorrect or surprising. If I included an ORDER BY clause (which I did not in this case), I'll also ensure the results are sorted the way I intended.

Then, I can use the editor to manually sort each column first in one direction and then the other. For example, Figures 2.17 and 2.18 show the query results manually sorted in the Result Grid by market_date and vendor_id , respectively. This allows me to look at the minimum and maximum values in each, because that's often where “edge cases” exist, such as unexpected NULLs, strings that start with spaces or numbers, or data entry or calculation errors that increase numeric values by a large factor. I can explore anything that looks strange, and I might also spot if there is an unusual value present, because series of frequent values will appear side by side in the sorted results, making both frequent and unique values noticeable as you scroll down the sorted column.


Figure 2.16


Figure 2.17

In Chapter 6, you will learn about aggregate queries, which will provide more options for inspecting your results, but these are a few simple steps you can take, without writing a more complicated query, to make sure your output looks sensible.

