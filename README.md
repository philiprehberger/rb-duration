# philiprehberger-duration

[![Tests](https://github.com/philiprehberger/rb-duration/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-duration/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-duration.svg)](https://rubygems.org/gems/philiprehberger-duration)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-duration)](https://github.com/philiprehberger/rb-duration/commits/main)

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

### Component Accessors

```ruby
d = Philiprehberger::Duration.parse("1 day 2 hours 30 minutes 45 seconds")
d.days     # => 1
d.hours    # => 2
d.minutes  # => 30
d.seconds  # => 45
d.to_hash  # => { days: 1, hours: 2, minutes: 30, seconds: 45 }
```

### Rounding

```ruby
d = Philiprehberger::Duration.parse("1h 45m")
d.round(:hour).to_human  # => "2 hours"
```

## API

| Method | Description |
|--------|-------------|
| `Duration.parse(input)` | Parse human string, ISO 8601, or numeric seconds |
| `Duration.between(time_a, time_b)` | Duration between two Time objects |
| `#to_seconds` | Total seconds as float |
| `#to_human` | Human-readable string |
| `#to_iso8601` | ISO 8601 formatted string |
| `#days` | Extracted day component |
| `#hours` | Extracted hour component (0-23) |
| `#minutes` | Extracted minute component (0-59) |
| `#seconds` | Extracted second component (0-59) |
| `#to_hash` | Components as `{ days:, hours:, minutes:, seconds: }` |
| `#round(unit)` | Round to nearest `:day`, `:hour`, `:minute`, or `:second` |
| `#+`, `#-`, `#*`, `#/` | Arithmetic operations |
| `<`, `>`, `==`, `<=>` | Comparison (via Comparable) |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-duration)

🐛 [Report issues](https://github.com/philiprehberger/rb-duration/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-duration/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
