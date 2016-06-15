#!/bin/sh

exec bundle exec ./bin/rails server -e production -b 0.0.0.0
