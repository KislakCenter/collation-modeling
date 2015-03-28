# README

## Software version

Ruby v2.1.5

Rails 4.2.1


* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Install

Install Ruby 2.1.5

```bash
# Update ruby-build; the following works on Mac with Homebrew
$ brew update
$ brew upgrade ruby-build
$ rbenv install 2.1.5
$ rbenv rehash
$ rbenv shell 2.1.5 # <- Make sure you're using 2.1.5 before
proceeding
```

Install rails 4.2

`gem install rails`

Create the collation-modeling app, skipping test unit with the `-T` flag:

`rails new collation-modeling -T`

`$ cd collation-modeling`

Set the local `rbenv` to 2.1.5

```bash
$ rbenv local 2.1.5
```

# RSPEC
Add the following to the Gemfile test, development groups:

```ruby
group :development, :test do
gem 'spring-commands-rspec'
gem 'rspec-rails'
gem 'guard-rspec'
gem 'rb-fsevent' if `uname` =~ /Darwin/
end
```

`$ bundle install`

`$ rails g rspec:install`

# GUARD

`$ guard init`

Change guard invocation line from:

```ruby
guard :rspec, cmd: "bundle exec rspec" do
```

to:

```ruby
guard :rspec, cmd:"spring rspec" do
```

# BOOTSTRAP

The following instructions taken fromx
<http://www.gotealeaf.com/blog/integrating-rails-and-bootstrap-part-1>.

Add the gems:

```ruby
gem 'bootstrap-sass', '~> 3.2.0'
gem 'autoprefixer-rails'
```

`$ bundle install`

Rename `app/assets/stylesheets/application.css` to
`app/assets/stylesheets/application.css.sass`

```bash
$ mv app/assets/stylesheets/application.css \
app/assets/stylesheets/application.css.sass
```

Add the imports to `app/assets/stylesheets/application.css.sass`

```sass
@import "bootstrap-sprockets"
@import "bootstrap"
```

To `app/assets/javascripts/application.js` add the following after the
jquey import:

```js
//= require bootstrap-sprockets
```

It should look like this when done:

```js
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .
```

# Markdown over rdoc for readme

rename README.rdoc -> README.md

# SIMPLE FORM

Add simple form gem:

```ruby
gem 'simple_form'
```

Run bundle install:

```bash
$ bundle install
```

Make simple_form use bootstrap:

```bash
$ rails generate simple_form:install --bootstrap
```

# MYSQL2

Remove sqlite3 and add mysql2 database gem.


```ruby
# Use sqlite3 as the database for Active Record
# gem 'sqlite3' # nope: de 20150113

# Add mysql2 adapter - de 20150113
gem 'mysql2'
```

Run bundle install:

```bash
$ bundle install
```

Replace config/database.yml contents with:

```yaml
# Using mysql2 gem:
#
# gem 'mysql2'
#
default: &default
adapter: mysql2
encoding: utf8
pool: 5
timeout: 5000

development:
<<: *default
database: collation_development
username: root
password:

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
<<: *default
database: collation_test
username: root
password:

production:
<<: *default
database: collation
username: collationuser
password: ENV['COLLATION_DB_PASSWORD']
```

Try to create the database:

```bash
$ rake db:create
```

Now, try to connect to the database:

```bash
$ mysql collation_development -u root -p
Enter password:  # <-- password is blank; hit enter
# blah, blah, blah
mysql> \r
Connection id:    6450
Current database: collation_development

```

The database is empty, but you should be able to connect to it.

# DEVISE

Add devise to Gemfile:

```ruby
gem 'devise'
```

Run bundle install:

```bash
$ bundle install
```

Generate the initializer:

```bash
$ rails generate devise:install
```

Be sure to follow configuration instructions:

===============================================================================

Some setup you must do manually if you haven't yet:

1. Ensure you have defined default url options in your
environments files. Here
is an example of default_url_options appropriate for a
development environment
in config/environments/development.rb:

config.action_mailer.default_url_options = { host:
'localhost', port: 3000 }

In production, :host should be set to the actual host of your
application.

2. Ensure you have defined root_url to *something* in your
config/routes.rb.
For example:

root to: "home#index"

3. Ensure you have flash messages in
app/views/layouts/application.html.erb.
For example:

<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>

4. If you are deploying on Heroku with Rails 3.2 only, you may
want to set:

config.assets.initialize_on_precompile = false

On config/application.rb forcing your application to not
access the DB
or load models when precompiling your assets.

5. You can copy Devise views (for customization) to your app by
running:

rails g devise:views

===============================================================================

Edit config files as described above:

```ruby
# config/environments/development.rb

# Devise stuff
# Ensure you have defined default url options in your environments
# files. Here
# is an example of default_url_options appropriate for a
# development environment
# in config/environments/development.rb:
# In production, :host should be set to the actual host of your
# application.
config.action_mailer.default_url_options = { host:
# 'localhost', port: 3000 }
```

```ruby
# config/environments/production.rb

# Devise stuff
# Ensure you have defined default url options in your environments
# files. Here
# is an example of default_url_options appropriate for a
# development environment
# in config/environments/development.rb:
#
#     config.action_mailer.default_url_options = { host:
# 'localhost', port: 3000 }
#
# In production, :host should be set to the actual host of
# your application.
# TODO: set production host for action_mailer
config.action_mailer.default_url_options = { host:
# 'localhost', port: 3000 }
```

Add add a welcome#index controller and action for root:

```bash
$ rails g controller welcome index
```

Set the root in config/routes.rb to this action:

```ruby
# config/routes.rb

# You can have the root of your site routed with "root"
root to: 'welcome#index'
```

Start the rails server and make sure the route is working:

```bash
$ rails s
```
