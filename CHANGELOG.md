# CHANGELOG for `aggregate`

Inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Note: This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

All notable changes to this project will be documented in this file.

## [2.4.5] - UNRELEASED
### Added
- Addresses issue [#149](https://github.com/Invoca/aggregate/issues/149). Add `aggregate_treat_undefined_attributes_as_default_value?` functionality to support treating attributes that are missing keys in the decoded aggregate store (serialized data) as the attribute's default value. See README for more details.

## [2.4.4] - 2021-10-22
### Fixed
- Update gemspec to require >= 1.0.2 for `large_text_field` gem to support reloading with a single argument.

## [2.4.3] - 2021-10-21
### Fixed
- Bug where `Aggregate::Container#reload` didn't accept arguments even though `ActiveRecord::Persistence` does.

## [2.4.2] - 2021-05-27
### Fixed
- Fixed a bug where bitfield attributes were unnecessarily storing nulls in the aggregate store when empty.

## [2.4.1] - 2021-04-12
### Fixed
- Fixed an issue for Rails 5 where autosave associations weren't being recognized to be saved when the only changes on the object are aggregate attributes.
  - This was primarily an issue with objects that utilize storing their aggregate data via LargeTextField and trying to have that object be autosaved by saving the object's parent relationship object.

E.g.

```ruby
advertiser_campaign.future_terms.build_commission_budget_terms({...})
advertiser_campaign.save! # This would not save the commission budget terms aggregate attribute on the future campaign terms
```

## [2.4.0] - 2021-03-23
### Removed
- Removed support for Rails 6.1+, since some requires moved around. Instead, for now we're stopping at < 6.1.

## [2.3.1] - 2021-03-09
### Fixed
- Fixed a bug where `Aggregate::AggregateStore` saved change methods would not show correct changes for
  all scenarios:
  - `#saved_changes?`
  - `#aggregate_attribute_saved_changes`
  - `#saved_change_to_{attribute}?`
- When a one of the methods is called while the save is still in progess, the change will show correctly

## [2.3.0] - 2021-03-04
### Added
- Added support for `saved_changes?` in `Aggregate::AggregateStore` for rails 5.
- Added `saved_changes?` method which returns boolean of whether or not changes were made on the most recent save.
- Added `aggregate_attribute_saved_changes` method which returns a hash of the most recent saved changes for the aggregate attributes.

## [2.2.0] - 2021-01-04
### Added
- Added support for assigning bitfield via array of mapped values.
- Added `to_a` method which converts bitfield bits to an array of mapped values.

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

[2.4.5]: https://github.com/Invoca/aggregate/compare/v2.4.4...v2.4.5
[2.4.4]: https://github.com/Invoca/aggregate/compare/v2.4.3...v2.4.4
[2.4.3]: https://github.com/Invoca/aggregate/compare/v2.4.2...v2.4.3
[2.4.2]: https://github.com/Invoca/aggregate/compare/v2.4.1...v2.4.2
[2.4.1]: https://github.com/Invoca/aggregate/compare/v2.4.0...v2.4.1
[2.4.0]: https://github.com/Invoca/aggregate/compare/v2.3.1...v2.4.0
[2.3.1]: https://github.com/Invoca/aggregate/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/Invoca/aggregate/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/Invoca/aggregate/compare/v2.1.3...v2.2.0
[2.1.3]: https://github.com/Invoca/aggregate/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/Invoca/aggregate/compare/v2.1.1...v2.1.2
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
