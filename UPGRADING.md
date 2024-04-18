# Upgrade Guide

## Upgrade to v2

Dmemo v2 stopped showing some rows of a table, and dropped related tables (`table_memo_raw_dataset*` and `masked_data`). If you want to preserve the data of the tables, please take a backup of them before upgrading.

The tables are deleted if you run `bin/docker_db_apply.sh` with an environment variable `RIDGEPOLE_DROP_TABLE=1`. You should drop the tables after deploying dmemo v2.

Dmemo v2 also deprecates SynchronizeDataSources job. Please switch to ImportDataSourceDefinitions or SynchronizeDefinitions.
