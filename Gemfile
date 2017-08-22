source 'https://rubygems.org'

ruby '2.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.9'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 3.2.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.3.1'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.0.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'bootstrap-sass', '~> 3.3.7'
gem 'autoprefixer-rails', '~> 7.1.2.6'

gem 'acts_as_list', '~> 0.9.5'
gem 'simple_form', '~> 3.5.0'

gem 'devise', '~> 3.4.1'
gem 'activerecord-import', '~> 0.19.1'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn', '~> 5.3.0'

group :production do
  gem 'pg', '~> 0.18.1'
end

group :development, :test do
  gem 'mysql2', '~> 0.4.9'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'#, '~> 4.0.3'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'#, '~> 1.3.3'

  gem 'redcarpet'#, '~> 3.1.2'

  gem 'pry-rails'#, '~> 0.3.4'
end

# Access an IRB console on exception pages or by using <%= console %> in views
gem 'web-console', '~> 2.0', group: :development

group :development, :test do
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'rspec-rails', '~> 3.6.1'
  gem 'guard-rspec', '~> 4.5.0'
  gem 'rb-fsevent', '~> 0.9.4'
  gem 'factory_girl_rails', '~> 4.5.0'
end
