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
end
