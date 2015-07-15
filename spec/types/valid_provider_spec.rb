require 'spec_helper'

describe 'fake' do

  let :title do
    'foo'
  end

  it { should be_valid_type }

  describe 'tests of the types' do

    {
      :parameters =>
        {:baddies => ['one', 'two'], :goodies => ['three', 'four']},
      :properties =>
        {:baddies => ['five', 'fix'], :goodies => ['seven', 'eight']},
      :features   =>
        {:baddies => ['nine', 'ten'], :goodies => ['eleven', 'twelve']}
    }.each do |k, v|

      describe "#{k} checks" do

        [v[:baddies], v[:baddies].first].each do |baddies|
          it "should fail for #{baddies.size} baddies" do
            expect do
              should be_valid_type.send("with_#{k}".to_sym, baddies)
            end.to raise_error(
              RSpec::Expectations::ExpectationNotMetError,
              /Invalid #{k}: #{Array(baddies).join(',')}/
            )
          end
        end

        [v[:goodies], v[:goodies].first].each do |goodies|
          it "should pass with #{goodies.size} goodies" do
            should be_valid_type.send("with_#{k}".to_sym, goodies)
          end
        end

      end

    end

  end

  describe 'tests that create a resource instance' do

    let :params do
      { :three => 'value' }
    end

    it 'should pass when providers match' do
      should be_valid_type.with_provider(:default)
    end

    it 'should fail when provider does not match' do
      expect do
        should be_valid_type.with_provider(:non_matching)
      end.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /Expected provider: non_matching does not match: default/
      )
    end

    it 'should pass when providers match' do
      should be_valid_type.with_provider(:default)
    end

    it 'should fail with invalid parameters' do
      expect do
        should be_valid_type.with_set_attributes(
          :four => 'three'
        )
      end.to raise_error(
        Puppet::Error,
        /Valid values match \/\(one\|two\)\//
      )
    end

    it 'should not fail with valid parameters' do
      should be_valid_type.with_set_attributes(
        :four => 'one'
      )
    end

  end

end
