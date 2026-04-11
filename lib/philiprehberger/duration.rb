# frozen_string_literal: true

require_relative 'duration/version'
require_relative 'duration/parser'
require_relative 'duration/formatter'

module Philiprehberger
  # Immutable Duration value object
  class Duration
    include Comparable

    class Error < StandardError; end

    attr_reader :total_seconds

    # Parse a duration from a string or numeric value
    #
    # @param input [String, Numeric] human string, ISO 8601, or seconds
    # @return [Duration]
    # @raise [Error] if input cannot be parsed
    def self.parse(input)
      seconds = Parser.parse(input)
      new(seconds)
    end

    # Construct a duration from named components
    #
    # @param weeks [Numeric] number of weeks
    # @param days [Numeric] number of days
    # @param hours [Numeric] number of hours
    # @param minutes [Numeric] number of minutes
    # @param seconds [Numeric] number of seconds
    # @return [Duration]
    def self.from_hash(weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
      total = (weeks * 604_800) + (days * 86_400) + (hours * 3600) + (minutes * 60) + seconds
      new(total)
    end

    # Return a zero-length duration
    #
    # @return [Duration]
    def self.zero
      new(0)
    end

    # Calculate the duration between two Time objects
    #
    # @param time_a [Time] start time
    # @param time_b [Time] end time
    # @return [Duration]
    def self.between(time_a, time_b)
      new((time_b - time_a).abs)
    end

    def initialize(total_seconds)
      raise Error, 'Seconds must be numeric' unless total_seconds.is_a?(Numeric)
      raise Error, 'Seconds must not be negative' if total_seconds.negative?

      @total_seconds = total_seconds.to_f
      freeze
    end

    # Whether this duration is zero seconds
    # @return [Boolean]
    def zero?
      @total_seconds.zero?
    end

    # Format using strftime-style tokens: %W (weeks), %D (days), %H (hours, zero-padded),
    # %M (minutes, zero-padded), %S (seconds, zero-padded), %T (H:M:S),
    # %s (total seconds as integer), %%
    #
    # @param pattern [String]
    # @return [String]
    def format(pattern)
      pattern.gsub(/%[WDHMSTs%]/) do |token|
        case token
        when '%W' then weeks.to_s
        when '%D' then days.to_s
        when '%H' then hours.to_s.rjust(2, '0')
        when '%M' then minutes.to_s.rjust(2, '0')
        when '%S' then seconds.to_s.rjust(2, '0')
        when '%T' then "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
        when '%s' then @total_seconds.to_i.to_s
        when '%%' then '%'
        end
      end
    end

    def to_seconds = @total_seconds
    def to_minutes = @total_seconds / 60.0
    def to_hours = @total_seconds / 3600.0
    def to_days = @total_seconds / 86_400.0
    def to_weeks = @total_seconds / 604_800.0
    def to_i = @total_seconds.to_i
    def to_f = @total_seconds
    def to_human = Formatter.to_human(@total_seconds)
    def to_iso8601 = Formatter.to_iso8601(@total_seconds)

    # Extracted week component
    # @return [Integer]
    def weeks
      @total_seconds.to_i / 604_800
    end

    # Extracted day component (0-6)
    # @return [Integer]
    def days
      (@total_seconds.to_i % 604_800) / 86_400
    end

    # Extracted hour component (0-23)
    # @return [Integer]
    def hours
      (@total_seconds.to_i % 86_400) / 3600
    end

    # Extracted minute component (0-59)
    # @return [Integer]
    def minutes
      (@total_seconds.to_i % 3600) / 60
    end

    # Extracted second component (0-59)
    # @return [Integer]
    def seconds
      @total_seconds.to_i % 60
    end

    # Return components as a hash
    # @return [Hash] { weeks:, days:, hours:, minutes:, seconds: }
    def to_hash
      { weeks: weeks, days: days, hours: hours, minutes: minutes, seconds: seconds }
    end

    # Round to the nearest unit
    # @param unit [Symbol] :week, :day, :hour, :minute, or :second
    # @return [Duration] new rounded duration
    def round(unit)
      rounded = case unit
                when :week then ((@total_seconds / 604_800.0).round * 604_800)
                when :day then ((@total_seconds / 86_400.0).round * 86_400)
                when :hour then ((@total_seconds / 3600.0).round * 3600)
                when :minute then ((@total_seconds / 60.0).round * 60)
                when :second then @total_seconds.round
                else raise Error, "Unknown unit: #{unit}"
                end
      self.class.new(rounded)
    end

    def +(other)
      self.class.new(@total_seconds + resolve_seconds(other))
    end

    def -(other)
      self.class.new(@total_seconds - resolve_seconds(other))
    end

    def *(other)
      self.class.new(@total_seconds * other)
    end

    def /(other)
      self.class.new(@total_seconds / other)
    end

    def <=>(other)
      return nil unless other.is_a?(Duration)

      @total_seconds <=> other.total_seconds
    end

    def to_s = to_human
    def inspect = "#<Duration #{to_human}>"

    private

    def resolve_seconds(other)
      case other
      when Duration then other.total_seconds
      when Numeric then other.to_f
      else raise Error, "Cannot operate with #{other.class}"
      end
    end
  end
end
