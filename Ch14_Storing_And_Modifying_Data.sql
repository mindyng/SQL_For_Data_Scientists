We have covered many aspects of developing datasets for machine learning that involve selecting data from a database and preparing it for machine learning models, but what do you do once you have designed your query and are ready to start analyzing the results? Your SQL editor will often allow you to write the results of your query to a CSV file to be imported into Business Intelligence (BI) software such as Tableau or machine learning scripts in a language like Python. However, sometimes for data governance, data security, teamwork, or file size and processing speed purposes, it is preferable to store the dataset within the database.

In this chapter, we'll cover some types of SQL queries beyond SELECT statements, such as INSERT statements, which allow you to store the results of your query in a new table in the database.

Storing SQL Datasets as Tables and Views
In most databases, you can store the results of a query as either a table or a view. Storing results as a table takes a snapshot of whatever the results are at the time the query is run and saves the data returned as a new table object, or as new rows appended to an existing table, depending on how you write your SQL statement. A database view instead stores the SQL itself and runs it on-demand when you write a query that references the name of the view, to dynamically generate a new dataset based on the state of the referenced database objects at the time you run the query. (You may have also heard of the term materialized view, which is more like a stored snapshot and is not what I'm referring to here.)

If you have database storage space available, permissions to create tables or insert records into tables in your database, and it is not cost-prohibitive to do so, it can be good practice to store snapshots of the datasets you are using in your machine learning applications. You can check with your database administrator to determine whether you can and should create and modify tables, and which schema(s) you have permission to write to.

When you're iteratively testing various combinations of fields and parameters in your machine learning algorithm, you'll want to test multiple different approaches with the same static dataset, so you can be sure your input data isn't changing each time you run your script by writing the results to a table. You might also decide to store a copy of the dataset for later reference if the dataset you're querying could change over time and you want to keep a record of the exact values that were run through your model at the time you ran it.

One way to store the results of a query is to use a CREATE TABLE statement. The syntax is

CREATE TABLE [schema_name].[new_table_name] AS
(
   [your query here]
)
As with the SELECT statements, the indentation and line breaks in these queries don't matter to the database and are just used to format for readability. The table name used in a CREATE TABLE statement must be new and unique within the schema. If you try to run the same CREATE TABLE statement twice in a row, you will get an error stating that the table already exists.

Once you create the table, you can query it like any other table or view, referencing the new name you gave it. If you created a table by accident or want to re-create it with a different name or definition, you can DROP the table.

WARNING
Be very careful when using the DROP TABLE statement, or you might accidentally delete something that should not have been be deleted! Depending on the database settings and backup frequency, the data you delete may not be recoverable! I usually ensure that I am only granted database permissions to create and drop tables in a personal schema, which is separate from the schema used to run applications or where tables that others are using are stored, so I can't accidentally delete a table I did not create or that is used in a production application.

The syntax for dropping a table is simply:

DROP TABLE [schema_name].[table_name]
So, to create, select from, and drop a table that contains a snapshot of the data that is currently in the Farmer's Market database product table, filtered to products with a quantity type “unit,” run the following three queries in sequence:

CREATE TABLE farmers_market.product_units AS
(
   
 SELECT * 
   
 FROM farmers_market.product 
   
 WHERE product_qty_type = "unit"
)
;
   
 
SELECT * FROM farmers_market.product_units
;
   
 
DROP TABLE farmers_market.product_units
;
The semicolons are used to separate multiple queries in the same file.

TIP
If you don't want to accidentally run a DROP TABLE statement that is included in a file with other SQL statements (since many SQL editors have a “run all” command), comment it out immediately after running it, and save the file with that query commented out, so you don't accidentally run it the next time you open the file and drop a table you didn't intend to! In MySQL Workbench, you can comment out code by preceding each line with two dashes and a space or by surrounding a block of code with /* and */ .

Database views are created and dropped the same exact way as tables, though when you create a view, you are not actually storing the data, but storing the query to be run when you query the view. So when you drop a view, you are not actually deleting any data, since the data isn't stored; you are just dropping the named reference to the query:

CREATE VIEW farmers_market.product_units_vw AS
(
   
 SELECT * 
   
 FROM farmers_market.product 
   
 WHERE product_qty_type = "unit"
)
;
   
 
SELECT * FROM farmers_market.product_units_vw
;
   
 
DROP VIEW farmers_market.product_units_vw
;
Note that some database systems, like SQL Server, support a SELECT INTO syntax, which operates much like the CREATE TABLE statement previously demonstrated, and is often used to create backups of existing tables. Check your database's documentation online to determine which syntax to use.

Adding a Timestamp Column
When you create or modify a database table, you might want to keep a record of when each row in the table was created or last modified. You can do this by adding a timestamp column to your CREATE TABLE or UPDATE statement. The syntax for creating a timestamp varies by database system, but in MySQL, the function that returns the current date and time is called CURRENT_TIMESTAMP . You can give the timestamp column an alias like any calculated column.

Keep in mind that the timestamp is generated by the database server, so if the database is in another time zone, the timestamp returned by the function may be different than the current time at your physical location. Many databases use Coordinated Universal Time (UTC) as their default timestamp time, which is a global time standard that is synchronized using atomic clocks, aligns in hour offset with the Greenwich Mean Time time zone, and doesn't change for Daylight Savings Time. Eastern Standard Time, which is observed in the Eastern Time Zone in North America during the winter, can be signified as UTC-05:00, meaning it is five hours behind UTC. Eastern Daylight Time, observed during the summer, has an offset of UTC-04:00, because the Eastern Time Zone observes Daylight Savings Time and shifts by an hour, while UTC does not shift. You can see how time zone math can quickly get complicated, which is why many databases simplify by using a standard UTC clock time instead of a developer's local time.

We can modify the preceding CREATE TABLE example to include a timestamp column as follows:

CREATE TABLE farmers_market.product_units AS
(
   
 SELECT p.*,
    
   CURRENT_TIMESTAMP AS snapshot_timestamp
   
 FROM farmers_market.product AS p
   
 WHERE product_qty_type = "unit"
)
Example output from this query is shown in Figure 14.1.

A table records product id, name, size, category id, quantity type, and snapshot timestamp.
Figure 14.1

Inserting Rows and Updating Values in Database Tables
If you want to modify data in an existing database table, you can use an INSERT statement to add a new row or an UPDATE statement to modify an existing row of data in a table.

In this chapter, we're specifically inserting results of a query into another table, which is a specific kind of INSERT statement called INSERT INTO SELECT .

The syntax is

INSERT INTO [schema_name].[table_name] ([comma-separated list of column names])
[your SELECT query here]
So if we wanted to add rows to our product_units table created earlier, we would write:

INSERT INTO farmers_market.product_units (product_id, product_name, product_size, product_category_id, product_qty_type, snapshot_timestamp)
   
 SELECT 
       
 product_id, 
       
 product_name,
       
 product_size, 
       
 product_category_id, 
       
 product_qty_type,
       
 CURRENT_TIMESTAMP
   
 FROM farmers_market.product AS p
   
 WHERE product_id = 23
It is important that the columns in both queries are in the same order. The corresponding fields may not have identical names, but the system will attempt to insert the returned values from the SELECT statement in the column order listed in parentheses.

Now when we query the product_units table, we'll have a snapshot of the same product row at two different times, as shown in Figure 14.2.

A table records product id, name, size, category id, quantity type, and snapshot timestamp.
Figure 14.2

If you make a mistake when inserting a row and want to delete it, the syntax is simply

DELETE FROM [schema_name].[table_name]
WHERE [set of conditions that uniquely identifies the row]
You may want to start with SELECT * instead of DELETE so you can see what rows will be deleted before running the DELETE statement!

The product_id and snapshot_timestamp uniquely identify rows in the product_units table, so we can run the following statement to delete the row added by our previous INSERT INTO :

DELETE FROM farmers_market.product_units
WHERE product_id = 23
   
 AND snapshot_timestamp = '2021-04-18 00:49:24'
Sometimes you want to update a value in an existing row instead of inserting a totally new row. The syntax for an UPDATE statement is as follows:

UPDATE [schema_name].[table_name]
SET [column_name] = [new value]
WHERE [set of conditions that uniquely identifies the rows you want to change]
Let's say that you've already entered all of the farmer's market vendor booth assignments for the next several months, but vendor 4 informs you that they can't make it on October 10, so you decide to upgrade vendor 8 to vendor 4's booth, which is larger and closer to the entrance, for the day.

Before making any changes, let's snapshot the existing vendor booth assignments, along with the vendor name and booth type, into a new table using the following SQL:

CREATE TABLE farmers_market.vendor_booth_log AS
(
   
 SELECT vba.*, 
       
 b.booth_type, 
       
 v.vendor_name,
       
 CURRENT_TIMESTAMP AS snapshot_timestamp 
   
 FROM farmers_market.vendor_booth_assignments vba
       
 INNER JOIN farmers_market.vendor v
           
 ON vba.vendor_id = v.vendor_id
       
 INNER JOIN farmers_market.booth b
           
 ON vba.booth_number = b.booth_number
   
 WHERE market_date>= '2020-10-01'
)
Selecting all records from this new log table produces the results shown in Figure 14.3.

A table records vendor id, booth number, booth type, vendor name, and snapshot timestamp.
Figure 14.3

To update vendor 8's booth assignment, we can run the following SQL:

UPDATE farmers_market.vendor_booth_assignments
SET booth_number = 7 
WHERE vendor_id = 8 and market_date = '2020-10-10'
And we can delete vendor 4's booth assignment with the following SQL:

DELETE FROM farmers_market.vendor_booth_assignments
WHERE vendor_id = 4 and market_date = '2020-10-10'
Now, when we query the vendor_booth_assignments table, there is no record that vendor 4 had a booth assignment on that date, or that vendor 8's booth assignment used to be different. But we do have a record of the previous assignments in the vendor_booth_log we created! Now we can insert new records into the log table to record the latest changes:

INSERT INTO farmers_market.vendor_booth_log (vendor_id, booth_number, market_date, booth_type, vendor_name, snapshot_timestamp)
   
 SELECT 
       
 vba.vendor_id, 
       
 vba.booth_number, 
       
 vba.market_date,
       
 b.booth_type, 
       
 v.vendor_name,
       
 CURRENT_TIMESTAMP AS snapshot_timestamp 
   
 FROM farmers_market.vendor_booth_assignments vba
       
 INNER JOIN farmers_market.vendor v
           
 ON vba.vendor_id = v.vendor_id
       
 INNER JOIN farmers_market.booth b
           
 ON vba.booth_number = b.booth_number
   
 WHERE market_date>= '2020-10-01'
So now even though the original vendor_booth_assignments table doesn't contain the original booth assignments for these two vendors on October 10, if we had run an analysis at an earlier date and wanted to see what the database values were at that time, we could query this vendor_booth_log table to look at the values at different points time, as shown in Figure 14.4.

A table records vendor id, booth number, market date, and snapshot timestamp.
Figure 14.4

Using SQL Inside Scripts
Importing the datasets you develop into your machine learning script is beyond the scope of this book, but you can search the internet for the combination of SQL and your chosen scripting language and packages to find tutorials. For example, searching “import SQL python pandas dataframe” will lead you to tutorials for connecting to a database from within your Python script, running a SQL query, and importing the results into a pandas dataframe for analysis. You can usually either paste the SQL query into your script and store it in a string variable or reference the SQL stored in a text document.

Keep in mind that some special characters in your query will need to be “escaped.” For example, if you surround your SQL query in double quotes to store it in a string variable in Python, it will interpret any double quotes within your query as ending the string and raise an error. To use quotes inside quoted strings in Python, you can precede them with a backslash.

Representing this SQL query as a string in Python

SELECT * FROM farmers_market.product WHERE product_qty_type = "unit"
requires escaping the internal double quotes, like so:

my_query = "SELECT * FROM farmers_market.product WHERE product_qty_type = \"unit\""
This is common in programming languages where strings are surrounded by quotes, since many strings contain quotes in the enclosed text, so you can search for “string escape characters” along with your chosen machine learning script tool or language to find out how to modify your SQL for use within your script.

You can also write data from your script back to the database using SQL, but the approach varies based on the scripting language you're using and the type of database you're connecting to. In Python, for example, there are packages available to help you connect and write to a variety of databases without even needing to write dynamic SQL INSERT statements—the packages generate the SQL for you to insert values from an object in Python like a dataframe into a database table for persistent storage.

Another approach is to programmatically create a file to temporarily store your data, transfer the file to a location that is accessible from your script and your database, and load the results from the file into your table. For example, you might use Python to write data from a pandas dataframe to a CSV file, transfer the CSV file to an Amazon Web Services S3 bucket, then access the file from the database and copy the records into an existing table in a Redshift database. All of these steps can be automated from your script.

One machine learning use case for writing data from your script to the database is if you want to store your transformed dataset after you have completed feature engineering and data preprocessing steps in your script that weren't completed in the original dataset-generating SQL.

Another use case for writing values generated within your script back to the database is when you want to store the results that your predictive model generates and associate them with the original dataset. You can create a table that stores the unique identifiers for the rows in your input dataset for which you have scores, a timestamp, the name or ID of your model, and the score or classification generated by the model for each record. You can insert new rows into the table each time you refresh your model scores. Then, use a SQL query to filter this model score log table to a specific date and model identifier and join it to the table with your input dataset, joining on the unique row identifiers. This will allow you to analyze the results of the model alongside the input data used to generate the predictions at the time.

There are many ways to connect to and interact with data from a database in your other scripts that may or may not require SQL.

In Closing
Now that you know SQL basics, you should have the foundation needed to create datasets for your machine learning models, even if you need to search the internet for functions and syntax that were not covered in this book.

I have been a data scientist for five years now, and all of the queries I have written to generate my datasets for machine learning have been variations of the SQL I originally learned in school 20 years ago. I hope that this book has given you the SQL skills you need to achieve your analysis goals faster and more independently, and that you find pulling and modifying your own datasets as empowering as I do!

Exercises
If you include a CURRENT_TIMESTAMP column when you create a view, what would you expect the values of that column to be when you query the view?
Write a query to determine what the data from the vendor_booth_assignment table looked like on October 3, 2020 by querying the vendor_booth_log table created in this chapter. (Assume that records have been inserted into the log table any time changes were made to the vendor_booth_assignment table.)
