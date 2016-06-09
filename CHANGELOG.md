#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Fixed
- fixing timeout deprecation for ruby 2.3.0

## [0.3.1] - 2016-05-11
### Added
- handler-mailer.rb: add smtp_use_tls setting to support SMTPS in Amazon SES

### Changed
- Upgrade to rubocop 0.40

## [0.3.0] - 2016-04-23
### Fixed
- Fix aws-ses gem dependency

### Added
- handler-mailer.rb: add ability to build mailing list from client subscriptions

## [0.2.0] - 2016-03-17
### Added
- Support for prefixing the email subject

### Fixed
- handler-mailer.rb: Fix content type selection

## [0.1.5] - 2016-02-04
### Added
- new certs

## [0.1.4] - 2016-02-04
- Testing

## [0.1.3] - 2016-02-04
- Testing

## [0.1.2] - 2015-12-30
### Fixed
- Load correct mailgun gem in mailgun handler

## [0.1.1] - 2015-11-25
### Fixed
- Fix check output

## [0.1.0] - 2015-11-17
### Added
- Ability to use custom ERB template for mail message
- Ability to specify a custom timeout interval for sending mail
- Content type option
- Add essential information to headers

### Fixed
- Use correct mailgun gem
- Correct password replacement

### Changed
- Upgraded to rubocop 0.32.1

## [0.0.2] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0
- updated documentation links in the README and CONTRIBUTING
- puts deps in alpha order in the gemspec and rakefile

## 0.0.1 - 2015-06-04
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.3.1...HEAD
[0.3.1]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/v0.3.0...0.3.1
[0.3.0]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/v0.2.0...0.3.0
[0.2.0]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/v0.1.5...0.2.0
[0.1.5]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.1.4...v0.1.5
[0.1.4]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.1.3...0.1.4
[0.1.3]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.0.2...0.1.0
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-mailer/compare/0.0.1...0.0.2

