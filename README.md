# Capistrano S3 Shared Secrets

Capistrano S3 shared secrets is an opinionated method to share `config/secrets.yml` across developers
using an AWS S3 bucket to store a common secrets.yml. It also makes some secrets available to capistrano
and upload only the relevant stage section to servers

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-s3-shared-secrets', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-s3-shared-secrets

## Usage

Require the module in your `Capfile`:

```ruby
require 'capistrano/s3-shared-secrets'
```

This gem uses `s3cmd` to access AWS S3 files, you cam install it via pip

```
pip install s3cmd
```

`capistrano/s3-shared-secrets` comes with 4 tasks

```
cap secrets:compare                # Compares local secrets with the stored on the bucket
cap secrets:get_from_s3            # Overwrites local secrets with bucket version
cap secrets:upload                 # Uploads secrets.yml
cap app:write:secrets_yml          # write secrets.yml
```

If theres a `deploy_<stage>:` section in the secrets file it will be available thru fetch to capistrano via fetch in a `:secrets` array

#### secrets:get_from_s3

Gets local secrets file from the AWS bucket (`s3cmd` must be properly configured to access bucket contents) *overwriting* local file

#### secrets:upload

Uploads local secrets file from local *overwriting* the AWS S3 bucket destination

#### secrets:compare

Shows a diff between local and S3 stored secrets file

#### app:write:secrets_yml

Overwrite secrets file in the release roles using local file contents, it only writes the section which match the `:stage` selected in capistrano

## Configuration

Some variables can be configured

```
set :secrets_local_file, 'config/secrets.yml'          # default secrets file
set :setup_bucket, -> {"#{fetch(:application)}-setup"} # default bucket name
set :warn_if_no_secrets_file, -> { true }              # warn when theres no secrets file
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/the-cocktail/capistrano-s3-shared-secrets.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

