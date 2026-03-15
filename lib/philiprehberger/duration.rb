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

    def to_seconds = @total_seconds
    def to_human = Formatter.to_human(@total_seconds)
    def to_iso8601 = Formatter.to_iso8601(@total_seconds)

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
