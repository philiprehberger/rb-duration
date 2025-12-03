# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-04-15

### Added
- `Duration.parse?(input)` non-raising variant that returns `nil` for `nil`, empty, or unparseable input

## [0.5.0] - 2026-04-10

### Added
- Week support in parsing (`"2w"`, `"1 week"`, `"P2W"`), formatting, and component access
- `Duration.from_hash` factory method for constructing durations from named components
- `#to_weeks` total conversion method
- `#weeks` component accessor
- `#to_i` and `#to_f` standard Ruby numeric conversion methods
- `%W` format token for weeks in `#format`
- `:week` unit for `#round`

### Changed
- `#to_hash` now includes `weeks:` key
- `#days` now returns the day component within the current week (0-6), consistent with how `#hours` returns 0-23

## [0.4.0] - 2026-04-10

### Added
- `#to_minutes` total duration in minutes as Float
- `#to_hours` total duration in hours as Float
- `#to_days` total duration in days as Float

### Fixed
- Align issue templates with guide (add gem version field, alternatives field)

## [0.3.0] - 2026-04-09

### Added
- `Duration.zero` class method for constructing a zero-length duration
- `#zero?` predicate
- `#format(pattern)` strftime-style formatter supporting `%D`, `%H`, `%M`, `%S`, `%T`, `%s`, and `%%`

## [0.2.1] - 2026-04-08

### Changed
- Align gemspec summary with README description.

## [0.2.0] - 2026-04-01

### Added
- `#days`, `#hours`, `#minutes`, `#seconds` component accessor methods
- `#to_hash` for structured serialization as `{ days:, hours:, minutes:, seconds: }`
- `#round(unit)` for rounding to nearest `:day`, `:hour`, `:minute`, or `:second`

## [0.1.10] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.9] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.8] - 2026-03-26

### Changed
- Add Sponsor badge to README
- Fix License section format
- Sync gemspec summary with README

## [0.1.7] - 2026-03-24

### Fixed
- Shorten README one-liner to match gemspec summary and stay under 120 characters

## [0.1.6] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.1.5] - 2026-03-22

### Changed
- Expand test coverage from 25 to 47 examples

### Fixed
- Standardize Installation section in README

## [0.1.4] - 2026-03-18

### Changed
- Revert gemspec to single-quoted strings per RuboCop default configuration

## [0.1.3] - 2026-03-18

### Changed
- Fix RuboCop Style/StringLiterals violations in gemspec

## [0.1.2] - 2026-03-16

### Changed
- Add License badge to README
- Add bug_tracker_uri to gemspec

## [0.1.1] - 2026-03-15

### Changed
- Add Requirements section to README

## [0.1.0] - 2026-03-15

### Added
- Initial release
- Human and ISO 8601 duration parsing
- Arithmetic and comparison operations
- Multiple output formats (human-readable and ISO 8601)
- Immutable frozen value objects
