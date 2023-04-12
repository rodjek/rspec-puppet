# frozen_string_literal: true

require 'spec_helper'

describe 'fake' do
  let :title do
    'foo'
  end

  it { is_expected.to be_valid_type }

  describe 'tests of the types' do
    {
      parameters: { baddies: %w[one two], goodies: %w[three four] },
      properties: { baddies: %w[five fix], goodies: %w[seven eight] },
      features: { baddies: %w[nine ten], goodies: %w[eleven twelve] }
    }.each do |k, v|
      describe "#{k} checks" do
        [v[:baddies], v[:baddies].first].each do |baddies|
          it "fails for #{baddies.size} baddies" do
            expect do
              expect(subject).to be_valid_type.send("with_#{k}".to_sym, baddies)
            end.to raise_error(
              RSpec::Expectations::ExpectationNotMetError,
              /Invalid #{k}: #{Array(baddies).join(',')}/
            )
          end
        end

        [v[:goodies], v[:goodies].first].each do |goodies|
          it "passes with #{goodies.size} goodies" do
            expect(subject).to be_valid_type.send("with_#{k}".to_sym, goodies)
          end
        end
      end
    end
  end

  describe 'tests that create a resource instance' do
    let :params do
      { three: 'value' }
    end

    it 'passes when providers match' do
      expect(subject).to be_valid_type.with_provider(:default)
    end

    it 'fails when provider does not match' do
      expect do
        expect(subject).to be_valid_type.with_provider(:non_matching)
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected provider: non_matching does not match: default/
      )
    end

    it 'passes when providers match' do
      expect(subject).to be_valid_type.with_provider(:default)
    end

    it 'fails with invalid parameters' do
      expect do
        expect(subject).to be_valid_type.with_set_attributes(
          four: 'three'
        )
      end.to raise_error(
        Puppet::Error,
        %r{Valid values match /\(one\|two\)/}
      )
    end

    it 'does not fail with valid parameters' do
      expect(subject).to be_valid_type.with_set_attributes(
        four: 'one'
      )
    end
  end
end
