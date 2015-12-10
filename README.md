# README

The collation-modeler is a Rails application for creating
XML-formatted descriptions of quires, as "Leaves XML":

```xml
<?xml version="1.0"?>
<manuscript>
  <url>http://www.example.com</url>
  <title>Test One Book</title>
  <shelfmark>MS T1B</shelfmark>
  <quire n="1">
    <leaf n="1" mode="original" single="false" folio_number="1" conjoin="7" position="1"/>
    <leaf n="2" mode="original" single="true" folio_number="2" conjoin="" position="2"/>
    <leaf n="3" mode="original" single="false" folio_number="3" conjoin="6" position="3"/>
    <leaf n="4" mode="original" single="false" folio_number="4" conjoin="5" position="4"/>
    <leaf n="5" mode="original" single="false" folio_number="5" conjoin="4" position="5"/>
    <leaf n="6" mode="original" single="false" folio_number="6" conjoin="3" position="6"/>
    <leaf n="" conjoin="2" position="7"/>
    <leaf n="7" mode="original" single="false" folio_number="7" conjoin="1" position="8"/>
  </quire>
  <quire n="2">
    <leaf n="1" mode="original" single="false" folio_number="" conjoin="2" position="1"/>
    <leaf n="2" mode="original" single="false" folio_number="" conjoin="1" position="2"/>
  </quire>
  <quire n="3">
    <leaf n="1" mode="original" single="false" folio_number="" conjoin="6" position="1"/>
    <leaf n="2" mode="original" single="false" folio_number="" conjoin="5" position="2"/>
    <leaf n="3" mode="original" single="false" folio_number="" conjoin="4" position="3"/>
    <leaf n="4" mode="original" single="false" folio_number="" conjoin="3" position="4"/>
    <leaf n="5" mode="original" single="false" folio_number="" conjoin="2" position="5"/>
    <leaf n="6" mode="original" single="false" folio_number="" conjoin="1" position="6"/>
  </quire>
</manuscript>
```

Or "Joins XML":

```xml
<?xml version="1.0"?>
<manuscript url="http://www.example.com">
  <title>Test One Book</title>
  <shelfmark>MS T1B</shelfmark>
  <quires>
    <quire n="1">
      <unit>
        <leaf n="1" mode="original" single="false" folio_number="1"/>
        <leaf n="7" mode="original" single="false" folio_number="7"/>
      </unit>
      <unit>
        <leaf n="2" mode="original" single="true" folio_number="2"/>
      </unit>
      <unit>
        <leaf n="3" mode="original" single="false" folio_number="3"/>
        <leaf n="6" mode="original" single="false" folio_number="6"/>
      </unit>
      <unit>
        <leaf n="4" mode="original" single="false" folio_number="4"/>
        <leaf n="5" mode="original" single="false" folio_number="5"/>
      </unit>
    </quire>
    <quire n="2">
      <unit>
        <leaf n="1" mode="original" single="false" folio_number=""/>
        <leaf n="2" mode="original" single="false" folio_number=""/>
      </unit>
    </quire>
    <quire n="3">
      <unit>
        <leaf n="1" mode="original" single="false" folio_number=""/>
        <leaf n="6" mode="original" single="false" folio_number=""/>
      </unit>
      <unit>
        <leaf n="2" mode="original" single="false" folio_number=""/>
        <leaf n="5" mode="original" single="false" folio_number=""/>
      </unit>
      <unit>
        <leaf n="3" mode="original" single="false" folio_number=""/>
        <leaf n="4" mode="original" single="false" folio_number=""/>
      </unit>
    </quire>
  </quires>
</manuscript>
```

The Leaves XML can be used as input for the collation visualization
tool described on Dot Porter's project page
(<https://github.com/leoba/VisColl>).

## Set up

#### Required software

- Ruby v2.1.5

I recommend using Homebrew to install `rbenv` and `ruby-build`, and
then use `rbenv` to install Ruby 2.1.5.

- Foreman

`gem install foreman`

#### Setting up and running the Rails app

It's a pretty standard Rails app, you'll need a database.  Edit
`config/database.yml` to fit your setup.  You'll need to change the
`Gemfile` if you want to use a database other than MySQL.

Once you've made those changes, run:

```bash
bundle install
bundle exec rake db:setup
```

Then run:

`foreman start`

These instructions are not tested, so please contact me if you have
any problems.

My installation notes are here: [SETUP.md](SETUP.md). You don't need
to follow these, I've already set up the Gemfile, and so on. Note the
Devise is listed as here and in the Gemfile but authentication has not
been set up yet.
