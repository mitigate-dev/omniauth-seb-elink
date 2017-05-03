# Omniauth SEB e-link

Omniauth strategy for using SEB e-link as an authentication service provider.

[![Build Status](https://travis-ci.org/mak-it/omniauth-seb-elink.svg?branch=master)](https://travis-ci.org/mak-it/omniauth-seb-elink)

Supported Ruby versions: 2.2+

## Related projects
- [omniauth-citadele](https://github.com/mak-it/omniauth-citadele) - strategy for authenticating with Citadele
- [omniauth-dnb](https://github.com/mak-it/omniauth-dnb) - strategy for authenticating with DNB
- [omniauth-nordea](https://github.com/mak-it/omniauth-nordea) - strategy for authenticating with Nordea
- [omniauth-swedbank](https://github.com/mak-it/omniauth-swedbank) - strategy for authenticating with Swedbank

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-seb-elink'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-seb-elink

## Usage

Here's a quick example, adding the middleware to a Rails app
in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :seb, ENV['SEB_PUBLIC_CRT'], ENV['SEB_SND_ID']
end
```

## Auth Hash

Here's an example Auth Hash available in `request.env['omniauth.auth']`:

```ruby
{
  provider: 'seb',
  uid: '374042-80367',
  info: {
    full_name: 'ARNIS RAITUMS'
  },
  extra: {
    raw_info: {
      B02K_ALG: "01",
      B02K_CUSTID: "37404280367",
      B02K_CUSTNAME: "RAITUMS ARNIS",
      B02K_CUSTTYPE: "01",
      B02K_IDNBR: "87654321LV",
      B02K_KEYVERS: "0001",
      B02K_MAC: "B2B82821F6EB9CA28E4D67F343914363",
      B02K_STAMP: "yyyymmddhhmmssxxxxxx",
      B02K_TIMESTMP: "20020170329134514398",
      B02K_VERS: "0002",
      omniauth_status: "success"
    }
  }
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
