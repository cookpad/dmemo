# CHANGELOG

## 0.7.0 (Not releaed)
- ignored_tables settings also ignore schema
  This is possible breaking change. Your schemas may be ignored depending on ignored_tables settings.
- Support Presto as DataSource [#112](https://github.com/hogelog/dmemo/pull/112)

## 0.6.0
- Remove sync data source feature from web setting view
- Refactoring
- Support Google BigQuery as DataSource [#106](https://github.com/hogelog/dmemo/pull/106)

## 0.5.0
- Upgrade to Rails v5.2 [#99](https://github.com/hogelog/dmemo/pull/99)
- Upgrade many dependencies
- Remove some dependencies
  - faml
  - capistrano-rails

## 0.4.0
- Remove search result number limitation
- Remove keyword name constraints

## 0.3.2
- Improve data source sync performance
- Fix table count

## 0.3.1
- Fix data source table access [#68](https://github.com/hogelog/dmemo/pull/68) reported from [@yuemori](https://github.com/yuemori)

## 0.3.0
- Keywords feature
- Autolink table name in description

## 0.2.1
- Logging data source access with tag https://github.com/hogelog/dmemo/pull/37
- Small fixes

## 0.2.0
- Ignored tables feature
- Optimize data source sync
- Cache data source access
- Introduce schema_memos
- Show all database access logs
- Check the upgrade guide: https://github.com/hogelog/dmemo/issues/30

## 0.1.5
- Favorite table feature
- Reduce data source synchronize queries

## 0.1.4
- Automated Build on Docker Hub
  - https://hub.docker.com/r/hogelog/dmemo/
