## Sensu-Plugins-mailer

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-mailer.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-mailer)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-mailer.svg)](http://badge.fury.io/rb/sensu-plugins-mailer)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-mailer)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-mailer.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-mailer)

## Functionality

## Files
 * bin/handler-mailer-mailgun.rb
 * bin/handler-mailer-ses.rb
 * bin/handler-mailer.rb

## Usage

The following three configuration variables must be set if you want mailer to use remote SMTP settings:

    smtp_address - defaults to "localhost"
    smtp_port - defaults to "25"
    smtp_domain - defaults to "localhost.localdomain"

There is an optional subscriptions hash which can be added to your mailer.json file.  This subscriptions hash allows you to define individual mail_to addresses for a given subscription.  When the mailer handler runs it will check the clients subscriptions and build a mail_to string with the default mailer.mail_to address as well as any subscriptions the client subscribes to where a mail_to address is found.  There can be N number of hashes inside of subscriptions but the key for a given hash inside of subscriptions must match a subscription name. 

Optionally, you can specify your own ERB template file to use for the message
body.  The order of precedence for templates is: command-line argument (-t),
client config called "template", the mailer handler config, default.

```json
{
  "mailer": {
    "mail_from": "sensu@example.com",
    "mail_to": "monitor@example.com",
    "smtp_address": "smtp.example.org",
    "smtp_port": "25",
    "smtp_domain": "example.org",
    "template": "/optional/path/to/template.erb",
    "subscriptions": {
      "subscription_name": {
        "mail_to": "teamemail@example.com"
      }
    }
  }
}
```

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

### Contact Based Routing

Optionally, this handler can use the same syntax as [Sensu Enterprise contact routing](https://sensuapp.org/docs/0.26/enterprise/contact-routing.html) for sending e-mails for particular checks or clients, in addition to the previous configuration. This is configured by declaring contacts:

**support.json**
```
{
  "contacts": {
    "support": {
      "email": {
        "to": "support@sensuapp.com"
      }
    }
  }
} 
```

Then, in a check definition, you can specify a contact or an array of contacts which should be notified by e-mail:

**example_check.json**
```
{
  "checks": {
    "example_check": {
      "command": "do_something.rb",
      "handler": "mailer",
      "contact": "support"
    }
  }
}
```

Additionally, a client defination can specify a contact or an array of contacts to be notified of any check which alerts to the mailer handler. This is configured by specifying a contact value, or contacts array in the client.json configuration.

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
