Asking Questions About the Data Source
Once you find out what type of data source you're working with and learn about the schema design and the relationships between the database tables, there is still a lot of information you should gather about the tables you'll be querying before you dive into writing any SQL.

If you are lucky enough to have access to subject matter experts (SMEs) who know the details of why the database was designed the way it is, how the data is collected and updated, and what to expect in terms of the frequency and types of data that may be updating as you work with the database, stay in communication with them throughout the data exploration and query development process. These might be database administrators (DBAs), ETL engineers (the people who extract, transform, and load data from a source system into a data warehouse), or the people who actually generate or enter the data into the source system in the first place. If you spot some values that don't seem to make sense, you can sometimes look in a data dictionary to learn more (if one exists and is correct), but often going directly to the SMEs to get the details is the best approach. If your questions are easily answered by existing documentation, they will point you to it!

Here are some example questions you might want to ask the SMEs as you're first learning about the data source:

“Here are the questions I'm being asked to answer in my analysis. Which tables in this database should I look in first for the relevant data? And is there an entity-relationship diagram documenting the relationships between them that I can reference?”
These questions are especially helpful for large data warehouses with a lot of tables, where being pointed in the right direction from the start can save a lot of time searching for the data you need.

“What set of fields make up the primary key for this table?” Or, “What is the grain of this fact table?”
Understanding the level of detail of each table is important in order to know how to filter, group, and summarize the data in the table, and join it to other tables.

“Are these records imported directly from the source system, or have they been transformed or merged in some way before being stored in this table?”
This is helpful to know when debugging data that doesn't look like you expected. If the database is “raw” data from the source system, you might talk to those entering the data to learn more about it. If it has gone through a transformation or includes data from several different tables in the system of origin, then the first stop to understand a value would likely be the ETL engineers who programmed the code that modified it.

“Is this a static snapshot table, or does it update regularly? At what frequency does it update? And are older records expired and kept as new data is added, or is the existing record overwritten when changes occur?”
If a table you're querying contains “live” data that is being updated as you work, and you are using it to perform calculations or as an input to a machine learning algorithm, you may want to make a copy of it to use while working. That way, you know that changes in the calculations or model output are due to changes in your code, and not due to data that is changing as you debug.

For datasets updated on a nightly basis, you might want to know what time they refresh, so you can schedule other things that depend on it, like an extract refresh, to occur after the table gets the latest data.

If old records are maintained in the table as a log, you can use the expiration date to filter out old records if you only want the latest ones, or keep past records if you're reporting on historical trends.

“Is this data collected automatically as events occur, or are the values entered by people? Do we have documentation on the interface that they can see with the data entry form field labels?”
Data entered by people may be more prone to error because of manual entry, but the people doing the data entry are often extremely valuable to talk to if you want to understand the business processes that generated the data. You can ask them why certain values were selected, what might trigger an update of a record, or what automated processes are kicked off when they make a change or process a batch.

It's a good idea to check to see how the values in each field are distributed: What is the range of possible values? If a column contains categorical values, how many rows fall into each category? If the column contains continuous or discrete numeric values, what is the shape of the statistical distribution? I find that it helps to visualize the data at this exploratory stage, called Exploratory Data Analysis (EDA). Histograms are especially useful for this purpose.

Additionally, you might explore the data broken down by time period (such as by fiscal year) to see if those distributions change over time. If you find that they do, you may find out by talking to the SMEs that there is a point at which old records stop being updated, a business process changed, or past values get zeroed out in certain cases, for example.

Knowing how their data entry forms look can also help with communication with SMEs about the data, because they may not know the field names in the underlying database but will be able to describe the data using the labels they can see on the front-end interface.
