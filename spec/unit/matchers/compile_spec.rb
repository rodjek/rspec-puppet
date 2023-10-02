# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet/support'

describe RSpec::Puppet::ManifestMatchers::Compile do
  include RSpec::Puppet::Support
  # override RSpec::Puppet::Support's subject with the original default
  subject { described_class.new }

  let(:catalogue) { -> { load_catalogue(:host) } }
  let(:facts) { { 'operatingsystem' => 'Debian' } }

  describe 'a valid manifest' do
    let(:pre_condition) { 'file { "/tmp/resource": }' }

    it('matches') { is_expected.to be_matches catalogue }

    it {
      expect(subject).to have_attributes(
        description: 'compile into a catalogue without dependency cycles'
      )
    }

    context 'when expecting an "example" error' do
      before { subject.and_raise_error('example') }

      it("doesn't match") { is_expected.not_to be_matches catalogue }

      it {
        expect(subject).to have_attributes(
          description: 'fail to compile and raise the error "example"'
        )
      }

      context 'after matching' do
        before { subject.matches? catalogue }

        it {
          expect(subject).to have_attributes(
            failure_message: a_string_starting_with('expected that the catalogue would fail to compile and raise the error "example"')
          )
        }
      end
    end

    context 'when matching an "example" error' do
      before { subject.and_raise_error(/example/) }

      it("doesn't match") { is_expected.not_to be_matches catalogue }

      it {
        expect(subject).to have_attributes(
          description: 'fail to compile and raise an error matching /example/'
        )
      }

      context 'after matching' do
        before { subject.matches? catalogue }

        it {
          expect(subject).to have_attributes(
            failure_message: a_string_starting_with('expected that the catalogue would fail to compile and raise an error matching /example/')
          )
        }
      end
    end
  end

  describe 'a manifest with missing dependencies' do
    let(:pre_condition) { 'file { "/tmp/resource": require => File["/tmp/missing"] }' }

    it("doesn't match") { is_expected.not_to be_matches catalogue }

    context 'after matching' do
      before { subject.matches? catalogue }

      it {
        expect(subject).to have_attributes(
          failure_message: a_string_matching(%r{\Aerror during compilation: Could not (retrieve dependency|find resource) 'File\[/tmp/missing\]'})
        )
      }
    end
  end

  describe 'a manifest with syntax error' do
    let(:pre_condition) { 'file { "/tmp/resource": ' }

    it("doesn't match") { is_expected.not_to be_matches catalogue }

    context 'after matching' do
      before { subject.matches? catalogue }

      it {
        expect(subject).to have_attributes(
          failure_message: a_string_starting_with('error during compilation: ')
        )
      }
    end
  end

  describe 'a manifest with a dependency cycle' do
    let(:pre_condition) do
      <<-EOS
      file { "/tmp/a": require => File["/tmp/b"] }
      file { "/tmp/b": require => File["/tmp/a"] }
      EOS
    end

    it("doesn't match") { is_expected.not_to be_matches catalogue }

    context 'after matching' do
      before { subject.matches? catalogue }

      it {
        expect(subject).to have_attributes(
          failure_message: a_string_starting_with('dependency cycles found: ')
        )
      }
    end

    context 'when expecting an "example" error' do
      before { subject.and_raise_error('example') }

      it("doesn't match") { is_expected.not_to be_matches catalogue }

      context 'after matching' do
        before { subject.matches? catalogue }

        it {
          expect(subject).to have_attributes(
            description: 'fail to compile and raise the error "example"',
            failure_message: a_string_starting_with('dependency cycles found: ')
          )
        }
      end
    end

    context 'when matching an "example" error' do
      before { subject.and_raise_error(/example/) }

      it("doesn't match") { is_expected.not_to be_matches catalogue }

      context 'after matching' do
        before { subject.matches? catalogue }

        it {
          expect(subject).to have_attributes(
            description: 'fail to compile and raise an error matching /example/',
            failure_message: a_string_starting_with('dependency cycles found: ')
          )
        }
      end
    end
  end

  describe 'a manifest with a real failure' do
    let(:pre_condition) { 'fail("failure")' }

    it("doesn't match") { is_expected.not_to be_matches catalogue }

    context 'after matching' do
      before { subject.matches? catalogue }

      it {
        expect(subject).to have_attributes(
          description: 'compile into a catalogue without dependency cycles',
          failure_message: a_string_starting_with('error during compilation: ')
        )
      }
    end

    context 'when expecting the failure' do
      let(:expected_error) do
        'Evaluation Error: Error while evaluating a Function Call, failure (line: 52, column: 1) on node rspec::puppet::manifestmatchers::compile'
      end

      before { subject.and_raise_error(expected_error) }

      let(:error_detail) { 'failure (line: 52, column: 1)' }
      it('matches') { is_expected.to be_matches catalogue }

      it {
        expect(subject).to have_attributes(
          description: "fail to compile and raise the error \"#{expected_error}\""
        )
      }

      context 'after matching' do
        before { subject.matches? catalogue }

        it {
          expect(subject).to have_attributes(
            failure_message: a_string_starting_with('error during compilation: ')
          )
        }
      end
    end

    context 'when matching the failure' do
      before { subject.and_raise_error(/failure/) }

      it('matches') { is_expected.to be_matches catalogue }

      it {
        expect(subject).to have_attributes(
          description: 'fail to compile and raise an error matching /failure/'
        )
      }

      context 'after matching' do
        before { subject.matches? catalogue }

        it {
          expect(subject).to have_attributes(
            failure_message: a_string_starting_with('error during compilation: ')
          )
        }
      end
    end
  end
end
