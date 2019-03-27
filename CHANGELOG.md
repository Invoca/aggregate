# Changelog
All notable changes to this project will be documented in this file.
## [1.0.1] - 2019-03-13
### Changed
- Update `required` option for attributes to only raise an error when `nil` is given. This is to allow supplying `false` for boolean fields.

## [1.0.0] - 2019-01-15
### Changed
- Require `store_aggregates_using` or `store_aggregates_using_large_text_field` usage when using `Aggregate::Container` in order to move away from writing to `large_text_fields`. This is not backwards compatible as all classes using `Aggregate::Container` will need to be updated.

## [0.2.0] - 2019-01-14
### Added
- Added initial entry in ChangeLog (see README at this point for gem details)
