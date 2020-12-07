# CHANGELOG for `aggregate`

Inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Note: This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

All notable changes to this project will be documented in this file.

## [2.1.3] - 2020-12-07
### Fixed
- Fixed a bug where `Aggregate::AggregateStore#aggregate_attribute_changes` and `Aggregate::AggregateStore#changed?` would show incorrect changes.
Ensures that the correct state is represented when a field is changed from and back to it's initial value.
- Fixed a bug where changes to aggregate attributes during an aggregate schema fixup were being marked as changes.
  - These are seen as data migrations and thus are not changes to the model itself, but a transformation
- Fixed a bug where `aggregate_has_many` attribute was not being marked as changed if one of its containing values changed  

## [2.1.2] - 2020-11-23
### Fixed
- Fixed a bug where `Aggregate::AggregateStore#aggregate_attribute_changes` would show incorrect changes across database transactions

## [2.1.1] - 2020-08-31
### Fixed
- Fixed bug in Rails 5+ where `Aggregate::Base` and `Aggregate::Container` no longer had access to
callbacks defined by `ActiveRecord`

## [2.1.0] - 2020-05-28
### Added
- Added support for rails 5 and 6.
- Added appraisal tests for all supported rails version: 4/5/6

## [2.0.1] - 2020-05-04
### Removed
- Remove indirect dependency on hobo_support by upgrading large_text_field dependency
- Replace previously missed usage hobo_support methods with Ruby and Rails provided equivalents

## [2.0.0] - 2020-04-29
### Changed
- Change `Aggregate::Attribute::DateTime` to use 3 decimal places (millisecond precision) when `:aggregate_db_storage_type == :elasticsearch`

## [1.2.2] - 2020-04-28
### Changed
- Bumped invoca-utils to 0.3.0

## [1.2.1] - 2020-04-27
### Changed
- Replace hobo_support with invoca_utils

## [1.2] - 2019-07-03
### Changed
- Change `store_hash_as_json` hash option to default to `true` for regardless of `aggregate_db_storage_type`

## [1.1] - ?
### Added
- `Aggregate::AggregateStore#aggregate_attribute_changes`

## [1.0.1] - 2019-03-13
### Changed
- Update `required` option for attributes to only raise an error when `nil` is given. This is to allow supplying `false` for boolean fields.

## [1.0.0] - 2019-01-15
### Changed
- Require `store_aggregates_using` or `store_aggregates_using_large_text_field` usage when using `Aggregate::Container` in order to move away from writing to `large_text_fields`. This is not backwards compatible as all classes using `Aggregate::Container` will need to be updated.

## [0.2.0] - 2019-01-14
### Added
- Added initial entry in ChangeLog (see README at this point for gem details)

[2.1.1]: https://github.com/Invoca/aggregate/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/Invoca/aggregate/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/Invoca/aggregate/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/Invoca/aggregate/compare/v1.2.2...v2.0.0
[1.2.2]: https://github.com/Invoca/aggregate/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/Invoca/aggregate/compare/v1.2...v1.2.1
[1.2]: https://github.com/Invoca/aggregate/compare/v1.1...v1.2
[1.1]: https://github.com/Invoca/aggregate/compare/v1.0.1...v1.1
[1.0.1]: https://github.com/Invoca/aggregate/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Invoca/aggregate/compare/v0.2.0...v1.0.0

