#!/bin/sh

export RAILS_ENV=production
export EMAIL=$1
exec ./bin/rake admin:activate
