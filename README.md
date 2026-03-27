# philiprehberger-duration

[![Tests](https://github.com/philiprehberger/rb-duration/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-duration/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-duration.svg)](https://rubygems.org/gems/philiprehberger-duration)
[![License](https://img.shields.io/github/license/philiprehberger/rb-duration)](LICENSE)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ec6cb9)](https://github.com/sponsors/philiprehberger)

Immutable Duration value object with parsing, arithmetic, and formatting

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-duration"
```

Or install directly:

```bash
gem install philiprehberger-duration
```

## Usage

```ruby
require "philiprehberger/duration"

d = Philiprehberger::Duration.parse("2h 30m")
d.to_seconds   # => 9000.0
d.to_human     # => "2 hours, 30 minutes"
d.to_iso8601   # => "PT2H30M"
```

### Parsing

```ruby
Duration = Philiprehberger::Duration

Duration.parse("1 day 3 hours")   # human string
Duration.parse("PT2H30M")         # ISO 8601
Duration.parse(3600)              # numeric seconds
```

### Arithmetic

```ruby
d1 = Duration.parse("2h")
d2 = Duration.parse("30m")

d1 + d2   # => Duration("2 hours, 30 minutes")
d1 - d2   # => Duration("1 hour, 30 minutes")
d2 * 3    # => Duration("1 hour, 30 minutes")
d1 / 2    # => Duration("1 hour")
```

### Comparison

```ruby
Duration.parse("2h") > Duration.parse("1h")   # => true
Duration.parse("60m") == Duration.parse("1h")  # => true
```

### Between Two Times

```ruby
Duration.between(start_time, end_time).to_human  # => "3 hours, 15 minutes"
```

## API

| Method | Description |
|--------|-------------|
| `Duration.parse(input)` | Parse human string, ISO 8601, or numeric seconds |
| `Duration.between(time_a, time_b)` | Duration between two Time objects |
| `#to_seconds` | Total seconds as float |
| `#to_human` | Human-readable string |
| `#to_iso8601` | ISO 8601 formatted string |
| `#+`, `#-`, `#*`, `#/` | Arithmetic operations |
| `<`, `>`, `==`, `<=>` | Comparison (via Comparable) |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

[MIT](LICENSE)
