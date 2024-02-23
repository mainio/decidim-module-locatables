# Decidim::Locatables

A wrapper module for locations modules which allow linking locations to different classes.

## Usage

Locatables will be available as a Component for a Participatory
Space.

Each modules' specific usage guides will be available in each module's own README -files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-locatables", github: "mainio/decidim-module-locatables"
```

This module uses [Locations](https://github.com/mainio/decidim-module-locations) module to work, also add this line to
your application's Gemfile:

```ruby
gem "decidim-locations", github: "mainio/decidim-module-locations"
```

And then execute:

```bash
$ bundle
```

## After installation

This module requires locations -module to work that comes with migrations to the database which have to be
installed.

Install the locations -module migrations first:

```bash
$ bundle exec rake decidim_locations:install:migrations
```

Proposals- and Meetings -locations come with migrations that transfer proposals and meetings
with addresses to locations. And Forms -locations comes with migrations to add a possibility to change
the amount of shapes allowed in a map, but also two new fields to configure default
coordinates to the map initialization through the admin settings.

If you want to use the whole wrapper module, remember to install all of these migrations:

```bash
$ bundle exec rake decidim_forms_locations:install:migrations
$ bundle exec rake decidim_proposals_locations:install:migrations
$ bundle exec rake decidim_meetings_locations:install:migrations
```

Migrate the installed migrations:

```bash
$ bundle exec rake db:migrate
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
