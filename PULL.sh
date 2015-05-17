#/bin/bash
git pull origin master
git fetch --all
git reset --hard origin/master
sudo bundle install
bundle exec rake db:migrate RAILS_ENV=production
rm public/assets/*
bundle exec rake assets:precompile RAILS_ENV=production
sudo apachectl restart
