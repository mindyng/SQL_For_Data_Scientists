## UNIONs

Because I have shown two examples of UNION queries that don't actually require UNION s, I wanted to mention one case when a UNION is definitely required: when you have separate tables with the same columns, representing different time periods. This could happen, for example, when you have event logs (such as website traffic logs) that are stored across multiple files, and each file is loaded into its own table in the database. Or, the tables could be static snapshots of the same dynamic dataset from different points in time. Or, maybe the data was migrated from one system into another, and you need to pull data from tables in two different systems and combine them together into one view to see the entire history of records.

## Self-Join to Determine To-Date Maximum
A self-join in SQL is when a table is joined to itself (you can think of it like two copies of the table joined together) in order to compare rows to one another.

Let's say we wanted to show an aggregate metric changing over time, comparing each value to all previous values. One reason you might want to compare a value to all previous values is to create a “record high to-date” indicator.

We can select data from this “table” twice. The trick here is to join the table to itself using the market_date field—but we won't be using an equal sign in the join. In this case, we want to join every row to all other rows that have a date that occurred prior to the “current” row's date, so we'll use a less-than sign ( < ) in the join. I'll use an alias of cm to represent the “current market date” row (the left side of the join), and an alias of pm to represent a “previous market date” row.

NOTE
It's easy to make an error when building this kind of join, so be sure to check your results carefully to ensure you created the intended output, especially if other tables are also joined in.

We can now remove the date filter in the WHERE clause to get the previous_max_sales for each date. Additionally, we can use a CASE statement to create a flag field that indicates whether the current sales are higher than the previous maximum sales, indicating whether each row's market_date set a sales record as of that date. This query's output is displayed in Figure 11.5. Note that now that we can see the row for April 6, 2019, we can see that it is labeled as being a record sales day at the time, and its sales record is the value we saw displayed as the previous_max_sales in Figure 11.4. You can see that after a new record is set on May 29, 2019, the value in the previous_max_sales field updates to the new record value:

## Counting New vs. Returning Customers by Week

The DISTINCT has been added because there is a row in the customer_purchases table for each item purchased, and we only need one row per market_date per customer_id . You might have noticed that we didn't need a GROUP BY here. Because the window function does its own partitioning, and the DISTINCT ensures we don't return duplicate rows, no further grouping is needed. A portion of the results from the preceding query is shown in Figure 11.6. You can see that each row depicts a date that customer shopped at the farmer's market alongside the customer's first purchase date.
