# Github::Api::Auth

Usefull class to authenticate to github api just once and get authenticated Octokit::Client in return. OTP included.

## Installation

Add this line to your application's Gemfile:

    gem 'github-api-auth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github-api-auth

## Usage

    require 'github/api/auth'
    octo_client = Github::Api::Auth.new(scopes: ['user', 'repo']).github

And you are good to go. It will ask you for login and password and store newly created access token in local file. If OTP is required it will initiate code send process and will ask for code.

Option `scopes` defaults to `repo:status`.

## Changelog

0.2.0

- Added scopes option
- Cleaned code from external things

0.1.0

- Added basic authentication
- Added OTP authentication
- Added authenticaton by stored access token

## Contributing

1. Fork it ( https://github.com/alex-fedorov/github-api-auth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
