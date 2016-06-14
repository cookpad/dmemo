#!/bin/sh

export RAILS_ENV=production
cd /app/db && exec bundle exec ridgepole -c ../config/database.yml -E production --file Schemafile -a --dry-run
