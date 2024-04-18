# Batch Jobs

Schemas, tables, and columns can be imported using `ImportDataSourceDefinition` job. Please run the job periodically.
Note that only linked schemas are imported by the job. The settings can be configured by admins.

```console
$ bundle exec rails runner 'ImportDataSourceDefinitions.run("DWH”)'
$ # If you want to import just a specific table:
$ bundle exec rails runner 'ImportTableDefinitions.run("DWH", “sample_schema", “target_table”)'
$ # Or if you want to import all schemas:
$ bundle exec rails runner 'SynchronizeDefinitions.run'
```
