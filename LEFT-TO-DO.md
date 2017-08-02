# Update Active admin
- Insert `gem require 'activeadmin'` in your Gemfile
- run `bundle exec rails g active_admin:install --skip-users`
- rm `config/initializers/active_admin.rb`
- run `rake db:migrate`
- git checkout --orphan on a new branch and reset --hard
  Pull https://github.com/MarcoCode/active_admin_upd
- Merge  --allow-unrelated-histories into your develop branch
- Clean conflicts, if any
- Add ACTIVE_USER and ACTIVE_PASSWORD env variables for the http basic auth
