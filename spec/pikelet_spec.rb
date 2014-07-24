require "spec_helper"
require "pikelet"
require "csv"

describe Pikelet do
  RSpec::Matchers.define :match_hash do |expected|
    match do |actual|
      actual.to_h == expected
    end
  end

  let(:records) { definition.parse(data).to_a }

  subject { records }

  describe "a simple flat file" do
    let(:definition) do
      Pikelet.define do
        name   0... 4
        number 4...13
      end
    end

    let(:data) do
      <<-FILE.gsub(/^\s*/, "").split(/[\r\n]+/)
        John012345678
        Sue 087654321
      FILE
    end

    it { is_expected.to have(2).records }

    its(:first) { is_expected.to match_hash(name: "John", number: "012345678") }
    its(:last)  { is_expected.to match_hash(name: "Sue",  number: "087654321") }
  end

  describe "a file with heterogeneous records" do
    let(:definition) do
      Pikelet.define do
        type_signature 0...1

        record 'A' do
          name   1... 5
          number 5...14
        end

        record 'B' do
          number  1...10
          name   10...14
        end
      end
    end

    let(:data) do
      <<-FILE.gsub(/^\s*/, "").split(/[\r\n]+/)
        AJohn012345678
        B087654321Sue
      FILE
    end


    it { is_expected.to have(2).records }

    its(:first) { is_expected.to match_hash(name: "John", number: "012345678", type_signature: "A") }
    its(:last)  { is_expected.to match_hash(name: "Sue",  number: "087654321", type_signature: "B") }
  end

  describe "a CSV file" do
    let(:definition) do
      Pikelet.define do
        name   0
        number 1
      end
    end

    let(:data) do
      CSV.parse <<-FILE.gsub(/^\s*/, "")
        John,012345678
        Sue,087654321
      FILE
    end

    it { is_expected.to have(2).records }

    its(:first) { is_expected.to match_hash(name: "John", number: "012345678") }
    its(:last)  { is_expected.to match_hash(name: "Sue",  number: "087654321") }
  end

  describe "inheritance" do
    let(:definition) do
      Pikelet.define do
        type_signature 0...6

        record 'SIMPLE' do
          name 6...10

          record 'FANCY' do
            number 10...19
          end
        end
      end
    end

    let(:data) do
      <<-FILE.gsub(/^\s*/, "").split(/[\r\n]+/)
        SIMPLEJohn012345678
        FANCY Sue 087654321
      FILE
    end

    it { is_expected.to have(2).records }

    its(:first) { is_expected.to match_hash(name: "John", type_signature: "SIMPLE") }
    its(:last)  { is_expected.to match_hash(name: "Sue",  number: "087654321", type_signature: "FANCY") }
  end

  describe "integer fields" do
    let(:definition) do
      Pikelet.define do
        value 0...4, type: :integer
      end
    end

    let(:data) do
      <<-FILE.gsub(/^\s*/, "").split(/[\r\n]+/)
        5637
      FILE
    end

    subject { records.first }

    its(:value) { is_expected.to eq 5637 }
  end

  describe "overpunch fields" do
    let(:definition) do
      Pikelet.define do
        value 0...4, type: :overpunch
      end
    end

    let(:data) do
      <<-FILE.gsub(/^\s*/, "").split(/[\r\n]+/)
        563J
      FILE
    end

    subject { records.first }

    its(:value) { is_expected.to eq -5631 }
  end
end
