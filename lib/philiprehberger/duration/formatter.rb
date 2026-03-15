# frozen_string_literal: true

module Philiprehberger
  class Duration
    # Format duration values for output
    module Formatter
      UNITS = [
        [86_400, 'day', 'days'],
        [3600, 'hour', 'hours'],
        [60, 'minute', 'minutes'],
        [1, 'second', 'seconds']
      ].freeze

      # Format seconds as human-readable string
      #
      # @param total_seconds [Numeric] total seconds
      # @return [String] e.g. "2 hours, 30 minutes"
      def self.to_human(total_seconds)
        return '0 seconds' if total_seconds.zero?

        parts = build_parts(total_seconds.to_i)
        parts.empty? ? '0 seconds' : parts.join(', ')
      end

      # Format seconds as ISO 8601 duration
      #
      # @param total_seconds [Numeric] total seconds
      # @return [String] e.g. "PT2H30M"
      def self.to_iso8601(total_seconds)
        days, remainder = total_seconds.to_i.divmod(86_400)
        hours, remainder = remainder.divmod(3600)
        minutes, seconds = remainder.divmod(60)
        build_iso_string(days, hours, minutes, seconds)
      end

      def self.build_parts(remaining)
        UNITS.each_with_object([]) do |(divisor, singular, plural), parts|
          value, remaining_val = remaining.divmod(divisor)
          next if value.zero?

          parts << "#{value} #{value == 1 ? singular : plural}"
          remaining = remaining_val
        end
      end
      private_class_method :build_parts

      def self.build_iso_string(days, hours, minutes, seconds)
        result = 'P'
        result += "#{days}D" unless days.zero?
        time_part = build_iso_time(hours, minutes, seconds)
        result += "T#{time_part}" unless time_part.empty?
        result == 'P' ? 'PT0S' : result
      end
      private_class_method :build_iso_string

      def self.build_iso_time(hours, minutes, seconds)
        parts = []
        parts << "#{hours}H" unless hours.zero?
        parts << "#{minutes}M" unless minutes.zero?
        parts << "#{seconds}S" unless seconds.zero?
        parts.join
      end
      private_class_method :build_iso_time
    end
  end
end
