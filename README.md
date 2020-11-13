# Cloud::Infra

A client which provides an interface to cloud.redhat RBAC and entitlements infrastructure services.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloud-infra-ruby', git: 'https://github.com/rack/rack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloud-infra-ruby

## Usage

The following environment variables are required to be set, or default will be used where applicable:
```
REDIS_HOST # default is 127.0.0.1
REDIS_PORT # default is 6379
REDIS_DB # default is 0
REDIS_PASSWORD # no default
CACHE_HOST # no default
```

```ruby
# require the client class
require 'cloud/infra'

# create a new client
platform_client = Cloud::Infra::Client.new

# get all RBAC access for a principal/application
rbac_access = platform_client.rbac_access(identity_header, application)
# check if the principal has RBAC access to the application
has_rbac_access = platform_client.has_rbac_access?(identity_header, application)

# get all entitlements for a principal
entitlements = platform_client.entitlements(identity_header)
# check if the principal has entitlements access to the bundle
has_entitlements_access = platform_client.has_entitlements_access?(identity_header, bundle)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
