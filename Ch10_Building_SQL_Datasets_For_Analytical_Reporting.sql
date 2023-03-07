An experienced analyst who goes through the steps in Figure 10.1 won't only think about writing a query to answer the immediate question at hand but will think more generally about “Building Datasets for Analysis” (we're finally getting to this book's subtitle!) and designing SQL queries that combine and summarize data in a way that can then be used to answer many similar questions that might arise as offshoots of the original question.I often say in my data science conference presentations that the process depicted in Figure 10.1 is what is expected of any data analyst or data scientist: to be able to listen to a question from a business stakeholder, determine how it might be answered using data from the database, retrieve the data needed to answer it, calculate the answers, and present that result in a form that the business stakeholder can understand and use to make decisions.

Schematic illustration of business questions and the corresponding answer.

An experienced analyst who goes through the steps in Figure 10.1 won't only think about writing a query to answer the immediate question at hand but will think more generally about “Building Datasets for Analysis” (we're finally getting to this book's subtitle!) and designing SQL queries that combine and summarize data in a way that can then be used to answer many similar questions that might arise as offshoots of the original question.

 An analytical dataset is designed for use in reports and predictive models, and usually combines data from several tables summarized at a granularity (row level of detail) that lends itself to multiple analyses
 
 Because I know that the first question I'm asked to answer with an ad-hoc query is almost never the only question, I will use any remaining project time to try to anticipate follow-up questions and design a dataset that may be useful for answering them. Adding additional relevant columns or calculations to a query also makes the resulting dataset reusable for future reporting purposes.
 
 Since we're talking about summary sales and time, I would first think about all of the different time periods by which someone might want to “slice and dice” market sales. Someone could ask to summarize sales by minute, hour, day, week, month, year, and so on. Then I would think about dimensions other than time that people might want to filter or summarize sales by, such as vendor or customer zip code.
 
 Whatever granularity I choose to make the dataset (at what level of detail I choose to summarize it) dictates the lowest level of detail at which I can then filter or summarize a report based on that dataset. So, for example, if I build a dataset that summarizes the data by week, I will not be able to produce a daily sales report from that dataset, because weeks are less granular than days.
 
 Conversely, the granularity I choose means I will always need to write summary queries for any question that's at a higher level of aggregation than the dataset. For example, if I create a dataset that summarizes sales per minute, I will always have to use GROUP BY in the query, or use a reporting tool to summarize sets of rows, to answer any question that needs those minutes combined into a longer time period like hours or days.
 
 If you are developing a dataset for use in a reporting tool that makes aggregation simple, such as Tableau, you may want to keep it as granular as possible, so you can drill down to as small of a time period as is available in the data. In Tableau, measures are automatically summarized by default as you build a report, and you have to instead break down the summary measures by adding dimensions. Summarizing by date in Tableau is as simple as dragging any datetime value into a report and choosing at what timescale you want to view that date field, regardless of whether the underlying dataset has one row per day or one row per second.
 
 However, if you are primarily going to be querying the dataset with SQL, you will have to use GROUP BY and structure your queries to summarize at the desired level every time you use it to build a report. So, if you anticipate that you will frequently be summarizing by day, it would make sense to build a dataset that is already summarized to one row per day. You can always go back to the source data and write a custom query for that rare case when you're expected to report on sales per hour, but reuse the pre-summarized daily sales dataset as a shortcut for the more common report requests in this case.
 
 I will start by writing a SELECT statement that pulls only the fields I need, leaving out unnecessary information, and allowing me to summarize at the selected level of detail. I don't need to include the quantity of an item purchased in this dataset, only the final sale amount, so I'll multiply the quantity and the cost_to_customer_per_qty fields, like we did in Chapter 3, “The WHERE Clause”:

SELECT 
   
 market_date, 
   
 vendor_id, 
   
 quantity * cost_to_customer_per_qty
FROM farmers_market.customer_purchases
After reviewing the output without aggregation, to ensure that these are the fields and values I expected to see, I'll group and sort by vendor_id and market_date , SUM the calculated cost column, round it to two decimal places, and give it an alias of sales .

Another approach allows you to develop SELECT statements that depend on a custom dataset in their own SQL editor window, or inside other code such as a Python script, without first including the entire CTE. This involves storing the query as a database view. A view is treated just like a table in SQL, the only difference being that it has run when it's referenced to dynamically generate a result set (where a table stores the data instead of storing the query), so queries that reference views can take longer to run than queries that reference tables. However, the view is retrieving the latest data from the underlying tables each time it is run, so you are working with the freshest data available when you query from a view.

The last query in that chapter creates a dataset that has one row per market_date , vendor_id , and product_id , and includes information about the vendor and product, including the total inventory brought to market and the total sales for that day. This is an example of an analytical dataset that can be reused for many report variations.

Some examples of questions that could be answered with that dataset include:

What quantity of each product did each vendor sell per market/week/month/year?
When are certain products in season (most available for sale)?
What percentage of each vendor's inventory is selling per time period?
Did the prices of any products change over time?
What are the total sales per vendor for the season?
How frequently do vendors discount their product prices?
Which vendor sold the most tomatoes last week?

A partial view of the output of this query is in Figure 10.9, and you can compare the numbers to those in the bar chart in Figure 9.18. One benefit of saving queries that generate summary datasets so they are available to reuse as needed, is that any tool you use to pull the data will be referencing the underlying data, table joins, and calculated values. As long as the data isn't changing between the report generation times, everyone using the defined dataset can get the same results.
 
