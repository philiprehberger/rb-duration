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
      expect { d + 'bad' }.to raise_error(described_class::Error)
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
end
