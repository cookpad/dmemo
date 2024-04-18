# CHANGELOG

## Unreleased

## 2.0.0

This release contains relatively many code changes. Please read our [upgrade guide](./UPGRADING.md) before upgrading.

- Remove search_path from where clause of SQL in adapter [#284](https://github.com/cookpad/dmemo/pull/284)
- Add log for batch [#285](https://github.com/cookpad/dmemo/pull/285)
- Improve view render peformance about raw_dataset in table memo page [#286](https://github.com/cookpad/dmemo/pull/286)
- Replace circleci with GitHub Actions [#287](https://github.com/cookpad/dmemo/pull/287) [#288](https://github.com/cookpad/dmemo/pull/288)
- Show column name when editing column memo [#291](https://github.com/cookpad/dmemo/pull/291)
- bundle update bootsnap https://github.com/cookpad/dmemo/commit/3f25f0e1b87266a8988f9af12298ccde3be2f596
- Bump nokogiri from 1.11.7 to 1.13.4 [#299](https://github.com/cookpad/dmemo/pull/299)
- Bump puma from 5.3.2 to 5.6.4 [#298](https://github.com/cookpad/dmemo/pull/298)
- Bump commonmarker from 0.22.0 to 0.23.4 [#297](https://github.com/cookpad/dmemo/pull/297)
- Use simpacker instead of Sprockets [#300](https://github.com/cookpad/dmemo/pull/300)
- Remove coveralls [#302](https://github.com/cookpad/dmemo/pull/302)
- Update badge URL [357bb92](https://github.com/cookpad/dmemo/commit/357bb92dc0db2b934883c331dd55805ce0c661fb)
- Use ECR Public to avoid rate limits on Docker Hub [ed25ba5](https://github.com/cookpad/dmemo/commit/ed25ba528be62990d6e498b15d50111e3b31d543)
- Allow DB password to be set independently [#315](https://github.com/cookpad/dmemo/pull/315) [#316](https://github.com/cookpad/dmemo/pull/316)
- Fix title element in keyword#show [#326](https://github.com/cookpad/dmemo/pull/326)
- Let rubocop search .ruby-version file [#328](https://github.com/cookpad/dmemo/pull/328)
- Remove references to old Docker repository [#331](https://github.com/cookpad/dmemo/pull/331)
- DataSource does not have db_name, but dbname [#329](https://github.com/cookpad/dmemo/pull/329)
- bin: Migrate database for testing, too [#327](https://github.com/cookpad/dmemo/pull/327)
- rubocop: Inherit rules from cookpad/styleguide and auto-correct all [#330](https://github.com/cookpad/dmemo/pull/330)
- Roll gems [#333](https://github.com/cookpad/dmemo/pull/333)
- Roll NPM packages and Node.js [#332](https://github.com/cookpad/dmemo/pull/332) [#335](https://github.com/cookpad/dmemo/pull/335)
- Add Cookpad to licensers [#334](https://github.com/cookpad/dmemo/pull/334)
- ci: Avoid running tests twice for pull requests [#336](https://github.com/cookpad/dmemo/pull/336)
- Bump follow-redirects from 1.15.5 to 1.15.6 [#337](https://github.com/cookpad/dmemo/pull/337)
- Bump webpack-dev-middleware from 7.0.0 to 7.1.1 [#338](https://github.com/cookpad/dmemo/pull/338)
- Bump express from 4.18.2 to 4.19.2 [#340](https://github.com/cookpad/dmemo/pull/340)
- **BREAKING** Remove raw datasets and masked data [#341](https://github.com/cookpad/dmemo/pull/341)
- Use pg gem directly on Redshift adapter [#342](https://github.com/cookpad/dmemo/pull/342)
- Update to Rails 7.0 [#339](https://github.com/cookpad/dmemo/pull/339)
- Upgrade Ruby to 3.1 and roll gems [#343](https://github.com/cookpad/dmemo/pull/343)
- Fix margin of search box when not logined [#344](https://github.com/cookpad/dmemo/pull/344)
- Fix finished log of ImportDataSourceDefinitions batch [#345](https://github.com/cookpad/dmemo/pull/345)
- Fix log of SynchronizeDefinitions [#346](https://github.com/cookpad/dmemo/pull/346)
- Deprecate SynchronizeDataSources [#347](https://github.com/cookpad/dmemo/pull/347)
- Lint by RuboCop [#348](https://github.com/cookpad/dmemo/pull/348)

## 1.0.0
- Modify listed item UI [#263](https://github.com/hogelog/dmemo/pull/263)
- Improve visibility in browser tab [#262](https://github.com/hogelog/dmemo/pull/262)
- Modify search result page [#268](https://github.com/hogelog/dmemo/pull/268)
- Fix a type of image_url column in User table [#271](https://github.com/hogelog/dmemo/pull/271)
- Add batch to split synchronize process [#274](https://github.com/teamdmemo/dmemo/pull/274)
- Modify config for development environment [#280](https://github.com/teamdmemo/dmemo/pull/280)
- Modify import batch to obsolate a dependency on search_path [#282](https://github.com/teamdmemo/dmemo/pull/282)

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
