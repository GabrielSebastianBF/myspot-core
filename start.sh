#!/bin/bash
cd /home/lemut/.openclaw/workspace/myspot-core
export GEM_HOME=/home/lemut/.gem/ruby/3.2.0
export PATH=/home/lemut/.gem/ruby/3.2.0/bin:/usr/local/bin:$PATH
export RAILS_ENV=development
export DB_HOST=localhost
export DB_USERNAME=myspot
export DB_PASSWORD=myspot_password

exec bundle exec puma -p 3000
