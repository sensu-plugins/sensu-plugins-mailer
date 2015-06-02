## Sensu-Plugins-mailer

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-mailer.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-mailer)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-mailer.svg)](http://badge.fury.io/rb/sensu-plugins-mailer)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-mailer.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-mailer)
[ ![Codeship Status for sensu-plugins/sensu-plugins-mailer](https://codeship.com/projects/558443b0-ea2d-0132-729c-4602e60b2e9f/status?branch=master)](https://codeship.com/projects/83060)

## Functionality

## Files
 * bin/handler-mailer-mailgun
 * bin/handler-mailer-ses
 * bin/handler-mailer

## Usage

**handler-mailer-mailgun**
```
{
  "mailer-mailgun": {
    "mail_from": "sensu@example.com",
    "mail_to": "bob@example.com",
    "mg_apikey": "mailgunapikeygoeshere",
    "mg_domain": "mailgun.domain.com"
  }
}
```

**handler-mailer-ses**
```
{
  "mailer-ses": {
    "mail_from": "sensu@example.com",
    "mail_to": "monitor@example.com",
    "aws_access_key": "myawsaccesskey",
    "aws_secret_key": "myawssecretkey",
    "aws_ses_endpoint": "email.us-east-1.amazonaws.com"
  }
}
```

**handler-mailer**
```
{
  "mailer": {
    "admin_gui": "http://admin.example.com:8080/",
    "mail_from": "sensu@example.com",
    "mail_to": "monitor@example.com",
    "smtp_address": "smtp.example.org",
    "smtp_port": "25",
    "smtp_domain": "example.org"
  }
}
```

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-mailer -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-mailer`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-mailer' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-mailer' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
