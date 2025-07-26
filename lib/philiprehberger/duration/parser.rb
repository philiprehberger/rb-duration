# frozen_string_literal: true

module Philiprehberger
  class Duration
    # Parse duration strings into total seconds
    module Parser
      HUMAN_PATTERN =
        /(\d+(?:\.\d+)?)\s*(ms|milliseconds?|w(?:eeks?)?|d(?:ays?)?|h(?:ours?)?|m(?:in(?:utes?)?)?|s(?:ec(?:onds?)?)?)/i
      ISO_PATTERN = /\AP(?:(\d+)W)?(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?\z/

      # Parse input into total seconds
      #
      # @param input [String, Numeric] the input to parse
      # @return [Float] total seconds
      # @raise [Duration::Error] if input cannot be parsed
      def self.parse(input)
        case input
        when Numeric then input.to_f
        when String then parse_string(input)
        else raise Duration::Error, "Cannot parse #{input.class}"
        end
      end

      def self.parse_string(string)
        return parse_iso(string) if string.match?(/\AP/i)

        parse_human(string)
      end
      private_class_method :parse_string

      def self.parse_human(string)
        matches = string.scan(HUMAN_PATTERN)
        raise Duration::Error, "Cannot parse duration: #{string}" if matches.empty?

        matches.sum { |value, unit| convert_unit(value.to_f, unit.downcase) }
      end
      private_class_method :parse_human

      def self.parse_iso(string)
        match = string.match(ISO_PATTERN)
        raise Duration::Error, "Invalid ISO 8601 duration: #{string}" unless match

        iso_to_seconds(match)
      end

      def self.iso_to_seconds(match)
        w, d, h, m, s = (1..5).map { |i| (match[i] || 0).to_f }
        (w * 604_800) + (d * 86_400) + (h * 3600) + (m * 60) + s
      end
      private_class_method :parse_iso

      def self.convert_unit(value, unit)
        case unit
        when 'ms', /\Amilliseconds?\z/ then value / 1000.0
        when /\Aw/ then value * 604_800
        when /\Ad/ then value * 86_400
        when /\Ah/ then value * 3600
        when /\Am/ then value * 60
        when /\As/ then value
        else raise Duration::Error, "Unknown unit: #{unit}"
        end
      end
      private_class_method :convert_unit
    end
  end
end
