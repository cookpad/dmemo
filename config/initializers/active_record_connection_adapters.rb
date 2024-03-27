# This file explicitly requires the connection adapter for mysql2 to ensure that every adapter is loaded before the app launch.
# This helps database_rewinder's monkey patch, which assumes that basic adapters are loaded before the patch is applied.
# https://github.com/amatsuda/database_rewinder/blob/v1.0.1/lib/database_rewinder/active_record_monkey.rb#L35-L36
#
# Without this, database_rewinder prepends its monkey-patch module to AbstractMysqlAdapter instead of Mysql2Adapter
# when testing, and that causes ArgumentError (wrong number of arguments) because parameters of AbstractMysqlAdapter#execute
# are different from those of Mysql2Adapter#execute (at least with activerecord 7.0).
require "active_record/connection_adapters/mysql2_adapter"
