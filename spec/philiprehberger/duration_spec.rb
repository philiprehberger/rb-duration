# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Duration do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.parse' do
    it 'parses human string with hours and minutes' do
      d = described_class.parse('2h 30m')
      expect(d.to_seconds).to eq(9000.0)
    end

    it 'parses human string with days and hours' do
      d = described_class.parse('1 day 3 hours')
      expect(d.to_seconds).to eq(97_200.0)
    end

    it 'parses milliseconds' do
      d = described_class.parse('500ms')
      expect(d.to_seconds).to eq(0.5)
    end

    it 'parses ISO 8601 format' do
      d = described_class.parse('PT2H30M')
      expect(d.to_seconds).to eq(9000.0)
    end

    it 'parses ISO 8601 with days' do
      d = described_class.parse('P1DT3H')
      expect(d.to_seconds).to eq(97_200.0)
    end

    it 'parses ISO 8601 with fractional seconds' do
      d = described_class.parse('PT0.5S')
      expect(d.to_seconds).to eq(0.5)
    end

    it 'parses numeric seconds' do
      d = described_class.parse(90)
      expect(d.to_seconds).to eq(90.0)
    end

    it 'raises on invalid string' do
      expect { described_class.parse('not a duration') }.to raise_error(described_class::Error)
    end

    it 'raises on invalid type' do
      expect { described_class.parse([]) }.to raise_error(described_class::Error)
    end
  end

  describe '.parse?' do
    it 'returns a Duration for a valid human string' do
      d = described_class.parse?('2h 30m')
      expect(d).to be_a(described_class)
      expect(d.to_seconds).to eq(9000.0)
    end

    it 'parses "1h30m" correctly' do
      d = described_class.parse?('1h30m')
      expect(d).to be_a(described_class)
      expect(d.to_seconds).to eq(5400.0)
    end

    it 'returns a Duration for a valid ISO 8601 string' do
      d = described_class.parse?('PT2H30M')
      expect(d).to be_a(described_class)
      expect(d.to_seconds).to eq(9000.0)
    end

    it 'returns a Duration for a valid integer input' do
      d = described_class.parse?(90)
      expect(d).to be_a(described_class)
      expect(d.to_seconds).to eq(90.0)
    end

    it 'returns nil for an empty string' do
      expect(described_class.parse?('')).to be_nil
    end

    it 'returns nil for nil input' do
      expect(described_class.parse?(nil)).to be_nil
    end

    it 'returns nil for gibberish input' do
      expect(described_class.parse?('xyz')).to be_nil
    end

    it 'returns nil for unsupported input types' do
      expect(described_class.parse?([])).to be_nil
      expect(described_class.parse?({})).to be_nil
      expect(described_class.parse?(:symbol)).to be_nil
    end
  end

  describe '.between' do
    it 'calculates duration between two times' do
      t1 = Time.new(2026, 1, 1, 0, 0, 0)
      t2 = Time.new(2026, 1, 1, 2, 30, 0)
      d = described_class.between(t1, t2)
      expect(d.to_seconds).to eq(9000.0)
    end

    it 'returns absolute duration regardless of order' do
      t1 = Time.new(2026, 1, 1, 2, 30, 0)
      t2 = Time.new(2026, 1, 1, 0, 0, 0)
      d = described_class.between(t1, t2)
      expect(d.to_seconds).to eq(9000.0)
    end
  end

  describe 'arithmetic' do
    let(:d1) { described_class.parse('2h') }
    let(:d2) { described_class.parse('30m') }

    it 'adds durations' do
      result = d1 + d2
      expect(result.to_seconds).to eq(9000.0)
    end

    it 'subtracts durations' do
      result = d1 - d2
      expect(result.to_seconds).to eq(5400.0)
    end

    it 'multiplies by a number' do
      result = d2 * 3
      expect(result.to_seconds).to eq(5400.0)
    end

    it 'divides by a number' do
      result = d1 / 2
      expect(result.to_seconds).to eq(3600.0)
    end
  end

  describe 'comparison' do
    it 'compares durations with <' do
      expect(described_class.parse('1h')).to be < described_class.parse('2h')
    end

    it 'compares durations with ==' do
      expect(described_class.parse('60m')).to eq(described_class.parse('1h'))
    end

    it 'compares durations with >' do
      expect(described_class.parse('2h')).to be > described_class.parse('1h')
    end
  end

  describe '#to_human' do
    it 'formats hours and minutes' do
      expect(described_class.parse('2h 30m').to_human).to eq('2 hours, 30 minutes')
    end

    it 'formats zero duration' do
      expect(described_class.new(0).to_human).to eq('0 seconds')
    end

    it 'uses singular for one unit' do
      expect(described_class.parse('1h').to_human).to eq('1 hour')
    end
  end

  describe '#to_iso8601' do
    it 'formats as ISO 8601' do
      expect(described_class.parse('2h 30m').to_iso8601).to eq('PT2H30M')
    end

    it 'formats zero as PT0S' do
      expect(described_class.new(0).to_iso8601).to eq('PT0S')
    end
  end

  describe 'immutability' do
    it 'is frozen' do
      d = described_class.parse('1h')
      expect(d).to be_frozen
    end
  end

  describe 'parse edge cases' do
    it 'parses 0 seconds' do
      d = described_class.parse(0)
      expect(d.to_seconds).to eq(0.0)
    end

    it 'parses very large values' do
      d = described_class.parse(86_400 * 365)
      expect(d.to_seconds).to eq(86_400.0 * 365)
    end

    it 'parses seconds-only human string' do
      d = described_class.parse('45s')
      expect(d.to_seconds).to eq(45.0)
    end

    it 'parses full word units' do
      d = described_class.parse('2 hours 15 minutes 30 seconds')
      expect(d.to_seconds).to eq(8130.0)
    end

    it 'parses ISO 8601 seconds only' do
      d = described_class.parse('PT45S')
      expect(d.to_seconds).to eq(45.0)
    end

    it 'parses ISO 8601 days only' do
      d = described_class.parse('P3D')
      expect(d.to_seconds).to eq(259_200.0)
    end
  end

  describe 'arithmetic with mixed units' do
    it 'adds duration and numeric' do
      d = described_class.parse('1h')
      result = d + 60
      expect(result.to_seconds).to eq(3660.0)
    end

    it 'subtracts numeric from duration' do
      d = described_class.parse('1h')
      result = d - 60
      expect(result.to_seconds).to eq(3540.0)
    end

    it 'raises on subtraction resulting in negative' do
      d = described_class.parse('1m')
      expect { d - 120 }.to raise_error(described_class::Error)
    end

    it 'raises on invalid operand type' do
      d = described_class.parse('1h')
      bad = 'bad'
      expect { d + bad }.to raise_error(described_class::Error)
    end
  end

  describe 'comparison at boundary' do
    it 'treats 60 minutes as equal to 1 hour' do
      expect(described_class.parse('60m')).to eq(described_class.parse('1h'))
    end

    it 'treats 86400 seconds as equal to 1 day' do
      expect(described_class.parse('86400s')).to eq(described_class.parse('1 day'))
    end

    it 'returns nil when comparing with non-Duration' do
      d = described_class.parse('1h')
      expect(d <=> 3600).to be_nil
    end
  end

  describe 'ISO 8601 roundtrip' do
    it 'roundtrips hours and minutes' do
      d = described_class.parse('PT2H30M')
      expect(described_class.parse(d.to_iso8601).to_seconds).to eq(d.to_seconds)
    end

    it 'roundtrips days' do
      d = described_class.parse('P5D')
      expect(described_class.parse(d.to_iso8601).to_seconds).to eq(d.to_seconds)
    end

    it 'roundtrips complex durations' do
      d = described_class.parse('P2DT3H15M45S')
      expect(described_class.parse(d.to_iso8601).to_seconds).to eq(d.to_seconds)
    end
  end

  describe 'negative durations' do
    it 'raises on negative seconds in constructor' do
      expect { described_class.new(-1) }.to raise_error(described_class::Error)
    end
  end

  describe '#to_human with singular units' do
    it 'uses singular for 1 day' do
      expect(described_class.parse('1 day').to_human).to eq('1 day')
    end

    it 'uses singular for 1 minute' do
      expect(described_class.parse('1m').to_human).to eq('1 minute')
    end

    it 'uses singular for 1 second' do
      expect(described_class.parse('1s').to_human).to eq('1 second')
    end

    it 'formats mixed singular and plural' do
      expect(described_class.parse('1h 30m').to_human).to eq('1 hour, 30 minutes')
    end
  end

  describe '.between edge cases' do
    it 'returns zero duration for same time' do
      t = Time.new(2026, 1, 1, 0, 0, 0)
      d = described_class.between(t, t)
      expect(d.to_seconds).to eq(0.0)
    end

    it 'handles large time differences' do
      t1 = Time.new(2020, 1, 1)
      t2 = Time.new(2026, 1, 1)
      d = described_class.between(t1, t2)
      expect(d.to_seconds).to be > 0
    end
  end

  describe '#inspect' do
    it 'returns a readable representation' do
      d = described_class.parse('2h 30m')
      expect(d.inspect).to eq('#<Duration 2 hours, 30 minutes>')
    end
  end

  describe '#to_s' do
    it 'returns human-readable format' do
      d = described_class.parse('1h')
      expect(d.to_s).to eq('1 hour')
    end
  end

  describe 'component accessors' do
    let(:duration) { described_class.parse('1 day 2 hours 30 minutes 45 seconds') }

    it 'returns days component' do
      expect(duration.days).to eq(1)
    end

    it 'returns hours component' do
      expect(duration.hours).to eq(2)
    end

    it 'returns minutes component' do
      expect(duration.minutes).to eq(30)
    end

    it 'returns seconds component' do
      expect(duration.seconds).to eq(45)
    end

    it 'returns zero for missing components' do
      d = described_class.parse('2h')
      expect(d.days).to eq(0)
      expect(d.minutes).to eq(0)
      expect(d.seconds).to eq(0)
    end
  end

  describe '#to_hash' do
    it 'returns component hash' do
      d = described_class.parse('1 day 2 hours 30 minutes 45 seconds')
      expect(d.to_hash).to eq({ weeks: 0, days: 1, hours: 2, minutes: 30, seconds: 45 })
    end

    it 'returns zeros for zero duration' do
      expect(described_class.new(0).to_hash).to eq({ weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0 })
    end

    it 'includes weeks component' do
      d = described_class.parse('2 weeks 3 days')
      expect(d.to_hash).to eq({ weeks: 2, days: 3, hours: 0, minutes: 0, seconds: 0 })
    end
  end

  describe '#round' do
    it 'rounds to nearest hour' do
      d = described_class.parse('1h 45m')
      expect(d.round(:hour).to_seconds).to eq(7200.0)
    end

    it 'rounds down to nearest hour' do
      d = described_class.parse('1h 20m')
      expect(d.round(:hour).to_seconds).to eq(3600.0)
    end

    it 'rounds to nearest minute' do
      d = described_class.parse('1h 30s')
      expect(d.round(:minute).to_seconds).to eq(3660.0)
    end

    it 'rounds to nearest day' do
      d = described_class.parse('1 day 13 hours')
      expect(d.round(:day).to_seconds).to eq(172_800.0)
    end

    it 'rounds to nearest second' do
      d = described_class.new(90.7)
      expect(d.round(:second).to_seconds).to eq(91.0)
    end

    it 'raises on unknown unit' do
      expect { described_class.parse('1h').round(:month) }.to raise_error(described_class::Error)
    end
  end

  describe '.zero' do
    it 'returns a zero-length duration' do
      expect(described_class.zero.to_seconds).to eq(0.0)
    end

    it 'is zero?' do
      expect(described_class.zero.zero?).to be(true)
    end
  end

  describe '#zero?' do
    it 'returns false for a nonzero duration' do
      expect(described_class.parse('1s').zero?).to be(false)
    end
  end

  describe '#to_minutes' do
    it 'converts to total minutes' do
      expect(described_class.parse('2h 30m').to_minutes).to eq(150.0)
    end

    it 'returns fractional minutes' do
      expect(described_class.parse('90s').to_minutes).to eq(1.5)
    end
  end

  describe '#to_hours' do
    it 'converts to total hours' do
      expect(described_class.parse('2h 30m').to_hours).to eq(2.5)
    end

    it 'returns fractional hours' do
      expect(described_class.parse('45m').to_hours).to eq(0.75)
    end
  end

  describe '#to_days' do
    it 'converts to total days' do
      expect(described_class.parse('36h').to_days).to eq(1.5)
    end

    it 'returns fractional days' do
      expect(described_class.parse('12h').to_days).to eq(0.5)
    end
  end

  describe '#format' do
    let(:duration) { described_class.parse('1 day 2 hours 3 minutes 4 seconds') }

    it 'substitutes %D with days' do
      expect(duration.format('%D')).to eq('1')
    end

    it 'substitutes %H, %M, %S zero-padded' do
      expect(duration.format('%H:%M:%S')).to eq('02:03:04')
    end

    it 'substitutes %T with H:M:S' do
      expect(duration.format('%T')).to eq('02:03:04')
    end

    it 'substitutes %s with total integer seconds' do
      expect(described_class.parse('90s').format('%s')).to eq('90')
    end

    it 'escapes %% as a literal percent' do
      expect(duration.format('%D%%')).to eq('1%')
    end

    it 'leaves non-token text intact' do
      expect(duration.format('%D days %T')).to eq('1 days 02:03:04')
    end

    it 'substitutes %W with weeks' do
      d = described_class.parse('2 weeks 1 day')
      expect(d.format('%W weeks %D days')).to eq('2 weeks 1 days')
    end
  end

  describe 'week support' do
    it 'parses human string with weeks' do
      d = described_class.parse('2w')
      expect(d.to_seconds).to eq(1_209_600.0)
    end

    it 'parses full word weeks' do
      d = described_class.parse('1 week 3 days')
      expect(d.to_seconds).to eq(864_000.0)
    end

    it 'parses ISO 8601 weeks' do
      d = described_class.parse('P2W')
      expect(d.to_seconds).to eq(1_209_600.0)
    end

    it 'parses ISO 8601 weeks with days' do
      d = described_class.parse('P1W3D')
      expect(d.to_seconds).to eq(864_000.0)
    end

    it 'returns weeks component' do
      d = described_class.parse('2 weeks 3 days')
      expect(d.weeks).to eq(2)
    end

    it 'returns days component within week' do
      d = described_class.parse('2 weeks 3 days')
      expect(d.days).to eq(3)
    end

    it 'formats weeks in to_human' do
      expect(described_class.parse('2w').to_human).to eq('2 weeks')
    end

    it 'formats singular week in to_human' do
      expect(described_class.parse('1w').to_human).to eq('1 week')
    end

    it 'formats weeks and days in to_human' do
      expect(described_class.parse('1 week 2 days').to_human).to eq('1 week, 2 days')
    end

    it 'formats weeks in to_iso8601' do
      expect(described_class.parse('2w').to_iso8601).to eq('P2W')
    end

    it 'formats weeks and days in to_iso8601' do
      expect(described_class.parse('1 week 3 days 2 hours').to_iso8601).to eq('P1W3DT2H')
    end

    it 'converts to total weeks' do
      expect(described_class.parse('2w').to_weeks).to eq(2.0)
    end

    it 'returns fractional weeks' do
      expect(described_class.parse('10 days').to_weeks).to be_within(0.001).of(1.429)
    end

    it 'rounds to nearest week' do
      d = described_class.parse('10 days')
      expect(d.round(:week).to_seconds).to eq(604_800.0)
    end
  end

  describe '.from_hash' do
    it 'creates duration from component hash' do
      d = described_class.from_hash(hours: 2, minutes: 30)
      expect(d.to_seconds).to eq(9000.0)
    end

    it 'creates duration with all components' do
      d = described_class.from_hash(weeks: 1, days: 2, hours: 3, minutes: 4, seconds: 5)
      expect(d.to_seconds).to eq(788_645.0)
    end

    it 'creates zero duration with no arguments' do
      d = described_class.from_hash
      expect(d.to_seconds).to eq(0.0)
    end

    it 'roundtrips with to_hash' do
      original = described_class.parse('1 week 2 days 3 hours 4 minutes 5 seconds')
      rebuilt = described_class.from_hash(**original.to_hash)
      expect(rebuilt.to_seconds).to eq(original.to_seconds)
    end
  end

  describe '#from_now' do
    it 'returns a Time in the future' do
      frozen_time = Time.new(2026, 4, 15, 12, 0, 0)
      allow(Time).to receive(:now).and_return(frozen_time)

      d = described_class.parse('2h')
      expect(d.from_now).to eq(Time.new(2026, 4, 15, 14, 0, 0))
    end
  end

  describe '#ago' do
    it 'returns a Time in the past' do
      frozen_time = Time.new(2026, 4, 15, 12, 0, 0)
      allow(Time).to receive(:now).and_return(frozen_time)

      d = described_class.parse('30m')
      expect(d.ago).to eq(Time.new(2026, 4, 15, 11, 30, 0))
    end
  end

  describe '#since' do
    it 'returns a Time offset forward from the given time' do
      base = Time.new(2026, 1, 1, 0, 0, 0)
      d = described_class.parse('1h 30m')
      expect(d.since(base)).to eq(Time.new(2026, 1, 1, 1, 30, 0))
    end
  end

  describe '#before' do
    it 'returns a Time offset backward from the given time' do
      base = Time.new(2026, 1, 1, 12, 0, 0)
      d = described_class.parse('3h')
      expect(d.before(base)).to eq(Time.new(2026, 1, 1, 9, 0, 0))
    end
  end

  describe '#to_i' do
    it 'returns total seconds as integer' do
      expect(described_class.parse('1h 30m').to_i).to eq(5400)
    end

    it 'truncates fractional seconds' do
      expect(described_class.new(90.7).to_i).to eq(90)
    end
  end

  describe '#to_f' do
    it 'returns total seconds as float' do
      expect(described_class.parse('1h 30m').to_f).to eq(5400.0)
    end

    it 'preserves fractional seconds' do
      expect(described_class.new(90.7).to_f).to eq(90.7)
    end
  end

  describe '#to_short' do
    it 'returns "0s" for a zero duration' do
      expect(described_class.zero.to_short).to eq('0s')
    end

    it 'formats a single-unit duration' do
      expect(described_class.from_hash(minutes: 5).to_short).to eq('5m')
    end

    it 'formats a multi-unit duration with single-letter suffixes' do
      expect(described_class.from_hash(hours: 2, minutes: 30).to_short).to eq('2h 30m')
    end

    it 'omits zero components' do
      expect(described_class.from_hash(hours: 1, seconds: 5).to_short).to eq('1h 5s')
    end

    it 'includes weeks when applicable' do
      expect(described_class.from_hash(weeks: 1, days: 2).to_short).to eq('1w 2d')
    end
  end
end
