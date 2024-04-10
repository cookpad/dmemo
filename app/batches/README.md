# Batch Jobs

For synchronization of database information from data source.  
The behavior differs greatly depending on whether you use SynchronizeDataSources or not.  
All batches except SynchronizeDataSources are new beta batches added to improve batch operations.

## SynchronizeDataSources

Synchronize all data from all data sources.  
IgnoredTables and MskedData will work. 
If the number of schemas and tables to be synchronized is large, it will take a long time to synchronize.  
Until v0.8.1, the target schema was dependent on the search_path in PostgreSQL and Redshift. Starting from the next version, search_path will no longer be used. Synchronize all visible schemas by a user account of Dmemo access.


## Import Batches

This is a new batch that replaces SynchronizeDataSources. New batches have been created to reduce the time spent on fetching and to make it easier to manage the schemas to be fetched.  
**This is a beta version and is currently in trial.**  
IgnoredTables and MskedData work. Only schemas that have SchemaMemo and are linked in Dmemo will be imported.  
If you don't want to include them, the Dmemo administrator can edit the DataSource and unlink it.  
Since we have created batches for each granularity, we need to specify the target with an argument for each granularity.  

### For Examples
```
$bundle exec rails runner 'ImportDataSourceDefinitions.run("DWH”)’

$bundle exec rails runner 'ImportTableDefinitions.run("DWH", “sample_schema", “target_table”)'
```

## SynchronizeDefinitions

Run `ImportDataSourceDefinitions` for all data sources.
