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

Add these lines to your application's Gemfile (omniauth-rails_csrf_protection is required if using Rails):

    gem 'omniauth-rails_csrf_protection'
    gem 'omniauth-seb-elink'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gem omniauth-rails_csrf_protection omniauth-seb-elink

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
      IB_SND_ID: 'SEBUB',
      IB_SERVICE: '0001',
      IB_REC_ID: 'TETS_SND_ID',
      IB_USER: '374042-80367',
      IB_DATE: '11.05.2017',
      IB_TIME: '15:22:18',
      IB_USER_INFO: 'ID=374042-80367;NAME=ARNIS RAITUMS',
      IB_VERSION: '001',
      IB_CRC: 'UYVDKsdkjsd...',
      IB_LANG: 'LAT'
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
