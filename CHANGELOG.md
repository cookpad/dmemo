# CHANGELOG

## Unreleased
- Modify listed item UI [#263](https://github.com/hogelog/dmemo/pull/263)
- Improve visibility in browser tab [#262](https://github.com/hogelog/dmemo/pull/262)
## 0.8.1
- Upgrade gems not versioned in Gemfile [#252](https://github.com/hogelog/dmemo/pull/252)
- Support Omniauth v2 [#256](https://github.com/hogelog/dmemo/pull/256)
- Upgrade to Ruby v3.0.0 and Rails v6.1.3 [#253](https://github.com/hogelog/dmemo/pull/253)
- Fix SQL to get raw data from Redshift Spectrum [#258](https://github.com/hogelog/dmemo/pull/258)

## 0.8.0
- Use INFORMATION_SCHEMA system table in mysql2 adapter to count rows [#114](https://github.com/hogelog/dmemo/pull/114)
- Support Spectrum schema of AWS Redshift [#117](https://github.com/hogelog/dmemo/pull/117)
- Support late binding view of AWS Redshfit [#118](https://github.com/hogelog/dmemo/pull/118)
- Upgrade to Ruby v2.6.2 and Debian Stretch

## 0.7.0
- ignored_tables settings also ignore schema
  - This is possible breaking change. Your schemas may be ignored depending on ignored_tables settings.
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
